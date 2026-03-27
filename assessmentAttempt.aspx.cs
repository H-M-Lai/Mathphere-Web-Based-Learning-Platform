using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;

namespace MathSphere
{
    public partial class assessmentAttempt : Page
    {
        private readonly string CS =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private string _currentAttemptId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadAssessment();
            else if (hdnFinish.Value == "1")
                FinishAttempt();
        }

        // Load assessment
        private void LoadAssessment()
        {
            string assessmentId = (Request.QueryString["assessmentId"] ?? "").Trim();
            string moduleId = (Request.QueryString["moduleId"] ?? "").Trim();
            string userId = Session["UserID"]?.ToString()?.Trim();

            if (string.IsNullOrEmpty(assessmentId) || string.IsNullOrEmpty(userId))
            { ShowError("Assessment not found or session expired."); return; }

            using (var conn = new SqlConnection(CS))
            {
                conn.Open();

                string title = null;
                int timeLimitMinutes = 0, totalMarks = 0;

                using (var cmd = new SqlCommand(@"
                    SELECT title,
                           ISNULL(timeLimitMinutes, 0) AS timeLimitMinutes,
                           ISNULL(totalMarks, 0)       AS totalMarks,
                           ISNULL(passingScore, 0)     AS passingScore
                    FROM   dbo.assessmentTable
                    WHERE  assessmentID = @aid AND isPublished = 1", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) { ShowError("This assessment is not available."); return; }
                        title = r["title"].ToString();
                        timeLimitMinutes = Convert.ToInt32(r["timeLimitMinutes"]);
                        totalMarks = Convert.ToInt32(r["totalMarks"]);
                        ViewState["PassingScore"] = Convert.ToInt32(r["passingScore"]);
                    }
                }

                var questions = new DataTable();
                using (var cmd = new SqlCommand(@"
                    SELECT questionID, questionNumber, questionText,
                           ISNULL(points,1) AS points, questionType
                    FROM   dbo.questionTable
                    WHERE  assessmentID = @aid ORDER BY questionNumber", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    new SqlDataAdapter(cmd).Fill(questions);
                }

                if (questions.Rows.Count == 0)
                { ShowError("This assessment has no questions yet."); return; }

                hdnAssessmentId.Value = assessmentId;
                hdnModuleId.Value = moduleId;
                hdnTimeLimit.Value = timeLimitMinutes.ToString();
                hdnFinish.Value = "0";

                litAttemptTitle.Text = System.Web.HttpUtility.HtmlEncode(title);
                litAttemptQCount.Text = questions.Rows.Count.ToString();
                litAttemptTotalMarks.Text = totalMarks.ToString();
                pnlNoTimer.Visible = timeLimitMinutes <= 0;

                rptAttemptQuestions.DataSource = questions;
                rptAttemptQuestions.DataBind();
                pnlAttempt.Visible = true;
            }
        }

        protected void rptAttemptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row = (DataRowView)e.Item.DataItem;
            var rptOpts = (Repeater)e.Item.FindControl("rptOptions");
            var litBadge = (Literal)e.Item.FindControl("litQDiffBadge");

            string qid = row["questionID"].ToString();
            int points = Convert.ToInt32(row["points"]);

            if (litBadge != null)
            {
                string diff = points <= 5 ? "Easy" : points <= 10 ? "Medium" : "Hard";
                string cls = diff == "Easy" ? "bg-math-green/10 text-math-green"
                            : diff == "Medium" ? "bg-math-blue/10 text-math-blue"
                                               : "bg-primary/10 text-primary";
                litBadge.Text = $@"<span class=""text-[10px] font-black uppercase tracking-widest {cls} px-2 py-0.5 rounded-full"">{diff}</span>";
            }

            var opts = new DataTable();
            using (var conn = new SqlConnection(CS))
            using (var cmd = new SqlCommand(@"
                SELECT optionID, optionLabel, optionText, @qid AS questionID
                FROM   dbo.questionOptionTable
                WHERE  questionID = @qid ORDER BY optionLabel", conn))
            {
                cmd.Parameters.AddWithValue("@qid", qid);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(opts);
            }
            rptOpts.DataSource = opts;
            rptOpts.DataBind();
        }

        // Finish attempt
        private void FinishAttempt()
        {
            string assessmentId = hdnAssessmentId.Value.Trim();
            string moduleId = hdnModuleId.Value.Trim();
            string userId = Session["UserID"]?.ToString()?.Trim();

            if (string.IsNullOrEmpty(assessmentId) || string.IsNullOrEmpty(userId)) return;

            using (var conn = new SqlConnection(CS))
            {
                conn.Open();

                // Load questions and correct options
                var questions = new DataTable();
                using (var cmd = new SqlCommand(@"
                    SELECT q.questionID, q.questionNumber,
                           ISNULL(q.points,1) AS points,
                           o.optionID, o.isCorrect
                    FROM   dbo.questionTable q
                    JOIN   dbo.questionOptionTable o ON o.questionID = q.questionID
                    WHERE  q.assessmentID = @aid", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    new SqlDataAdapter(cmd).Fill(questions);
                }

                var questionMeta = new Dictionary<string, (int points, HashSet<string> correctIds)>();
                foreach (DataRow r in questions.Rows)
                {
                    string qid = r["questionID"].ToString();
                    int pts = Convert.ToInt32(r["points"]);
                    string optId = r["optionID"].ToString();
                    bool isCorr = Convert.ToBoolean(r["isCorrect"]);

                    if (!questionMeta.ContainsKey(qid))
                        questionMeta[qid] = (pts, new HashSet<string>());
                    if (isCorr)
                        questionMeta[qid].correctIds.Add(optId);
                }

                int totalScore = 0, totalMarks = 0;
                var studentAnswers = new Dictionary<string, string>();

                foreach (string qid in questionMeta.Keys)
                {
                    string selected = Request.Form["question_" + qid] ?? "";
                    studentAnswers[qid] = selected;
                    totalMarks += questionMeta[qid].points;
                    if (!string.IsNullOrEmpty(selected) &&
                        questionMeta[qid].correctIds.Contains(selected))
                        totalScore += questionMeta[qid].points;
                }

                decimal pct = totalMarks > 0
                    ? Math.Round((decimal)totalScore / totalMarks * 100, 2) : 0;

                // Insert attempt row
                // assessmentAttemptTable: attemptID, assessmentID, userID, score, totalMarks, percentage, attemptDate
                string attemptId = GenerateAttemptId(conn);
                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.assessmentAttemptTable
                        (attemptID, assessmentID, userID, score, totalMarks, percentage, attemptDate)
                    VALUES
                        (@id, @aid, @uid, @score, @total, @pct, SYSUTCDATETIME())", conn))
                {
                    cmd.Parameters.AddWithValue("@id", attemptId);
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@score", totalScore);
                    cmd.Parameters.AddWithValue("@total", totalMarks);
                    cmd.Parameters.AddWithValue("@pct", pct);
                    cmd.ExecuteNonQuery();
                }

                // Insert student answers
                // studentAnswerTable columns: answerID, attemptID, userID, questionID, selectedOption, answerText, isCorrect, pointsAwarded, answeredAt
                foreach (var kvp in studentAnswers)
                {
                    string qid = kvp.Key;
                    string selOptId = kvp.Value;
                    bool correct = !string.IsNullOrEmpty(selOptId) &&
                                      questionMeta[qid].correctIds.Contains(selOptId);
                    int pts = correct ? questionMeta[qid].points : 0;
                    string answerId = GenerateAnswerId(conn);

                    using (var cmd = new SqlCommand(@"
                        INSERT INTO dbo.studentAnswerTable
                            (answerID, attemptID, userID, questionID,
                             selectedOption, answerText, isCorrect, pointsAwarded, answeredAt)
                        VALUES
                            (@ansId, @attId, @uid, @qid,
                             @sel, NULL, @correct, @pts, SYSUTCDATETIME())", conn))
                    {
                        cmd.Parameters.AddWithValue("@ansId", answerId);
                        cmd.Parameters.AddWithValue("@attId", attemptId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@qid", qid);
                        // selectedOption stores the chosen optionID for this (radio-button) flow
                        cmd.Parameters.AddWithValue("@sel",
                            string.IsNullOrEmpty(selOptId) ? (object)DBNull.Value : selOptId);
                        cmd.Parameters.AddWithValue("@correct", correct);
                        cmd.Parameters.AddWithValue("@pts", pts);
                        cmd.ExecuteNonQuery();
                    }
                }

                _currentAttemptId = attemptId;

                litScoreDisplay.Text = $"{totalScore}/{totalMarks}";
                litPercentDisplay.Text = pct.ToString("0");
                litAttemptDate.Text = DateTime.Now.ToString("dd MMM yyyy, hh:mm tt");

                var lnkBack = (System.Web.UI.HtmlControls.HtmlAnchor)FindControl("lnkBackAfterAttempt");
                if (lnkBack != null)
                    lnkBack.HRef = string.IsNullOrEmpty(moduleId)
                        ? "StudentDashboard.aspx"
                        : $"moduleContent.aspx?moduleId={moduleId}";

                pnlAttempt.Visible = false;
                pnlResults.Visible = true;
                LoadAnswerKey(assessmentId, attemptId, conn);
            }
        }

        // Answer key
        private void LoadAnswerKey(string assessmentId, string attemptId, SqlConnection conn)
        {
            var questions = new DataTable();
            using (var cmd = new SqlCommand(@"
                SELECT questionID, questionNumber, questionText, ISNULL(points,1) AS points
                FROM   dbo.questionTable
                WHERE  assessmentID = @aid ORDER BY questionNumber", conn))
            {
                cmd.Parameters.AddWithValue("@aid", assessmentId);
                new SqlDataAdapter(cmd).Fill(questions);
            }

            // selectedOption here stores optionID (radio button flow)
            var studentSelections = new Dictionary<string, string>();
            if (!string.IsNullOrEmpty(attemptId))
            {
                using (var cmd = new SqlCommand(@"
                    SELECT questionID, ISNULL(selectedOption,'') AS selectedOption
                    FROM   dbo.studentAnswerTable WHERE attemptID=@attId", conn))
                {
                    cmd.Parameters.AddWithValue("@attId", attemptId);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                            studentSelections[r["questionID"].ToString()] =
                                r["selectedOption"].ToString();
                }
            }

            ViewState["StudentSelections"] = studentSelections;
            rptAnswerKey.DataSource = questions;
            rptAnswerKey.DataBind();
        }

        protected void rptAnswerKey_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row = (DataRowView)e.Item.DataItem;
            var rptOpts = (Repeater)e.Item.FindControl("rptAKOptions");
            var litBadge = (Literal)e.Item.FindControl("litAKDiffBadge");
            var litResultBadge = (Literal)e.Item.FindControl("litResultBadge");

            string qid = row["questionID"].ToString();
            int points = Convert.ToInt32(row["points"]);

            var selections = ViewState["StudentSelections"] as Dictionary<string, string>
                                ?? new Dictionary<string, string>();
            string selectedId = selections.ContainsKey(qid) ? selections[qid] : "";

            if (litBadge != null)
            {
                string diff = points <= 5 ? "Easy" : points <= 10 ? "Medium" : "Hard";
                string cls = diff == "Easy" ? "bg-math-green/10 text-math-green"
                            : diff == "Medium" ? "bg-math-blue/10 text-math-blue"
                                               : "bg-primary/10 text-primary";
                litBadge.Text = $@"<span class=""text-[10px] font-black uppercase {cls} px-2 py-0.5 rounded-full"">{diff}</span>";
            }

            var opts = new DataTable();
            using (var conn = new SqlConnection(CS))
            using (var cmd = new SqlCommand(@"
                SELECT optionID, optionLabel, optionText, CAST(isCorrect AS BIT) AS IsCorrect
                FROM   dbo.questionOptionTable
                WHERE  questionID = @qid ORDER BY optionLabel", conn))
            {
                cmd.Parameters.AddWithValue("@qid", qid);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(opts);
            }

            opts.Columns.Add("IsSelected", typeof(bool));
            bool gotCorrect = false;
            foreach (DataRow r in opts.Rows)
            {
                bool sel = r["optionID"].ToString() == selectedId;
                r["IsSelected"] = sel;
                if (sel && Convert.ToBoolean(r["IsCorrect"])) gotCorrect = true;
            }

            if (litResultBadge != null)
            {
                if (string.IsNullOrEmpty(selectedId))
                    litResultBadge.Text = @"<span class=""text-[10px] font-black uppercase tracking-widest bg-gray-100 text-gray-400 px-2 py-0.5 rounded-full"">Not Answered</span>";
                else if (gotCorrect)
                    litResultBadge.Text = @"<span class=""text-[10px] font-black uppercase tracking-widest bg-math-green/10 text-math-green px-2 py-0.5 rounded-full"">Correct</span>";
                else
                    litResultBadge.Text = @"<span class=""text-[10px] font-black uppercase tracking-widest bg-red-50 text-red-400 px-2 py-0.5 rounded-full"">Wrong</span>";
            }

            rptOpts.DataSource = opts;
            rptOpts.DataBind();
        }

        protected string GetOptionClass(bool isCorrect, bool isSelected)
        {
            if (isCorrect) return "flex items-center gap-2 p-3 rounded-xl border-2 border-math-green/40 bg-math-green/10";
            if (isSelected) return "flex items-center gap-2 p-3 rounded-xl border-2 border-red-200 bg-red-50";
            return "flex items-center gap-2 p-3 rounded-xl border border-gray-100 bg-gray-50/50";
        }

        protected string GetOptionLabelClass(bool isCorrect, bool isSelected)
        {
            if (isCorrect) return "shrink-0 size-7 rounded-lg border-2 border-math-green bg-math-green/20 flex items-center justify-center font-black text-xs text-math-green";
            if (isSelected) return "shrink-0 size-7 rounded-lg border-2 border-red-300 bg-red-100 flex items-center justify-center font-black text-xs text-red-400";
            return "shrink-0 size-7 rounded-lg border border-gray-200 bg-white flex items-center justify-center font-black text-xs text-gray-400";
        }

        protected string GetOptionTextClass(bool isCorrect, bool isSelected)
        {
            if (isCorrect) return "text-xs font-bold text-math-green flex-1";
            if (isSelected) return "text-xs font-bold text-red-400 flex-1";
            return "text-xs font-semibold text-gray-500 flex-1";
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            pnlAttempt.Visible = false;
            litError.Text = System.Web.HttpUtility.HtmlEncode(msg);
        }

        private string GenerateAttemptId(SqlConnection conn)
        {
            const string sql = @"
                SELECT ISNULL(MAX(CAST(SUBSTRING(attemptID,3,LEN(attemptID)) AS INT)),0)+1
                FROM   dbo.assessmentAttemptTable
                WHERE  attemptID LIKE 'AT%'
                  AND  ISNUMERIC(SUBSTRING(attemptID,3,LEN(attemptID)))=1";
            using (var cmd = new SqlCommand(sql, conn))
                return "AT" + Convert.ToInt32(cmd.ExecuteScalar()).ToString("D3");
        }

        private string GenerateAnswerId(SqlConnection conn)
        {
            const string sql = @"
                SELECT ISNULL(MAX(CAST(SUBSTRING(answerID,3,LEN(answerID)) AS INT)),0)+1
                FROM   dbo.studentAnswerTable
                WHERE  answerID LIKE 'SA%'
                  AND  ISNUMERIC(SUBSTRING(answerID,3,LEN(answerID)))=1";
            using (var cmd = new SqlCommand(sql, conn))
                return "SA" + Convert.ToInt32(cmd.ExecuteScalar()).ToString("D3");
        }
    }
}

