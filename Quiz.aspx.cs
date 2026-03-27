using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class Quiz : Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private bool IsGuest =>
            Session["IsGuest"] is bool b && b &&
            string.IsNullOrWhiteSpace(
                (Session["UserID"] ?? Session["userID"])?.ToString());

        private string UserId =>
            ((Session["UserID"] ?? Session["userID"]) as string)?.Trim() ?? "";

        // Answer DTO from JS
        private class AnswerDto
        {
            [JsonProperty("questionId")] public string QuestionId { get; set; }
            [JsonProperty("optionId")] public string OptionId { get; set; }
            [JsonProperty("correct")] public bool Correct { get; set; }
            [JsonProperty("pts")] public int Pts { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsGuest)
            {
                Response.Redirect("~/BrowseModule.aspx", true);
                return;
            }

            if (!IsPostBack)
                LoadQuiz();
            else
            {
                if (Request.Form["hdnFinish"] == "1")
                    SaveQuizAttempt();
            }
        }

        // Load quiz questions
        private void LoadQuiz()
        {
            string quizId = Request.QueryString["quizId"];
            string blockId = Request.QueryString["blockId"];
            string moduleId = Request.QueryString["moduleId"];

            if (string.IsNullOrWhiteSpace(quizId) && string.IsNullOrWhiteSpace(blockId))
            {
                ShowError("No quiz ID was supplied. Please return to the module and try again.");
                return;
            }

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Resolve quizId from blockId if needed
                if (string.IsNullOrWhiteSpace(quizId) && !string.IsNullOrWhiteSpace(blockId))
                {
                    using (var cmd = new SqlCommand(
                        "SELECT quizID FROM dbo.blockContentTable WHERE blockID = @bid", conn))
                    {
                        cmd.Parameters.AddWithValue("@bid", blockId);
                        var result = cmd.ExecuteScalar();
                        if (result == null || result == DBNull.Value)
                        {
                            ShowError("No quiz linked to this block.");
                            return;
                        }
                        quizId = result.ToString().Trim();
                    }
                }

                // Load quiz title
                string title;
                using (var cmd = new SqlCommand(
                    "SELECT quizTitle FROM dbo.quizTable WHERE quizID = @qid", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", quizId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read()) { ShowError($"Quiz '{quizId}' not found."); return; }
                        title = rdr["quizTitle"].ToString();
                    }
                }

                // Load questions
                var questions = new DataTable();
                using (var cmd = new SqlCommand(@"
                    SELECT questionID   AS QuestionID,
                           questionText AS QuestionText,
                           orderIndex   AS QuestionNumber,
                           points       AS Points,
                           hint         AS Hint
                    FROM   dbo.quizQuestionTable
                    WHERE  quizID = @qid
                    ORDER BY orderIndex", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", quizId);
                    using (var da = new SqlDataAdapter(cmd))
                        da.Fill(questions);
                }

                if (questions.Rows.Count == 0)
                {
                    ShowError("This quiz has no questions yet.");
                    return;
                }

                litQuizTitle.Text = System.Web.HttpUtility.HtmlEncode(title);
                litTotal.Text = questions.Rows.Count.ToString();
                litTotalHidden.Value = questions.Rows.Count.ToString();
                litQuizId.Value = quizId;
                litModuleId.Value = moduleId ?? "";

                lnkRetry.NavigateUrl = Request.RawUrl;
                lnkBackToModule.NavigateUrl = !string.IsNullOrWhiteSpace(moduleId)
                    ? $"moduleContent.aspx?moduleId={moduleId}"
                    : "StudentDashboard.aspx";

                rptQuestions.DataSource = questions;
                rptQuestions.DataBind();

                pnlQuiz.Visible = true;
                pnlError.Visible = false;
                pnlResults.Visible = false;
            }
        }

        // Repeater item data-bind
        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row = (DataRowView)e.Item.DataItem;
            var rptOpts = e.Item.FindControl("rptOptions") as Repeater;
            if (rptOpts == null) return;

            string questionId = row["QuestionID"].ToString();
            string quizId = litQuizId.Value;

            var options = new DataTable();
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"
                    SELECT optionID    AS OptionID,
                           optionLabel AS OptionLabel,
                           optionText  AS OptionText,
                           CAST(isCorrect AS BIT) AS IsCorrect
                    FROM   dbo.quizOptionTable
                    WHERE  questionID = @qid AND quizID = @quiz
                    ORDER BY optionLabel", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", questionId);
                    cmd.Parameters.AddWithValue("@quiz", quizId);
                    using (var da = new SqlDataAdapter(cmd))
                        da.Fill(options);
                }
            }

            rptOpts.DataSource = options;
            rptOpts.DataBind();
        }

        // Save quiz attempt
        private void SaveQuizAttempt()
        {
            if (IsGuest) return;

            string quizId = (litQuizId.Value ?? "").Trim();
            string moduleId = (litModuleId.Value ?? "").Trim();
            string userId = UserId;
            string answersJson = Request.Form["hdnSubmitAnswers"];
            int earnedPts = int.TryParse(Request.Form["hdnEarnedPts"], out int ep) ? ep : 0;

            if (string.IsNullOrWhiteSpace(userId))
            {
                ShowError("Your session has expired. Please log in again.");
                return;
            }
            if (string.IsNullOrWhiteSpace(quizId))
            {
                ShowError("Quiz ID is missing. Please reopen the quiz from the module page.");
                return;
            }

            var answers = new List<AnswerDto>();
            if (!string.IsNullOrWhiteSpace(answersJson))
            {
                try { answers = JsonConvert.DeserializeObject<List<AnswerDto>>(answersJson) ?? new List<AnswerDto>(); }
                catch { ShowError("Could not read submitted answers. Please try the quiz again."); return; }
            }

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Build a lookup: quizQuestionTable.questionID ? questionTable.questionID
                // The FK_answer_question constraint on studentAnswerTable.questionID references
                // dbo.questionTable.questionID — NOT dbo.quizQuestionTable.questionID.
                // quizQuestionTable has a sourceQuestionID (or similar) column that joins to
                // questionTable.  We load that mapping once before the transaction.
                var questionIdMap = BuildQuestionIdMap(conn, quizId);

                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Insert QuizAttempt
                        string quizAttemptId = GenerateQuizAttemptId(conn, tx);

                        using (var cmd = new SqlCommand(@"
                            INSERT INTO dbo.QuizAttempt
                                (quizAttemptID, quizID, userID, score, attemptedAt)
                            VALUES
                                (@id, @qid, @uid, @score, SYSUTCDATETIME())", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", quizAttemptId);
                            cmd.Parameters.AddWithValue("@qid", quizId);
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.Parameters.AddWithValue("@score", earnedPts);
                            cmd.ExecuteNonQuery();
                        }

                        // 2. Insert individual answers
                        foreach (var ans in answers)
                        {
                            if (string.IsNullOrWhiteSpace(ans.QuestionId)) continue;

                            // KEY FIX
                            // Resolve the FK-safe questionID from questionTable.
                            // If the quiz question ID is already a valid questionTable ID, the
                            // map returns it unchanged.  If there's a separate sourceQuestionID
                            // column, the map returns that instead.
                            string fkQuestionId = ResolveQuestionTableId(
                                conn, tx, ans.QuestionId.Trim(), questionIdMap);

                            if (string.IsNullOrWhiteSpace(fkQuestionId))
                            {
                                // Skip answers whose question can't be resolved rather than
                                // blowing up the whole attempt.
                                System.Diagnostics.Debug.WriteLine(
                                    $"[Quiz] Skipping answer – cannot resolve questionID '{ans.QuestionId}'");
                                continue;
                            }
                            // -
                            string answerId = GenerateAnswerId(conn, tx);

                            using (var cmd = new SqlCommand(@"
                                INSERT INTO dbo.studentAnswerTable
                                    (answerID, attemptID, userID, questionID,
                                     selectedOption, answerText, isCorrect, pointsAwarded, answeredAt)
                                VALUES
                                    (@aid, @atid, @uid, @qid,
                                     @opt, NULL, @correct, @pts, SYSUTCDATETIME())", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@aid", answerId);
                                cmd.Parameters.AddWithValue("@atid", quizAttemptId);
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@qid", fkQuestionId);
                                cmd.Parameters.AddWithValue("@opt",
                                    string.IsNullOrWhiteSpace(ans.OptionId)
                                        ? (object)DBNull.Value : ans.OptionId.Trim());
                                cmd.Parameters.AddWithValue("@correct", ans.Correct);
                                cmd.Parameters.AddWithValue("@pts", ans.Pts);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tx.Commit();
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        ShowError("Error saving quiz attempt: " + ex.Message);
                        return;
                    }
                }

                // 3. Award XP (first attempt only)
                bool isFirstAttempt;
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(1) FROM dbo.QuizAttempt WHERE quizID=@qid AND userID=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", quizId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    isFirstAttempt = Convert.ToInt32(cmd.ExecuteScalar()) == 1;
                }

                if (isFirstAttempt)
                {
                    int totalMarks = 0;
                    using (var cmd = new SqlCommand(
                        "SELECT COALESCE(SUM(points),0) FROM dbo.quizQuestionTable WHERE quizID=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        totalMarks = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    int pct = totalMarks > 0
                        ? (int)Math.Round((double)earnedPts / totalMarks * 100.0) : 0;

                    int quizXp = SystemSettingsHelper.GetInt("QuizPerfectScore", 10);
                    if (quizXp > 0 && !string.IsNullOrEmpty(moduleId))
                    {
                        string src = ("QZ" + quizId).Length > 10
                            ? ("QZ" + quizId).Substring(0, 10) : "QZ" + quizId;
                        AwardXpOnce(conn, userId, moduleId, "QuizComplete", src, quizXp);
                    }

                    if (pct == 100)
                    {
                        int perfectBonus = SystemSettingsHelper.GetInt("QuizPerfectScore", 50);
                        if (perfectBonus > 0 && !string.IsNullOrEmpty(moduleId))
                        {
                            string src = ("QP" + quizId).Length > 10
                                ? ("QP" + quizId).Substring(0, 10) : "QP" + quizId;
                            AwardXpOnce(conn, userId, moduleId, "QuizPerfect", src, perfectBonus);
                        }
                    }
                }

                // 4. Mark block completed + module completion
                if (!string.IsNullOrEmpty(moduleId))
                {
                    string blockId = "";
                    using (var cmd = new SqlCommand(
                        "SELECT TOP 1 blockID FROM dbo.quizTable WHERE quizID=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        blockId = cmd.ExecuteScalar()?.ToString()?.Trim() ?? "";
                    }
                    if (!string.IsNullOrEmpty(blockId))
                        MarkBlockCompleted(conn, userId, blockId);

                    UpdateModuleCompletion(conn, userId, moduleId);
                }

                // 5. Update streak
                UpdateStreak(conn, userId, moduleId);

                ShowResults(quizId, earnedPts, moduleId, conn, answers);
            }
        }

        // -
        //  Build a map: quizQuestionTable.questionID ? questionTable.questionID
        //
        //  Strategy (tries columns in order of likelihood):
        //    a) quizQuestionTable has a sourceQuestionID column ? use that
        //    b) quizQuestionTable.questionID already exists in questionTable ? identity map
        //    c) questionTable has no matching row ? returns null (answer skipped)
        // -
        private Dictionary<string, string> BuildQuestionIdMap(
            SqlConnection conn, string quizId)
        {
            var map = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

            // Check whether quizQuestionTable has a 'sourceQuestionID' column
            bool hasSourceCol = ColumnExists(conn, "quizQuestionTable", "sourceQuestionID");

            if (hasSourceCol)
            {
                // Use the explicit link column
                using (var cmd = new SqlCommand(@"
                    SELECT questionID, sourceQuestionID
                    FROM   dbo.quizQuestionTable
                    WHERE  quizID = @qid
                      AND  sourceQuestionID IS NOT NULL", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", quizId);
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read())
                            map[rdr["questionID"].ToString()] =
                                rdr["sourceQuestionID"].ToString();
                }
            }

            // For any unmapped IDs (or if no sourceCol), check if the ID itself
            // exists directly in questionTable (identity mapping)
            using (var cmd = new SqlCommand(@"
                SELECT qq.questionID
                FROM   dbo.quizQuestionTable qq
                WHERE  qq.quizID = @qid
                  AND  EXISTS (SELECT 1 FROM dbo.questionTable q
                               WHERE q.questionID = qq.questionID)", conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                    {
                        string id = rdr["questionID"].ToString();
                        if (!map.ContainsKey(id))
                            map[id] = id;   // identity — same ID is valid in questionTable
                    }
            }

            return map;
        }

        // Resolve quizQuestion ID ? questionTable ID using the pre-built map,
        // falling back to a direct DB check if the map didn't cover it.
        private string ResolveQuestionTableId(
            SqlConnection conn, SqlTransaction tx,
            string quizQuestionId,
            Dictionary<string, string> map)
        {
            if (map.TryGetValue(quizQuestionId, out string resolved))
                return resolved;

            // Last-resort: check if the ID exists directly in questionTable
            using (var cmd = new SqlCommand(
                "SELECT COUNT(1) FROM dbo.questionTable WHERE questionID = @qid",
                conn, tx))
            {
                cmd.Parameters.AddWithValue("@qid", quizQuestionId);
                if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                    return quizQuestionId;
            }

            return null;  // unresolvable — caller will skip this answer
        }

        // Helper: check if a column exists in a table
        private bool ColumnExists(SqlConnection conn, string table, string column)
        {
            using (var cmd = new SqlCommand(@"
                SELECT COUNT(1)
                FROM   INFORMATION_SCHEMA.COLUMNS
                WHERE  TABLE_NAME   = @t
                  AND  COLUMN_NAME  = @c", conn))
            {
                cmd.Parameters.AddWithValue("@t", table);
                cmd.Parameters.AddWithValue("@c", column);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        // Streak update
        private void UpdateStreak(SqlConnection conn, string userId, string moduleId)
        {
            int newStreak = 0;
            try
            {
                using (var cmd = new SqlCommand(@"
                    DECLARE @today DATE = CAST(SYSUTCDATETIME() AS DATE);
                    IF EXISTS (SELECT 1 FROM dbo.StudentStreak WHERE userID = @uid)
                    BEGIN
                        DECLARE @last DATE, @cur INT, @best INT;
                        SELECT @last=lastActivityDate, @cur=currentStreak, @best=bestStreak
                        FROM   dbo.StudentStreak WHERE userID=@uid;
                        IF @last=@today BEGIN SELECT currentStreak FROM dbo.StudentStreak WHERE userID=@uid; RETURN; END
                        DECLARE @newStreak INT = CASE WHEN @last=DATEADD(DAY,-1,@today) THEN @cur+1 ELSE 1 END;
                        UPDATE dbo.StudentStreak
                        SET currentStreak=@newStreak,
                            bestStreak=CASE WHEN @newStreak>@best THEN @newStreak ELSE @best END,
                            lastActivityDate=@today, updatedAt=SYSUTCDATETIME()
                        WHERE userID=@uid;
                        SELECT @newStreak;
                    END
                    ELSE
                    BEGIN
                        INSERT INTO dbo.StudentStreak(streakID,userID,currentStreak,bestStreak,lastActivityDate,updatedAt)
                        VALUES(LEFT(REPLACE(NEWID(),'-',''),10),@uid,1,1,@today,SYSUTCDATETIME());
                        SELECT 1;
                    END", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    var result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        newStreak = Convert.ToInt32(result);
                }

                if (newStreak > 0 && newStreak % 7 == 0)
                {
                    int bonus = SystemSettingsHelper.GetInt("StreakBonus7Day", 100);
                    if (bonus > 0)
                    {
                        string src = ("SK" + newStreak).Length > 10
                            ? ("SK" + newStreak).Substring(0, 10) : "SK" + newStreak;
                        AwardXpOnce(conn, userId, moduleId ?? "", "StreakBonus", src, bonus);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Quiz.UpdateStreak] " + ex.Message);
            }
        }

        // Mark block completed
        private void MarkBlockCompleted(SqlConnection conn, string userId, string blockId)
        {
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
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.ExecuteNonQuery();
            }
        }

        // Update module completion
        private void UpdateModuleCompletion(SqlConnection conn, string userId, string moduleId)
        {
            int total = 0, done = 0;
            using (var cmd = new SqlCommand(@"
                SELECT COUNT(*) AS Total,
                       SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) AS Done
                FROM   dbo.moduleBlockTable mb
                LEFT JOIN dbo.studentBlockProgressTable sbp
                       ON sbp.blockID=mb.blockID AND sbp.userID=@uid
                WHERE  mb.moduleID=@mid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
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
                IF EXISTS(SELECT 1 FROM dbo.studentModuleCompletionTable WHERE moduleID=@mid AND userID=@uid)
                    UPDATE dbo.studentModuleCompletionTable
                    SET completionPercentage=@pct,
                        completionDate=CASE WHEN @pct>=100 AND completionDate IS NULL THEN SYSUTCDATETIME() ELSE completionDate END
                    WHERE moduleID=@mid AND userID=@uid
                ELSE
                    INSERT INTO dbo.studentModuleCompletionTable
                        (completionID,userID,moduleID,completionDate,completionPercentage)
                    VALUES(LEFT(REPLACE(NEWID(),'-',''),20),@uid,@mid,
                           CASE WHEN @pct>=100 THEN SYSUTCDATETIME() ELSE NULL END,@pct)", conn))
            {
                cmd.Parameters.AddWithValue("@mid", moduleId);
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@pct", pct);
                cmd.ExecuteNonQuery();
            }
        }

        // XP helper
        private void AwardXpOnce(SqlConnection conn, string userId,
                                  string moduleId, string sourceType,
                                  string sourceId, int points)
        {
            if (points <= 0) return;
            string safeMid = (moduleId ?? "").Length > 10
                ? moduleId.Substring(0, 10) : (moduleId ?? "");

            using (var cmd = new SqlCommand(@"
                IF NOT EXISTS (SELECT 1 FROM dbo.studentScoreEventTable
                               WHERE userID=@uid AND sourceType=@stype AND sourceID=@sid)
                BEGIN
                    DECLARE @courseId nvarchar(10)=NULL;
                    IF LEN(@mid)>0
                        SELECT TOP 1 @courseId=courseID FROM dbo.moduleTable WHERE moduleID=@mid;
                    DECLARE @n int;
                    SELECT @n=ISNULL(MAX(TRY_CAST(SUBSTRING(LTRIM(RTRIM(eventID)),3,LEN(eventID)) AS int)),0)+1
                    FROM   dbo.studentScoreEventTable WHERE eventID LIKE 'SE[0-9]%';
                    INSERT INTO dbo.studentScoreEventTable
                        (eventID,userID,courseID,moduleID,sourceType,sourceID,points,createdAt)
                    VALUES('SE'+RIGHT('00000000'+CAST(@n AS nvarchar(8)),8),
                           @uid,@courseId,
                           CASE WHEN LEN(@mid)>0 THEN @mid ELSE NULL END,
                           @stype,@sid,@pts,GETDATE())
                END", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@mid", safeMid);
                cmd.Parameters.AddWithValue("@sid", sourceId);
                cmd.Parameters.AddWithValue("@stype", sourceType);
                cmd.Parameters.AddWithValue("@pts", points);
                cmd.ExecuteNonQuery();
            }
        }

        // Results panel
        private void ShowResults(string quizId, int earnedPts,
                                 string moduleId, SqlConnection conn,
                                 List<AnswerDto> answers)
        {
            pnlQuiz.Visible = false;
            pnlResults.Visible = true;
            pnlError.Visible = false;

            int totalMarks = 0;
            using (var cmd = new SqlCommand(
                "SELECT COALESCE(SUM(points),0) FROM dbo.quizQuestionTable WHERE quizID=@qid", conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                totalMarks = Convert.ToInt32(cmd.ExecuteScalar());
            }

            int pct = totalMarks > 0
                ? (int)Math.Round((double)earnedPts / totalMarks * 100.0) : 0;

            double ringOffset = 283.0 * (1.0 - pct / 100.0);
            litScoreOffset.Text = ringOffset.ToString("F1",
                System.Globalization.CultureInfo.InvariantCulture);
            litScorePct.Text = pct.ToString();
            litScoreNum.Text = earnedPts.ToString();
            litMaxScore.Text = totalMarks.ToString();

            int correctCount = 0;
            foreach (var a in answers) if (a.Correct) correctCount++;
            litCorrectCount.Text = correctCount.ToString();
            litTotalCount.Text = answers.Count.ToString();

            bool passed = pct >= 60;
            pnlPass.Visible = passed;
            pnlFail.Visible = !passed;

            lnkRetry.NavigateUrl = Request.RawUrl;
            lnkBackToModule.NavigateUrl = !string.IsNullOrWhiteSpace(moduleId)
                ? $"moduleContent.aspx?moduleId={moduleId}"
                : "StudentDashboard.aspx";

            pnlXpAwarded.Visible = false;

            LoadQuizReview(quizId, answers, conn);
        }

        private void LoadQuizReview(string quizId,
                                     List<AnswerDto> answers, SqlConnection conn)
        {
            var answerMap = new Dictionary<string, AnswerDto>(StringComparer.OrdinalIgnoreCase);
            foreach (var a in answers)
                if (!string.IsNullOrWhiteSpace(a.QuestionId))
                    answerMap[a.QuestionId] = a;

            var questions = new List<ReviewQuestionRow>();

            using (var cmd = new SqlCommand(@"
                SELECT questionID, orderIndex AS QuestionNumber,
                       questionText, points, hint
                FROM   dbo.quizQuestionTable
                WHERE  quizID = @qid
                ORDER BY orderIndex", conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                    {
                        string qid = rdr["questionID"].ToString();
                        bool correct = answerMap.ContainsKey(qid) && answerMap[qid].Correct;
                        questions.Add(new ReviewQuestionRow
                        {
                            QuestionID = qid,
                            QuestionNumber = Convert.ToInt32(rdr["QuestionNumber"]),
                            QuestionText = rdr["questionText"].ToString(),
                            Points = Convert.ToInt32(rdr["points"]),
                            IsCorrect = correct,
                            Hint = rdr["hint"] == DBNull.Value ? null : rdr["hint"].ToString(),
                            SelectedOptId = answerMap.ContainsKey(qid) ? answerMap[qid].OptionId : null
                        });
                    }
            }

            foreach (var q in questions)
            {
                using (var cmd = new SqlCommand(@"
                    SELECT optionID, optionLabel, optionText,
                           CAST(isCorrect AS BIT) AS IsCorrect
                    FROM   dbo.quizOptionTable
                    WHERE  questionID=@qid AND quizID=@quiz
                    ORDER BY optionLabel", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", q.QuestionID);
                    cmd.Parameters.AddWithValue("@quiz", quizId);
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read())
                            q.Options.Add(new ReviewOptionRow
                            {
                                OptionLabel = rdr["optionLabel"].ToString(),
                                OptionText = rdr["optionText"].ToString(),
                                IsCorrect = Convert.ToBoolean(rdr["IsCorrect"]),
                                WasSelected = string.Equals(rdr["optionID"].ToString(),
                                    q.SelectedOptId, StringComparison.OrdinalIgnoreCase)
                            });
                }
            }

            pnlQuizReview.Visible = questions.Count > 0;
            rptReview.DataSource = questions;
            rptReview.DataBind();
        }

        protected void rptReview_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var q = (ReviewQuestionRow)e.Item.DataItem;
            var rptOpts = e.Item.FindControl("rptReviewOptions") as Repeater;
            if (rptOpts != null)
            {
                rptOpts.DataSource = q.Options;
                rptOpts.DataBind();
            }
        }

        // Review models
        private class ReviewQuestionRow
        {
            public string QuestionID { get; set; }
            public int QuestionNumber { get; set; }
            public string QuestionText { get; set; }
            public int Points { get; set; }
            public bool IsCorrect { get; set; }
            public string Hint { get; set; }
            public string SelectedOptId { get; set; }
            public List<ReviewOptionRow> Options { get; set; } = new List<ReviewOptionRow>();
        }

        private class ReviewOptionRow
        {
            public string OptionLabel { get; set; }
            public string OptionText { get; set; }
            public bool IsCorrect { get; set; }
            public bool WasSelected { get; set; }
        }

        // Error helper
        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            litError.Text = System.Web.HttpUtility.HtmlEncode(msg);
            pnlQuiz.Visible = false;
            pnlResults.Visible = false;
        }

        // ID generators
        private string GenerateQuizAttemptId(SqlConnection conn, SqlTransaction tx)
        {
            var rng = new Random();
            string id;
            do { id = "QA" + rng.Next(10000000, 99999999); }
            while (QuizAttemptIdExists(conn, tx, id));
            return id;
        }

        private bool QuizAttemptIdExists(SqlConnection conn, SqlTransaction tx, string id)
        {
            using (var cmd = new SqlCommand(
                "SELECT COUNT(1) FROM dbo.QuizAttempt WHERE quizAttemptID=@id", conn, tx))
            {
                cmd.Parameters.AddWithValue("@id", id);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private string GenerateAnswerId(SqlConnection conn, SqlTransaction tx)
        {
            var rng = new Random();
            string id;
            do { id = "SA" + rng.Next(10000000, 99999999); }
            while (AnswerIdExists(conn, tx, id));
            return id;
        }

        private bool AnswerIdExists(SqlConnection conn, SqlTransaction tx, string id)
        {
            using (var cmd = new SqlCommand(
                "SELECT COUNT(1) FROM dbo.studentAnswerTable WHERE answerID=@id", conn, tx))
            {
                cmd.Parameters.AddWithValue("@id", id);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
