using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class moduleContent : System.Web.UI.Page
    {
        private readonly string cs =
            System.Configuration.ConfigurationManager
                  .ConnectionStrings["MathSphereDB"].ConnectionString;

        private bool IsGuest =>
            Session["IsGuest"] is bool b && b &&
            string.IsNullOrWhiteSpace(
                (Session["UserID"] ?? Session["userID"])?.ToString());

        private string StudentId =>
            ((Session["UserID"] ?? Session["userID"]) as string)?.Trim() ?? "";

        public string ModuleId { get; private set; }

        // -
        //  Page_Load
        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsGuest && string.IsNullOrEmpty(StudentId))
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            ModuleId = Request.QueryString["moduleId"] ?? "";

            if (string.IsNullOrEmpty(ModuleId))
            {
                Response.Redirect(IsGuest ? "~/BrowseModule.aspx" : "~/StudentDashboard.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                try
                {
                    BindSidebarModules();
                    BindModuleHeader();
                    BindBlocks();
                    if (!IsGuest)
                        BindModuleAssessment();
                    else
                        pnlAssessmentSection.Visible = false;

                    FocusRequestedBlock();
                }
                catch (Exception ex)
                {
                    ShowActionError("We couldn't load this lesson completely. Please refresh and try again.");
                    pnlAssessmentSection.Visible = false;
                    System.Diagnostics.Debug.WriteLine("[moduleContent] Load error: " + ex);
                }
            }
        }
        private void FocusRequestedBlock()
        {
            string requestedBlockId = (Request.QueryString["blockId"] ?? string.Empty).Trim();
            if (string.IsNullOrEmpty(requestedBlockId)) return;

            string safeBlockId = HttpUtility.JavaScriptStringEncode(requestedBlockId);
            string script = $"window.setTimeout(function() {{ focusBlockById('{safeBlockId}'); }}, 80);";

            ScriptManager.RegisterStartupScript(this, GetType(), "focusRequestedBlock", script, true);
        }


        // -
        //  YouTube embed helper
        // -
        public static string ConvertToEmbedUrl(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return "";
            url = url.Trim();
            if (url.Contains("youtube.com/embed/")) return url;
            string videoId = null;
            var m1 = Regex.Match(url, @"youtu\.be/([A-Za-z0-9_\-]{6,15})", RegexOptions.IgnoreCase);
            if (m1.Success) videoId = m1.Groups[1].Value;
            if (videoId == null)
            {
                var m2 = Regex.Match(url, @"[?&]v=([A-Za-z0-9_\-]{6,15})", RegexOptions.IgnoreCase);
                if (m2.Success) videoId = m2.Groups[1].Value;
            }
            if (videoId == null)
            {
                var m3 = Regex.Match(url, @"youtube\.com/shorts/([A-Za-z0-9_\-]{6,15})", RegexOptions.IgnoreCase);
                if (m3.Success) videoId = m3.Groups[1].Value;
            }
            return !string.IsNullOrEmpty(videoId) ? "https://www.youtube.com/embed/" + videoId : url;
        }

        // -
        //  Sidebar
        // -
        private void BindSidebarModules()
        {
            const string sql = @"
                SELECT m.moduleID, m.moduleTitle AS ModuleName
                FROM   dbo.moduleTable m
                WHERE  m.courseID = (SELECT courseID FROM dbo.moduleTable WHERE moduleID = @mid)
                  AND  m.Status = 'Active'
                ORDER  BY m.moduleID ASC";
            var dt = new DataTable();
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }
            rptModules.DataSource = dt;
            rptModules.DataBind();
        }

        // -
        //  Module header + progress bar
        // -
        private void BindModuleHeader()
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT moduleTitle, ISNULL(moduleDescription,'') AS moduleDescription
                FROM   dbo.moduleTable
                WHERE  moduleID = @mid AND Status = 'Active'", conn))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        litModuleTitle.Text = HttpUtility.HtmlEncode(r["moduleTitle"].ToString());
                        litModuleDescription.Text = HttpUtility.HtmlEncode(r["moduleDescription"].ToString());
                    }
                    else
                    {
                        Response.Redirect(IsGuest ? "~/BrowseModule.aspx" : "~/StudentDashboard.aspx", true);
                        return;
                    }
                }
            }

            if (IsGuest)
            {
                litProgressDone.Text = "0";
                litProgressTotal.Text = "0";
                litProgressPct.Text = "0";
                pnlModuleComplete.Visible = false;
                pnlProgressFill.Style["width"] = "0%";
                return;
            }

            int total = 0, done = 0;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT COUNT(*) AS Total,
                       SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) AS Done
                FROM  dbo.moduleBlockTable mb
                LEFT JOIN dbo.studentBlockProgressTable sbp
                       ON sbp.blockID = mb.blockID AND sbp.userID = @uid
                WHERE  mb.moduleID = @mid
                  AND  (mb.blockType IN ('Video','Text','Quiz') OR mb.blockType LIKE 'Flashcard%')", conn))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                cmd.Parameters.AddWithValue("@uid", StudentId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                    if (r.Read())
                    {
                        total = r["Total"] == DBNull.Value ? 0 : Convert.ToInt32(r["Total"]);
                        done = r["Done"] == DBNull.Value ? 0 : Convert.ToInt32(r["Done"]);
                    }
            }

            int pct = total > 0 ? (int)Math.Round((double)done / total * 100) : 0;
            litProgressDone.Text = done.ToString();
            litProgressTotal.Text = total.ToString();
            litProgressPct.Text = pct.ToString();
            pnlModuleComplete.Visible = (total > 0 && done >= total);
            pnlProgressFill.Style["width"] = pct + "%";
        }

        // -
        //  Content blocks repeater
        // -
        private void BindBlocks()
        {
            const string sql = @"
                SELECT
                    mb.blockID                                                   AS BlockID,
                    mb.blockType                                                 AS BlockType,
                    mb.title                                                     AS Title,
                    mb.orderIndex                                                AS OrderIndex,

                    CAST(ISNULL(sbp.isCompleted, 0) AS BIT)                     AS IsCompleted,

                    CAST(
                        CASE
                            WHEN ISNULL(sbp.isCompleted, 0) = 1               THEN 0
                            WHEN mar.moduleID IS NULL                          THEN 0
                            WHEN mar.sequentialProgress = 0                   THEN 0
                            WHEN EXISTS (
                                SELECT 1
                                FROM   dbo.moduleBlockTable mb2
                                LEFT JOIN dbo.studentBlockProgressTable sbp2
                                       ON sbp2.blockID = mb2.blockID AND sbp2.userID = @uid
                                WHERE  mb2.moduleID   = mb.moduleID
                                  AND  mb2.orderIndex < mb.orderIndex
                                  AND  (mb2.blockType IN ('Video','Text','Quiz') OR mb2.blockType LIKE 'Flashcard%')
                                  AND  ISNULL(sbp2.isCompleted, 0) = 0
                            )                                                  THEN 1
                            ELSE 0
                        END
                    AS BIT)                                                      AS IsLocked,

                    ISNULL(bc.videoUrl,     '')                                 AS VideoUrl,
                    ISNULL(bc.videoCaption, '')                                 AS VideoCaption,
                    ISNULL(bc.videoNotes,   '')                                 AS VideoNotes,
                    ISNULL(bc.textContent,  '')                                 AS TextContent,
                    ISNULL(bc.fileUrl,      '')                                 AS FileUrl,

                    ISNULL(bc.flashcardSetID, '')                               AS FlashcardSetID,
                    ISNULL(fs.setTitle,       '')                               AS FlashcardSetTitle,
                    CAST(CASE WHEN EXISTS (
                        SELECT 1
                        FROM   dbo.flashcardCompletionTable fct
                        JOIN   dbo.flashcardTable ft ON ft.flashcardID = fct.flashcardID
                        WHERE  ft.flashcardSetID = bc.flashcardSetID
                          AND  fct.userID        = @uid
                          AND  fct.isCompleted   = 1
                    ) THEN 1 ELSE 0 END AS BIT)                                 AS FlashcardAttempted,

                    ISNULL(qt.quizTitle, '')                                    AS QuizTitle,
                    CAST(CASE WHEN EXISTS (
                        SELECT 1
                        FROM   dbo.QuizAttempt qa
                        WHERE  qa.quizID = qt.quizID
                          AND  qa.userID = @uid
                    ) THEN 1 ELSE 0 END AS BIT)                                 AS QuizAttempted

                FROM  dbo.moduleBlockTable               mb
                LEFT JOIN dbo.blockContentTable          bc  ON bc.blockID        = mb.blockID
                LEFT JOIN dbo.studentBlockProgressTable  sbp ON sbp.blockID       = mb.blockID
                                                             AND sbp.userID        = @uid
                LEFT JOIN dbo.flashcardSetTable          fs  ON fs.flashcardSetID = CAST(bc.flashcardSetID AS nvarchar(20))
                LEFT JOIN dbo.quizTable                  qt  ON qt.blockID        = mb.blockID
                LEFT JOIN dbo.moduleAccessRuleTable      mar ON mar.moduleID      = mb.moduleID
                WHERE  mb.moduleID = @mid
                  AND  (mb.blockType IN ('Video','Text','Quiz') OR mb.blockType LIKE 'Flashcard%')
                ORDER  BY mb.orderIndex ASC, mb.blockID ASC";

            string effectiveUid = IsGuest ? "" : StudentId;

            var dt = new DataTable();
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                cmd.Parameters.AddWithValue("@uid", effectiveUid);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }

            if (dt.Columns.Contains("VideoUrl"))
                foreach (DataRow row in dt.Rows)
                {
                    string raw = row["VideoUrl"]?.ToString() ?? "";
                    if (!string.IsNullOrWhiteSpace(raw))
                        row["VideoUrl"] = ConvertToEmbedUrl(raw);
                }

            ConvertToBool(dt, "IsCompleted");
            ConvertToBool(dt, "IsLocked");
            ConvertToBool(dt, "FlashcardAttempted");
            ConvertToBool(dt, "QuizAttempted");

            rptBlocks.DataSource = dt;
            rptBlocks.DataBind();
        }

        // -
        //  Mark block complete
        // -
        protected void btnNext_Click(object sender, EventArgs e)
        {
            if (IsGuest) return;

            string blockId = (((Button)sender).CommandArgument ?? string.Empty).Trim();
            string studentId = StudentId;

            pnlActionError.Visible = false;
            litActionError.Text = string.Empty;

            if (string.IsNullOrEmpty(blockId))
            {
                ShowActionError("We couldn't identify this lesson block. Please refresh and try again.");
                return;
            }

            if (string.IsNullOrEmpty(studentId))
            {
                ShowActionError("Your session has expired. Please sign in again and retry.");
                return;
            }

            if (!IsBlockUnlocked(blockId, studentId))
            {
                ShowActionError("Complete the previous block first, then try marking this one complete again.");
                return;
            }

            try
            {
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    bool isFirstCompletion = !IsAlreadyCompleted(conn, blockId, studentId);
                    string blockType = GetBlockType(conn, blockId);

                    // 1. Mark block completed
                    using (var cmd = new SqlCommand(@"
                        IF EXISTS (SELECT 1 FROM dbo.studentBlockProgressTable WHERE blockID=@bid AND userID=@uid)
                            UPDATE dbo.studentBlockProgressTable
                            SET isCompleted=1,
                                completedAt=CASE WHEN completedAt IS NULL THEN SYSUTCDATETIME() ELSE completedAt END
                            WHERE blockID=@bid AND userID=@uid
                        ELSE
                            INSERT INTO dbo.studentBlockProgressTable
                                (progressID,userID,blockID,isCompleted,startedAt,completedAt)
                            VALUES(LEFT(REPLACE(NEWID(),'-',''),20),@uid,@bid,1,SYSUTCDATETIME(),SYSUTCDATETIME())", conn))
                    {
                        cmd.Parameters.AddWithValue("@bid", blockId);
                        cmd.Parameters.AddWithValue("@uid", studentId);
                        cmd.ExecuteNonQuery();
                    }

                    // -- 2. Award XP on first completion (Video, Text, Flashcard) --
                    if (isFirstCompletion)
                    {
                        string settingKey = null;
                        if (blockType == "Video") settingKey = "VideoCompleteXP";
                        else if (blockType == "Text") settingKey = "TextCompleteXP";
                        else if (!string.IsNullOrEmpty(blockType) && blockType.StartsWith("Flashcard", StringComparison.OrdinalIgnoreCase)) settingKey = "FlashcardCompletion"; // uses SystemSettings key

                        if (settingKey != null)
                        {
                            int xp = SystemSettingsHelper.GetInt(settingKey, 10);
                            if (xp > 0)
                            {
                                string rawSourceId = "B" + blockId;
                                string sourceId = rawSourceId.Length > 10
                                                     ? rawSourceId.Substring(0, 10) : rawSourceId;
                                AwardXpOnce(conn, studentId, ModuleId, blockType + "Complete", sourceId, xp);
                            }
                        }
                    }

                    // 3. Update module completion percentage
                    UpdateModuleCompletion(conn, studentId, ModuleId);

                    // -- 4. Update streak -
                    UpdateStreak(conn, studentId);
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "scrollNext",
                    "scrollToNextBlock();", true);
                BindModuleHeader();
                BindBlocks();
                BindModuleAssessment();
            }
            catch (Exception ex)
            {
                ShowActionError("We couldn't mark this block as complete right now. Please try again in a moment.");
                System.Diagnostics.Debug.WriteLine("[moduleContent] btnNext_Click error: " + ex);
            }
        }
        private void ShowActionError(string message)
        {
            pnlActionError.Visible = true;
            litActionError.Text = Server.HtmlEncode(message);
        }


        // -
        //  Streak update — once per calendar day (UTC)
        //  Reads lastActivityDate from StudentStreak (column confirmed in schema).
        //  Also awards StreakBonus7Day XP at every 7-day milestone.
        // -
        private void UpdateStreak(SqlConnection conn, string studentId)
        {
            // Step 1: upsert StudentStreak row, return new streak value
            int newStreak = 0;
            using (var cmd = new SqlCommand(@"
                DECLARE @today DATE = CAST(SYSUTCDATETIME() AS DATE);

                IF EXISTS (SELECT 1 FROM dbo.StudentStreak WHERE userID = @uid)
                BEGIN
                    DECLARE @last DATE, @cur INT, @best INT;
                    SELECT @last = lastActivityDate,
                           @cur  = currentStreak,
                           @best = bestStreak
                    FROM   dbo.StudentStreak WHERE userID = @uid;

                    -- Already counted today — return current value unchanged
                    IF @last = @today
                    BEGIN
                        SELECT currentStreak FROM dbo.StudentStreak WHERE userID = @uid;
                        RETURN;
                    END

                    DECLARE @newStreak INT =
                        CASE WHEN @last = DATEADD(DAY, -1, @today)
                             THEN @cur + 1   -- consecutive day: extend
                             ELSE 1          -- gap: reset
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
                    -- Brand new streak row for this student
                    INSERT INTO dbo.StudentStreak
                        (streakID, userID, currentStreak, bestStreak, lastActivityDate, updatedAt)
                    VALUES (
                        LEFT(REPLACE(NEWID(),'-',''), 10),
                        @uid, 1, 1, @today, SYSUTCDATETIME()
                    );
                    SELECT 1;
                END", conn))
            {
                cmd.Parameters.AddWithValue("@uid", studentId);
                var result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                    newStreak = Convert.ToInt32(result);
            }

            // Step 2: award StreakBonus7Day XP at every 7-day milestone
            if (newStreak > 0 && newStreak % 7 == 0)
            {
                int bonus = SystemSettingsHelper.GetInt("StreakBonus7Day", 100);
                if (bonus > 0)
                {
                    // sourceId encodes the milestone so each 7-day award is unique
                    string sourceId = ("SK" + newStreak);
                    if (sourceId.Length > 10) sourceId = sourceId.Substring(0, 10);
                    AwardXpOnce(conn, studentId, ModuleId, "StreakBonus", sourceId, bonus);
                }
            }
        }

        // -
        //  Helpers: block state
        // -
        private bool IsAlreadyCompleted(SqlConnection conn, string blockId, string studentId)
        {
            using (var cmd = new SqlCommand(@"
                SELECT ISNULL((SELECT TOP 1 isCompleted FROM dbo.studentBlockProgressTable
                               WHERE blockID=@bid AND userID=@uid),0)", conn))
            {
                cmd.Parameters.AddWithValue("@bid", blockId);
                cmd.Parameters.AddWithValue("@uid", studentId);
                return Convert.ToBoolean(cmd.ExecuteScalar());
            }
        }

        private string GetBlockType(SqlConnection conn, string blockId)
        {
            using (var cmd = new SqlCommand(
                "SELECT ISNULL(blockType,'') FROM dbo.moduleBlockTable WHERE blockID=@bid", conn))
            {
                cmd.Parameters.AddWithValue("@bid", blockId);
                return cmd.ExecuteScalar()?.ToString()?.Trim() ?? "";
            }
        }

        private bool IsBlockUnlocked(string blockId, string studentId)
        {
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                bool sequential = true;
                using (var cmd = new SqlCommand(@"
                    SELECT ISNULL(mar.sequentialProgress, 1)
                    FROM   dbo.moduleBlockTable mb
                    LEFT JOIN dbo.moduleAccessRuleTable mar ON mar.moduleID = mb.moduleID
                    WHERE  mb.blockID = @bid", conn))
                {
                    cmd.Parameters.AddWithValue("@bid", blockId);
                    var val = cmd.ExecuteScalar();
                    if (val != null && val != DBNull.Value)
                        sequential = Convert.ToBoolean(val);
                }
                if (!sequential) return true;

                using (var cmd = new SqlCommand(@"
                    SELECT COUNT(1)
                    FROM   dbo.moduleBlockTable mb2
                    LEFT JOIN dbo.studentBlockProgressTable sbp
                           ON sbp.blockID=mb2.blockID AND sbp.userID=@uid
                    WHERE  mb2.moduleID=(SELECT moduleID FROM dbo.moduleBlockTable WHERE blockID=@bid)
                      AND  mb2.orderIndex<(SELECT orderIndex FROM dbo.moduleBlockTable WHERE blockID=@bid)
                      AND  (mb2.blockType IN ('Video','Text','Quiz') OR mb2.blockType LIKE 'Flashcard%')
                      AND  ISNULL(sbp.isCompleted,0)=0", conn))
                {
                    cmd.Parameters.AddWithValue("@bid", blockId);
                    cmd.Parameters.AddWithValue("@uid", studentId);
                    return (int)cmd.ExecuteScalar() == 0;
                }
            }
        }

        // -
        //  all XP reads now go through SystemSettingsHelper
        // -
        private void AwardXpOnce(SqlConnection conn, string studentId, string moduleId,
                                  string sourceType, string sourceId, int points)
        {
            if (points <= 0) return;
            string safeMid = moduleId.Length > 10 ? moduleId.Substring(0, 10) : moduleId;
            using (var cmd = new SqlCommand(@"
                IF NOT EXISTS (SELECT 1 FROM dbo.studentScoreEventTable
                               WHERE userID=@uid AND sourceType=@stype AND sourceID=@sid)
                BEGIN
                    DECLARE @courseId nvarchar(10);
                    SELECT TOP 1 @courseId=courseID FROM dbo.moduleTable WHERE moduleID=@mid;
                    DECLARE @n int;
                    SELECT @n=ISNULL(MAX(TRY_CAST(
                        SUBSTRING(LTRIM(RTRIM(eventID)),3,LEN(eventID)) AS int)),0)+1
                    FROM dbo.studentScoreEventTable WHERE eventID LIKE 'SE[0-9]%';
                    INSERT INTO dbo.studentScoreEventTable
                        (eventID,userID,courseID,moduleID,sourceType,sourceID,points,createdAt)
                    VALUES('SE'+RIGHT('00000000'+CAST(@n AS nvarchar(8)),8),
                           @uid,@courseId,@mid,@stype,@sid,@pts,GETDATE())
                END", conn))
            {
                cmd.Parameters.AddWithValue("@uid", studentId);
                cmd.Parameters.AddWithValue("@mid", safeMid);
                cmd.Parameters.AddWithValue("@sid", sourceId);
                cmd.Parameters.AddWithValue("@stype", sourceType);
                cmd.Parameters.AddWithValue("@pts", points);
                cmd.ExecuteNonQuery();
            }
        }

        // -
        //  Module completion tracking
        // -
        private void UpdateModuleCompletion(SqlConnection conn, string studentId, string moduleId)
        {
            int total = 0, done = 0;
            using (var cmd = new SqlCommand(@"
                SELECT COUNT(*) AS Total,
                       SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) AS Done
                FROM dbo.moduleBlockTable mb
                LEFT JOIN dbo.studentBlockProgressTable sbp
                       ON sbp.blockID=mb.blockID AND sbp.userID=@uid
                WHERE mb.moduleID=@mid
                  AND (mb.blockType IN ('Video','Text','Quiz') OR mb.blockType LIKE 'Flashcard%')", conn))
            {
                cmd.Parameters.AddWithValue("@uid", studentId);
                cmd.Parameters.AddWithValue("@mid", moduleId);
                using (var r = cmd.ExecuteReader())
                    if (r.Read())
                    {
                        total = r["Total"] == DBNull.Value ? 0 : Convert.ToInt32(r["Total"]);
                        done = r["Done"] == DBNull.Value ? 0 : Convert.ToInt32(r["Done"]);
                    }
            }
            decimal pct = total > 0 ? Math.Round((decimal)done / total * 100, 2) : 0;

            using (var cmd = new SqlCommand(@"
                IF EXISTS(SELECT 1 FROM dbo.studentModuleCompletionTable
                          WHERE moduleID=@mid AND userID=@uid)
                    UPDATE dbo.studentModuleCompletionTable
                    SET completionPercentage=@pct,
                        completionDate=CASE WHEN @pct>=100 AND completionDate IS NULL
                                           THEN SYSUTCDATETIME() ELSE completionDate END
                    WHERE moduleID=@mid AND userID=@uid
                ELSE
                    INSERT INTO dbo.studentModuleCompletionTable
                        (completionID,userID,moduleID,completionDate,completionPercentage)
                    VALUES(LEFT(REPLACE(NEWID(),'-',''),20),@uid,@mid,
                           CASE WHEN @pct>=100 THEN SYSUTCDATETIME() ELSE NULL END,@pct)", conn))
            {
                cmd.Parameters.AddWithValue("@mid", moduleId);
                cmd.Parameters.AddWithValue("@uid", studentId);
                cmd.Parameters.AddWithValue("@pct", pct);
                cmd.ExecuteNonQuery();
            }

            using (var cmd = new SqlCommand(@"
                IF EXISTS(SELECT 1 FROM dbo.studentProgressTable
                          WHERE moduleID=@mid AND userID=@uid)
                    UPDATE dbo.studentProgressTable
                    SET completionPercentage=@pct, lastActiveAt=SYSUTCDATETIME()
                    WHERE moduleID=@mid AND userID=@uid
                ELSE
                    INSERT INTO dbo.studentProgressTable
                        (progressID,userID,moduleID,currentStreak,completionPercentage,lastActiveAt)
                    VALUES(LEFT(REPLACE(NEWID(),'-',''),10),@uid,@mid,0,@pct,SYSUTCDATETIME())", conn))
            {
                cmd.Parameters.AddWithValue("@mid", moduleId);
                cmd.Parameters.AddWithValue("@uid", studentId);
                cmd.Parameters.AddWithValue("@pct", pct);
                cmd.ExecuteNonQuery();
            }
        }

        private void BindModuleAssessment()
        {
            int total = 0, done = 0;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT COUNT(*) AS Total,
                       SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) AS Done
                FROM dbo.moduleBlockTable mb
                LEFT JOIN dbo.studentBlockProgressTable sbp
                       ON sbp.blockID=mb.blockID AND sbp.userID=@uid
                WHERE mb.moduleID=@mid
                  AND (mb.blockType IN ('Video','Text','Quiz') OR mb.blockType LIKE 'Flashcard%')", conn))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                cmd.Parameters.AddWithValue("@uid", StudentId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                    if (r.Read())
                    {
                        total = r["Total"] == DBNull.Value ? 0 : Convert.ToInt32(r["Total"]);
                        done = r["Done"] == DBNull.Value ? 0 : Convert.ToInt32(r["Done"]);
                    }
            }
            bool allDone = total > 0 && done >= total;

            const string sql = @"
                SELECT TOP 1
                    a.assessmentID,
                    a.title,
                    ISNULL(a.timeLimitMinutes, 0)  AS timeLimitMinutes,
                    ISNULL(a.totalMarks,       0)  AS totalMarks,
                    ISNULL(a.passingScore,     0)  AS passingScore,
                    (SELECT COUNT(*) FROM dbo.questionTable q
                     WHERE  q.assessmentID = a.assessmentID) AS questionCount,
                    CAST(CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.assessmentAttemptTable aa
                        WHERE  aa.assessmentID = a.assessmentID AND aa.userID = @uid
                    ) THEN 1 ELSE 0 END AS BIT)              AS HasAttempted,
                    ISNULL((
                        SELECT MAX(aa2.score)
                        FROM   dbo.assessmentAttemptTable aa2
                        WHERE  aa2.assessmentID = a.assessmentID AND aa2.userID = @uid
                    ), 0)                                     AS BestScore
                FROM  dbo.assessmentTable a
                WHERE a.moduleID    = @mid
                  AND a.isPublished = 1
                ORDER BY a.createdAt DESC";

            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@mid", ModuleId);
                    cmd.Parameters.AddWithValue("@uid", StudentId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            pnlAssessmentSection.Visible = false;
                            return;
                        }

                        string assessmentId = r["assessmentID"].ToString();

                        pnlAssessmentSection.Visible = true;
                        litAssessmentTitle.Text = HttpUtility.HtmlEncode(r["title"].ToString());
                        litAssessmentQuestions.Text = r["questionCount"].ToString();
                        litAssessmentMarks.Text = r["totalMarks"].ToString();
                        hdnAssessmentId.Value = assessmentId;
                        hdnAssessmentTime.Value = r["timeLimitMinutes"].ToString();

                        int tl = Convert.ToInt32(r["timeLimitMinutes"]);
                        litAssessmentTime.Text = tl > 0 ? tl + " min" : "No limit";

                        pnlAssessmentLocked.Visible = !allDone;
                        pnlAssessmentUnlocked.Visible = allDone;

                        if (allDone)
                        {
                            bool ha = Convert.ToBoolean(r["HasAttempted"]);
                            pnlAssessmentAttempted.Visible = ha;
                            pnlAssessmentNotAttempted.Visible = !ha;

                            if (ha)
                                litAssessmentBestScore.Text =
                                    r["BestScore"] + " / " + r["totalMarks"];

                            r.Close();
                            SetAssessmentLinks(assessmentId);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowActionError("Assessment details couldn't be loaded right now. You can still continue with the lesson blocks.");
                System.Diagnostics.Debug.WriteLine("[moduleContent] BindModuleAssessment error: " + ex);
                pnlAssessmentSection.Visible = false;
            }
        }

        private void SetAssessmentLinks(string assessmentId)
        {
            string url = $"~/studentAssessment.aspx?assessmentId={assessmentId}&moduleId={ModuleId}";
            if (lnkStartAssessment != null) lnkStartAssessment.NavigateUrl = url;
            if (lnkRetryAssessment != null) lnkRetryAssessment.NavigateUrl = url;
        }

        private static void ConvertToBool(DataTable dt, string col)
        {
            if (!dt.Columns.Contains(col)) return;
            string tmp = col + "_b";
            dt.Columns.Add(tmp, typeof(bool));
            foreach (DataRow row in dt.Rows)
            {
                object v = row[col];
                row[tmp] = (v == DBNull.Value || v == null) ? false
                         : v is bool bv ? bv
                         : Convert.ToInt32(v) != 0;
            }
            dt.Columns.Remove(col);
            dt.Columns[tmp].ColumnName = col;
        }
    }
}











