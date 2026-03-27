using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace MathSphere
{
    public partial class Flashcard : Page
    {
        private string CS =>
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private string UserId =>
            ((Session["UserID"] ?? Session["userID"]) as string)?.Trim() ?? "";

        // Models
        public class FlashDeck
        {
            public string DeckID { get; set; }
            public string DeckTitle { get; set; }
            public string ModuleName { get; set; }
            public int CardCount { get; set; }
            public bool IsCompleted { get; set; }
        }

        public class FlashCard
        {
            public string CardId { get; set; }
            public string Question { get; set; }
            public string Answer { get; set; }
            public int SortOrder { get; set; }
        }

        private string DeckSearch
        {
            get => ViewState["DS"] as string ?? "";
            set => ViewState["DS"] = value;
        }

        // -
        //  Page_Load
        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(UserId))
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (Request.Form["hdnCompleteFlashcard"] == "1")
            {
                ProcessFlashcardCompletion();
                return;
            }

            if (!IsPostBack)
            {
                string setId = Request.QueryString["setId"] ?? "";
                string moduleId = Request.QueryString["moduleId"] ?? "";

                if (!string.IsNullOrEmpty(setId))
                    ShowStudy(setId, moduleId);
                else
                    ShowDecks();
            }
        }

        // -
        //  DECK PICKER
        // -
        private void ShowDecks()
        {
            pnlStudy.Visible = false;
            pnlDeckPicker.Visible = true;

            var decks = GetDecks(DeckSearch);
            rptDecks.DataSource = decks;
            rptDecks.DataBind();

            txtDeckSearch.Text = DeckSearch;
            pnlNoDecks.Visible = decks.Count == 0;
        }

        private List<FlashDeck> GetDecks(string search)
        {
            var list = new List<FlashDeck>();

            const string sql = @"
                SELECT
                    fs.flashcardSetID                        AS DeckID,
                    fs.setTitle                              AS DeckTitle,
                    ISNULL(m.moduleTitle, 'General')         AS ModuleName,
                    (SELECT COUNT(*)
                     FROM   dbo.flashcardTable fc
                     WHERE  fc.flashcardSetID = fs.flashcardSetID) AS CardCount,
                    CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.flashcardCompletionTable fct
                        JOIN   dbo.flashcardTable                  ft
                               ON ft.flashcardID = fct.flashcardID
                        WHERE  ft.flashcardSetID = fs.flashcardSetID
                          AND  fct.userID        = @uid
                          AND  fct.isCompleted   = 1
                    ) THEN 1 ELSE 0 END                      AS IsCompleted
                FROM  dbo.flashcardSetTable     fs
                LEFT JOIN dbo.moduleTable       m ON m.moduleID = fs.moduleID
                WHERE (
                    EXISTS (
                        SELECT 1 FROM dbo.studentEnrolmentTable se
                        WHERE  se.userID      = @uid
                          AND  se.enrolStatus = 1
                          AND  se.courseID    = m.courseID
                    )
                    OR fs.moduleID IS NULL
                )
                AND (
                    @search = ''
                    OR fs.setTitle   LIKE @searchLike
                    OR m.moduleTitle LIKE @searchLike
                )
                ORDER BY m.moduleTitle, fs.setTitle";

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = UserId;
                    cmd.Parameters.Add("@search", SqlDbType.NVarChar, 200).Value = search ?? "";
                    cmd.Parameters.Add("@searchLike", SqlDbType.NVarChar, 202).Value = "%" + (search ?? "") + "%";
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            list.Add(new FlashDeck
                            {
                                DeckID = dr["DeckID"].ToString(),
                                DeckTitle = dr["DeckTitle"].ToString(),
                                ModuleName = dr["ModuleName"].ToString(),
                                CardCount = Convert.ToInt32(dr["CardCount"]),
                                IsCompleted = Convert.ToInt32(dr["IsCompleted"]) == 1
                            });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Flashcard] GetDecks: " + ex);
            }

            return list;
        }

        // -
        //  STUDY VIEW
        // -
        private void ShowStudy(string setId, string moduleId = "")
        {
            if (string.IsNullOrWhiteSpace(setId)) { ShowDecks(); return; }

            var cards = GetCards(setId);
            var deck = GetDeckInfo(setId);

            if (cards.Count == 0) { ShowDecks(); return; }

            pnlDeckPicker.Visible = false;
            pnlStudy.Visible = true;

            litStudyTitle.Text = System.Web.HttpUtility.HtmlEncode(deck.DeckTitle);
            litStudyModule.Text = System.Web.HttpUtility.HtmlEncode(deck.ModuleName);

            string backUrl = !string.IsNullOrEmpty(moduleId)
                ? "moduleContent.aspx?moduleId=" + moduleId
                : "StudentDashboard.aspx";
            lnkBackToCourse.NavigateUrl = backUrl;
            lnkBackToCourse2.NavigateUrl = backUrl;

            hfDeckId.Value = setId;
            hfReturnModule.Value = moduleId;

            bool isFirst = !HasCompletedDeck(setId);
            hfIsFirstAttempt.Value = isFirst ? "1" : "0";

            int xp = isFirst ? SystemSettingsHelper.GetInt("FlashcardCompletion", 10) : 0;
            hfFlashcardXP.Value = xp.ToString();

            pnlAlreadyComplete.Visible = !isFirst;

            var ser = new JavaScriptSerializer();
            hfCardsJson.Value = ser.Serialize(cards);
            hfKnownJson.Value = "{}";
            hfCurrentDeck.Value = setId;
        }

        // -
        //  PROCESS FLASHCARD COMPLETION POST
        // -
        private void ProcessFlashcardCompletion()
        {
            string deckId = Request.Form["hdnCompleteDeckId"] ?? "";
            string moduleId = Request.Form["hdnCompleteModuleId"] ?? "";

            if (string.IsNullOrEmpty(deckId))
            {
                deckId = Request.QueryString["setId"] ?? "";
                moduleId = Request.QueryString["moduleId"] ?? "";
            }

            if (string.IsNullOrEmpty(deckId)) { ShowDecks(); return; }

            bool isFirst = !HasCompletedDeck(deckId);

            MarkFlashcardSetCompleted(deckId);

            string blockId = GetBlockIdFromDeck(deckId);
            if (!string.IsNullOrEmpty(blockId))
                MarkBlockCompleted(blockId);

            if (isFirst && !string.IsNullOrEmpty(moduleId))
            {
                int xp = SystemSettingsHelper.GetInt("FlashcardCompletion", 10);
                if (xp > 0)
                    AwardXpOnce(moduleId, xp, "FlashcardComplete",
                     ("FC" + deckId).Length > 10
                         ? ("FC" + deckId).Substring(0, 10)
                         : "FC" + deckId);
            }

            if (!string.IsNullOrEmpty(moduleId))
                UpdateModuleCompletion(moduleId);

            UpdateStreak();

            string returnUrl = !string.IsNullOrEmpty(moduleId)
                ? "moduleContent.aspx?moduleId=" + Uri.EscapeDataString(moduleId)
                : "Flashcard.aspx?setId=" + Uri.EscapeDataString(deckId)
                    + (string.IsNullOrEmpty(moduleId) ? "" : "&moduleId=" + moduleId);

            Response.Redirect(returnUrl);
        }

        // -
        //  Streak update — once per calendar day (UTC)
        //  Mirrors the same logic as moduleContent.UpdateStreak.
        //  Also awards StreakBonus7Day at every 7-day milestone.
        // -
        private void UpdateStreak()
        {
            int newStreak = 0;
            try
            {
                using (var con = new SqlConnection(CS))
                {
                    con.Open();
                    using (var cmd = new SqlCommand(@"
                        DECLARE @today DATE = CAST(SYSUTCDATETIME() AS DATE);

                        IF EXISTS (SELECT 1 FROM dbo.StudentStreak WHERE userID = @uid)
                        BEGIN
                            DECLARE @last DATE, @cur INT, @best INT;
                            SELECT @last = lastActivityDate,
                                   @cur  = currentStreak,
                                   @best = bestStreak
                            FROM   dbo.StudentStreak WHERE userID = @uid;

                            IF @last = @today
                            BEGIN
                                SELECT currentStreak FROM dbo.StudentStreak WHERE userID = @uid;
                                RETURN;
                            END

                            DECLARE @newStreak INT =
                                CASE WHEN @last = DATEADD(DAY, -1, @today)
                                     THEN @cur + 1
                                     ELSE 1
                                END;

                            UPDATE dbo.StudentStreak
                            SET currentStreak    = @newStreak,
                                bestStreak       = CASE WHEN @newStreak > @best THEN @newStreak ELSE @best END,
                                lastActivityDate = @today,
                                updatedAt        = SYSUTCDATETIME()
                            WHERE userID = @uid;

                            SELECT @newStreak;
                        END
                        ELSE
                        BEGIN
                            INSERT INTO dbo.StudentStreak
                                (streakID, userID, currentStreak, bestStreak, lastActivityDate, updatedAt)
                            VALUES (
                                LEFT(REPLACE(NEWID(),'-',''), 10),
                                @uid, 1, 1, @today, SYSUTCDATETIME()
                            );
                            SELECT 1;
                        END", con))
                    {
                        cmd.Parameters.AddWithValue("@uid", UserId);
                        var result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            newStreak = Convert.ToInt32(result);
                    }

                    // Award 7-day streak bonus
                    if (newStreak > 0 && newStreak % 7 == 0)
                    {
                        int bonus = SystemSettingsHelper.GetInt("StreakBonus7Day", 100);
                        if (bonus > 0)
                        {
                            string sourceId = "SK" + newStreak;
                            if (sourceId.Length > 10) sourceId = sourceId.Substring(0, 10);

                            // Need a moduleId for AwardXpOnce — use empty string safely
                            // The bonus is user-level, moduleId will resolve to NULL in score event
                            AwardXpOnceRaw(con, UserId, "", "StreakBonus", sourceId, bonus);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Flashcard.UpdateStreak] " + ex.Message);
            }
        }

        // -
        //  DB: Check if student already completed this deck
        // -
        private bool HasCompletedDeck(string deckId)
        {
            const string sql = @"
        SELECT COUNT(*)
        FROM   dbo.flashcardCompletionTable fct
        JOIN   dbo.flashcardTable           ft
               ON ft.flashcardID = fct.flashcardID
        WHERE  ft.flashcardSetID = @did
          AND  fct.userID        = @uid
          AND  fct.isCompleted   = 1";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@did", SqlDbType.NVarChar, 20).Value = deckId;
                    cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = UserId;
                    con.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
            catch { return false; }
        }

        // -
        //  DB: Mark all cards in set as completed
        // -
        private void MarkFlashcardSetCompleted(string deckId)
        {
            const string updateSql = @"
        UPDATE dbo.flashcardCompletionTable
        SET    isCompleted = 1,
               completedAt = SYSUTCDATETIME()
        WHERE  userID = @uid
          AND  flashcardID IN (
              SELECT flashcardID FROM dbo.flashcardTable
              WHERE  flashcardSetID = @did
          )";

            const string insertSql = @"
        IF NOT EXISTS (
            SELECT 1
            FROM   dbo.flashcardCompletionTable fct
            JOIN   dbo.flashcardTable           ft
                   ON ft.flashcardID = fct.flashcardID
            WHERE  ft.flashcardSetID = @did
              AND  fct.userID        = @uid
        )
        BEGIN
            DECLARE @fid nvarchar(10);
            SELECT TOP 1 @fid = flashcardID
            FROM   dbo.flashcardTable
            WHERE  flashcardSetID = @did
            ORDER  BY orderIndex ASC;

            IF @fid IS NOT NULL
            BEGIN
                DECLARE @n int;
                SELECT @n = ISNULL(MAX(
                    TRY_CAST(SUBSTRING(LTRIM(RTRIM(completionID)), 3, LEN(completionID))
                             AS int)), 0) + 1
                FROM   dbo.flashcardCompletionTable
                WHERE  completionID LIKE 'FC[0-9]%';

                INSERT INTO dbo.flashcardCompletionTable
                       (completionID, userID, flashcardID, isCompleted, completedAt)
                VALUES (
                    'FC' + RIGHT('00000000' + CAST(@n AS nvarchar(8)), 8),
                    @uid, @fid, 1, SYSUTCDATETIME()
                )
            END
        END";

            try
            {
                using (var con = new SqlConnection(CS))
                {
                    con.Open();
                    using (var cmd = new SqlCommand(updateSql, con))
                    {
                        cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = UserId;
                        cmd.Parameters.Add("@did", SqlDbType.NVarChar, 20).Value = deckId;
                        cmd.ExecuteNonQuery();
                    }
                    using (var cmd = new SqlCommand(insertSql, con))
                    {
                        cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = UserId;
                        cmd.Parameters.Add("@did", SqlDbType.NVarChar, 20).Value = deckId;
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Flashcard.MarkFlashcardSetCompleted] " + ex.Message);
            }
        }

        // -
        //  DB: Get blockID linked to this flashcard set
        // -
        private string GetBlockIdFromDeck(string deckId)
        {
            const string sql = @"
                SELECT TOP 1 mb.blockID
                FROM   dbo.blockContentTable  bc
                JOIN   dbo.moduleBlockTable   mb ON mb.blockID = bc.blockID
                WHERE  LTRIM(RTRIM(bc.flashcardSetID)) = LTRIM(RTRIM(@did))";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@did", SqlDbType.NVarChar, 20).Value = deckId;
                    con.Open();
                    return cmd.ExecuteScalar()?.ToString()?.Trim() ?? "";
                }
            }
            catch { return ""; }
        }

        // -
        //  DB: Mark block completed
        // -
        private void MarkBlockCompleted(string blockId)
        {
            const string sql = @"
                IF EXISTS (
                    SELECT 1 FROM dbo.studentBlockProgressTable
                    WHERE  userID = @uid AND blockID = @bid
                )
                BEGIN
                    UPDATE dbo.studentBlockProgressTable
                    SET    isCompleted = 1, completedAt = SYSUTCDATETIME()
                    WHERE  userID = @uid AND blockID = @bid
                END
                ELSE
                BEGIN
                    DECLARE @n int;
                    SELECT @n = ISNULL(MAX(
                        TRY_CAST(SUBSTRING(LTRIM(RTRIM(progressID)),3,LEN(progressID))
                                 AS int)),0)+1
                    FROM   dbo.studentBlockProgressTable
                    WHERE  progressID LIKE 'BP[0-9]%';

                    INSERT INTO dbo.studentBlockProgressTable
                           (progressID, userID, blockID,
                            isCompleted, startedAt, completedAt)
                    VALUES ('BP'+RIGHT('000000000000000000'+CAST(@n AS nvarchar(18)),18),
                            @uid, @bid, 1, SYSUTCDATETIME(), SYSUTCDATETIME())
                END";

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = UserId;
                    cmd.Parameters.Add("@bid", SqlDbType.NVarChar, 10).Value = blockId;
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Flashcard.MarkBlockCompleted] " + ex.Message);
            }
        }

        // -
        //  DB: Award XP once (with moduleId string param)
        // -
        private void AwardXpOnce(string moduleId, int points, string sourceType, string sourceId)
        {
            if (points <= 0) return;
            string safeSourceId = sourceId.Length > 10 ? sourceId.Substring(0, 10) : sourceId;
            string safeModuleId = moduleId.Length > 10 ? moduleId.Substring(0, 10) : moduleId;

            try
            {
                using (var con = new SqlConnection(CS))
                {
                    con.Open();
                    AwardXpOnceRaw(con, UserId, safeModuleId, sourceType, safeSourceId, points);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Flashcard.AwardXpOnce] " + ex.Message);
            }
        }

        // -
        //  Internal XP writer — reused by both AwardXpOnce and UpdateStreak
        // -
        private void AwardXpOnceRaw(SqlConnection con, string userId,
                                     string moduleId, string sourceType,
                                     string sourceId, int points)
        {
            const string sql = @"
        IF NOT EXISTS (
            SELECT 1 FROM dbo.studentScoreEventTable
            WHERE  userID = @uid AND sourceID = @sid AND sourceType = @stype
        )
        BEGIN
            DECLARE @courseId nvarchar(10) = NULL;
            IF LEN(@mid) > 0
                SELECT TOP 1 @courseId = courseID FROM dbo.moduleTable WHERE moduleID = @mid;

            DECLARE @n int;
            SELECT @n = ISNULL(MAX(
                TRY_CAST(SUBSTRING(LTRIM(RTRIM(eventID)), 3, LEN(eventID))
                         AS int)), 0) + 1
            FROM   dbo.studentScoreEventTable
            WHERE  eventID LIKE 'SE[0-9]%';

            INSERT INTO dbo.studentScoreEventTable
                   (eventID, userID, courseID, moduleID,
                    sourceType, sourceID, points, createdAt)
            VALUES (
                'SE' + RIGHT('00000000' + CAST(@n AS nvarchar(8)), 8),
                @uid, @courseId,
                CASE WHEN LEN(@mid) > 0 THEN @mid ELSE NULL END,
                @stype, @sid, @pts, GETDATE()
            )
        END";

            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = userId;
                cmd.Parameters.Add("@mid", SqlDbType.NVarChar, 10).Value = moduleId ?? "";
                cmd.Parameters.Add("@sid", SqlDbType.NVarChar, 10).Value = sourceId;
                cmd.Parameters.Add("@stype", SqlDbType.NVarChar, 30).Value = sourceType;
                cmd.Parameters.Add("@pts", SqlDbType.Int).Value = points;
                cmd.ExecuteNonQuery();
            }
        }

        private void UpdateModuleCompletion(string moduleId)
        {
            const string sql = @"
                DECLARE @total int, @done int, @pct decimal(5,2);

                SELECT @total = COUNT(*) FROM dbo.moduleBlockTable
                WHERE  moduleID = @mid AND isRequired = 1;

                SELECT @done = COUNT(*)
                FROM   dbo.studentBlockProgressTable sbp
                JOIN   dbo.moduleBlockTable mb ON mb.blockID = sbp.blockID
                WHERE  mb.moduleID = @mid AND sbp.userID = @uid
                  AND  sbp.isCompleted = 1 AND mb.isRequired = 1;

                SET @pct = CASE WHEN @total > 0
                    THEN CAST(@done AS decimal(5,2))/@total*100 ELSE 0 END;

                IF EXISTS (SELECT 1 FROM dbo.studentModuleCompletionTable
                           WHERE userID=@uid AND moduleID=@mid)
                    UPDATE dbo.studentModuleCompletionTable
                    SET    completionPercentage=@pct,
                           completionDate=CASE WHEN @pct>=100 THEN SYSUTCDATETIME()
                                               ELSE completionDate END
                    WHERE  userID=@uid AND moduleID=@mid
                ELSE BEGIN
                    DECLARE @n int;
                    SELECT @n=ISNULL(MAX(TRY_CAST(
                        SUBSTRING(LTRIM(RTRIM(completionID)),3,LEN(completionID))
                        AS int)),0)+1
                    FROM dbo.studentModuleCompletionTable
                    WHERE completionID LIKE 'MC[0-9]%';
                    INSERT INTO dbo.studentModuleCompletionTable
                           (completionID,userID,moduleID,completionDate,completionPercentage)
                    VALUES('MC'+RIGHT('000000000000000000'+CAST(@n AS nvarchar(18)),18),
                           @uid,@mid,
                           CASE WHEN @pct>=100 THEN SYSUTCDATETIME() ELSE NULL END,@pct)
                END

                IF EXISTS (SELECT 1 FROM dbo.studentProgressTable
                           WHERE userID=@uid AND moduleID=@mid)
                    UPDATE dbo.studentProgressTable
                    SET    completionPercentage=@pct, lastActiveAt=SYSUTCDATETIME()
                    WHERE  userID=@uid AND moduleID=@mid
                ELSE BEGIN
                    DECLARE @pn int;
                    SELECT @pn=ISNULL(MAX(TRY_CAST(
                        SUBSTRING(LTRIM(RTRIM(progressID)),3,LEN(progressID))
                        AS int)),0)+1
                    FROM dbo.studentProgressTable WHERE progressID LIKE 'SP[0-9]%';
                    INSERT INTO dbo.studentProgressTable
                           (progressID,userID,moduleID,currentStreak,completionPercentage,lastActiveAt)
                    VALUES('SP'+RIGHT('00000000'+CAST(@pn AS nvarchar(8)),8),
                           @uid,@mid,0,@pct,SYSUTCDATETIME())
                END";

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = UserId;
                    cmd.Parameters.Add("@mid", SqlDbType.NVarChar, 20).Value = moduleId;
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Flashcard.UpdateModuleCompletion] " + ex.Message);
            }
        }

        // -
        //  Deck info + Cards
        // -
        private FlashDeck GetDeckInfo(string setId)
        {
            const string sql = @"
                SELECT fs.setTitle, ISNULL(m.moduleTitle,'General') AS moduleTitle
                FROM   dbo.flashcardSetTable fs
                LEFT JOIN dbo.moduleTable    m ON m.moduleID = fs.moduleID
                WHERE  fs.flashcardSetID = @sid";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@sid", SqlDbType.NVarChar, 20).Value = setId;
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        if (dr.Read())
                            return new FlashDeck
                            {
                                DeckID = setId,
                                DeckTitle = dr["setTitle"].ToString(),
                                ModuleName = dr["moduleTitle"].ToString()
                            };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Flashcard] GetDeckInfo: " + ex);
            }
            return new FlashDeck { DeckID = setId, DeckTitle = "Deck", ModuleName = "" };
        }

        private List<FlashCard> GetCards(string setId)
        {
            var list = new List<FlashCard>();
            const string sql = @"
                SELECT flashcardID,
                       ISNULL(questionText,'') AS questionText,
                       ISNULL(answerText,  '') AS answerText,
                       ISNULL(orderIndex,   0) AS orderIndex
                FROM   dbo.flashcardTable
                WHERE  flashcardSetID = @sid
                ORDER  BY orderIndex ASC, flashcardID ASC";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@sid", SqlDbType.NVarChar, 20).Value = setId;
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            list.Add(new FlashCard
                            {
                                CardId = dr["flashcardID"].ToString(),
                                Question = dr["questionText"].ToString(),
                                Answer = dr["answerText"].ToString(),
                                SortOrder = Convert.ToInt32(dr["orderIndex"])
                            });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Flashcard] GetCards: " + ex);
            }
            return list;
        }

        // -
        //  Event handlers
        // -
        protected void rptDecks_ItemCommand(object src,
            System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "OpenDeck")
                ShowStudy(e.CommandArgument?.ToString());
        }

        protected void btnDeckSearch_Click(object s, EventArgs e)
        {
            DeckSearch = txtDeckSearch.Text.Trim();
            ShowDecks();
        }

        // -
        //  Helpers
        // -
        private static readonly string[] AccentClasses = {
            "bg-blue-500", "bg-green-500", "bg-yellow-400",
            "bg-purple-500", "bg-red-400",  "bg-pink-500",
            "bg-teal-500",   "bg-orange-400"
        };

        protected string GetDeckAccentClass(int index)
            => AccentClasses[index % AccentClasses.Length];
    }
}
