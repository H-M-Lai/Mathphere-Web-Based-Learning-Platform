using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class studentAssessment : System.Web.UI.Page
    {
        private readonly string connectionString =
            System.Configuration.ConfigurationManager
                .ConnectionStrings["MathSphereDB"].ConnectionString;

        public string QuestionsJson { get; private set; } = "[]";

        private string CurrentUserId => ((Session["UserID"] ?? Session["userID"]) as string)?.Trim() ?? "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(CurrentUserId))
            { Response.Redirect("~/Login.aspx", true); return; }

            if (!IsPostBack)
            {
                string aid = (Request.QueryString["assessmentId"] ?? "").Trim();
                if (string.IsNullOrEmpty(aid))
                { Response.Redirect("~/StudentDashboard.aspx"); return; }

                hdnAssessmentId.Value = aid;
                if (!LoadAssessmentMeta(aid)) return;
                string attemptId = CreateAttempt(aid);
                hdnAttemptId.Value = attemptId;
                LoadQuestions(aid);
            }
        }

        // Assessment header
        private bool LoadAssessmentMeta(string assessmentId)
        {
            const string sql = @"
                SELECT title, timeLimitMinutes, totalMarks,
                       ISNULL(shuffleQuestions, 0) AS shuffleQuestions
                FROM dbo.assessmentTable WHERE assessmentID = @aid";
            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@aid", assessmentId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { Response.Redirect("~/StudentDashboard.aspx"); return false; }
                    litHeaderTitle.Text = HttpUtility.HtmlEncode(r["title"].ToString());
                    hdnTimeLimit.Value = r["timeLimitMinutes"] == DBNull.Value
                                             ? "60" : r["timeLimitMinutes"].ToString();
                    // Store shuffle flag in ViewState for LoadQuestions to use
                    ViewState["ShuffleQuestions"] =
                        r["shuffleQuestions"] != DBNull.Value &&
                        Convert.ToBoolean(r["shuffleQuestions"]);
                }
            }
            return true;
        }

        // Create attempt
        private string CreateAttempt(string assessmentId)
        {
            string userId = CurrentUserId;
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var resumeCmd = new SqlCommand(@"
                    SELECT TOP 1 aa.attemptID
                    FROM   dbo.assessmentAttemptTable aa
                    WHERE  aa.assessmentID = @aid
                      AND  aa.userID = @uid
                      AND  NOT EXISTS (
                           SELECT 1 FROM dbo.studentAnswerTable sa
                           WHERE sa.attemptID = aa.attemptID
                      )
                    ORDER BY aa.attemptDate DESC", conn))
                {
                    resumeCmd.Parameters.AddWithValue("@aid", assessmentId);
                    resumeCmd.Parameters.AddWithValue("@uid", userId);
                    string existingAttemptId = Convert.ToString(resumeCmd.ExecuteScalar()) ?? "";
                    if (!string.IsNullOrWhiteSpace(existingAttemptId))
                        return existingAttemptId;
                }

                int totalMarks = 0;
                using (var cmd = new SqlCommand(
                    "SELECT ISNULL(totalMarks,0) FROM dbo.assessmentTable WHERE assessmentID=@aid", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    totalMarks = Convert.ToInt32(cmd.ExecuteScalar());
                }

                string attemptId = GenerateAttemptId(conn);

                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.assessmentAttemptTable
                        (attemptID, assessmentID, userID, score, totalMarks, percentage, attemptDate)
                    VALUES
                        (@atid, @aid, @uid, 0, @totalMarks, 0, SYSUTCDATETIME())", conn))
                {
                    cmd.Parameters.AddWithValue("@atid", attemptId);
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@totalMarks", totalMarks);
                    cmd.ExecuteNonQuery();
                }
                return attemptId;
            }
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

        // Load questions + options
        private void LoadQuestions(string assessmentId)
        {
            const string sqlQ = @"
                SELECT questionID, questionNumber, questionText, questionType, correctAnswer, points
                FROM   dbo.questionTable
                WHERE  assessmentID = @aid ORDER BY questionNumber";

            var rows = new DataTable();
            var jsQuestions = new List<object>();

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sqlQ, conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    new SqlDataAdapter(cmd).Fill(rows);
                }

                foreach (DataRow row in rows.Rows)
                {
                    string qid = row["questionID"].ToString();
                    var opts = new List<object>();
                    using (var cmd = new SqlCommand(@"
                        SELECT optionID, optionLabel, optionText, isCorrect
                        FROM   dbo.questionOptionTable
                        WHERE  questionID=@qid ORDER BY optionLabel", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", qid);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                                opts.Add(new
                                {
                                    optionId = r["optionID"].ToString(),
                                    optionLabel = r["optionLabel"].ToString(),
                                    optionText = r["optionText"].ToString(),
                                    isCorrect = Convert.ToBoolean(r["isCorrect"])
                                });
                    }
                    jsQuestions.Add(new
                    {
                        questionId = qid,
                        questionText = row["questionText"].ToString(),
                        questionType = row["questionType"].ToString(),
                        correctAnswer = row["correctAnswer"].ToString(),
                        points = Convert.ToInt32(row["points"]),
                        options = opts
                    });
                }
            }

            // Shuffle if teacher enabled it
            bool shuffle = ViewState["ShuffleQuestions"] as bool? ?? false;
            if (shuffle)
            {
                var rng = new Random();
                // Fisher-Yates on the DataTable rows list
                var rowList = new List<DataRow>();
                foreach (DataRow r in rows.Rows) rowList.Add(r);
                for (int i = rowList.Count - 1; i > 0; i--)
                {
                    int j = rng.Next(i + 1);
                    var tmp = rowList[i]; rowList[i] = rowList[j]; rowList[j] = tmp;
                }

                // Also shuffle the jsQuestions list to match
                var jsList = new List<object>(jsQuestions);
                // Re-build both in the same shuffled order using the row index mapping
                var originalIds = new List<string>();
                foreach (DataRow r in rows.Rows) originalIds.Add(r["questionID"].ToString());

                var shuffledJs = new List<object>();
                var shuffledRows = new List<DataRow>();
                foreach (var r in rowList)
                {
                    int origIdx = originalIds.IndexOf(r["questionID"].ToString());
                    shuffledJs.Add(jsList[origIdx]);
                    shuffledRows.Add(r);
                }
                jsQuestions = shuffledJs;
                // Replace rows content with shuffled order for HTML building below
                rowList = shuffledRows;

                QuestionsJson = new JavaScriptSerializer().Serialize(jsQuestions);
                BuildCards(rowList, shuffle: true);
                return;
            }

            QuestionsJson = new JavaScriptSerializer().Serialize(jsQuestions);

            // Non-shuffled path — use DataTable rows directly
            var orderedRows = new List<DataRow>();
            foreach (DataRow r in rows.Rows) orderedRows.Add(r);
            BuildCards(orderedRows, shuffle: false);
        }

        private void BuildCards(List<DataRow> rows, bool shuffle)
        {
            var cardRows = new DataTable();
            cardRows.Columns.Add("CardHtml");
            int num = 1;

            foreach (DataRow row in rows)
            {
                string qid = row["questionID"].ToString();
                string type = row["questionType"].ToString();
                int pts = Convert.ToInt32(row["points"]);
                string diff = pts <= 5 ? "Easy" : pts <= 10 ? "Medium" : "Hard";
                string diffCls = diff == "Easy" ? "bg-math-green/10 text-math-green"
                               : diff == "Medium" ? "bg-math-blue/10 text-math-blue"
                                                  : "bg-primary/10 text-primary";
                var html = new StringBuilder();
                html.Append($@"
                <div id=""qcard-{HttpUtility.HtmlEncode(qid)}"" data-qid=""{HttpUtility.HtmlEncode(qid)}""
                     class=""bg-white border-2 border-gray-100 rounded-3xl p-8 shadow-sm q-card"">
                    <div class=""flex items-start justify-between gap-4 mb-6"">
                        <div class=""flex items-center gap-3"">
                            <span class=""size-9 rounded-xl bg-math-dark-blue text-white flex items-center justify-center text-sm font-black flex-shrink-0"">{num}</span>
                            <span class=""px-2.5 py-1 {diffCls} text-[9px] font-black rounded-lg uppercase"">{diff}</span>
                            <span class=""text-[10px] font-bold text-gray-400"">{pts} pts</span>
                        </div>
                        <span class=""text-[10px] font-bold text-gray-300 uppercase tracking-widest"">{HttpUtility.HtmlEncode(type)}</span>
                    </div>
                    <p class=""text-base font-bold text-math-dark-blue mb-6 leading-relaxed"">{HttpUtility.HtmlEncode(row["questionText"].ToString())}</p>");

                bool isMcq = type.Equals("MCQ", StringComparison.OrdinalIgnoreCase) ||
                             type.Equals("mcq", StringComparison.OrdinalIgnoreCase);
                bool isTf = type.Equals("TF", StringComparison.OrdinalIgnoreCase) ||
                             type.Equals("true_false", StringComparison.OrdinalIgnoreCase);

                if (isMcq)
                {
                    var opts = GetOptions(qid);
                    html.Append(@"<div class=""space-y-3"">");
                    foreach (DataRow opt in opts.Rows)
                    {
                        string lbl = HttpUtility.HtmlEncode(opt["optionLabel"].ToString());
                        string optTxt = HttpUtility.HtmlEncode(opt["optionText"].ToString());
                        string safeQid = HttpUtility.HtmlAttributeEncode(qid);
                        html.Append($@"
                        <label class=""opt-label flex items-center gap-4 p-4 bg-gray-50 border-2 border-gray-100 rounded-2xl cursor-pointer hover:border-math-blue transition-all"">
                            <input type=""radio"" name=""q-{safeQid}"" value=""{lbl}""
                                   onchange=""recordAnswer('{safeQid}', this.value)"" class=""sr-only"" />
                            <span class=""opt-letter size-9 rounded-xl border-2 border-gray-200 bg-white flex items-center justify-center text-xs font-black text-gray-500 flex-shrink-0 transition-all"">{lbl}</span>
                            <span class=""opt-text text-sm font-semibold text-gray-700 flex-1"">{optTxt}</span>
                        </label>");
                    }
                    html.Append("</div>");
                }
                else if (isTf)
                {
                    string safeQid = HttpUtility.HtmlAttributeEncode(qid);
                    string btid = HttpUtility.HtmlAttributeEncode($"btnTrue-{qid}");
                    string bfid = HttpUtility.HtmlAttributeEncode($"btnFalse-{qid}");
                    html.Append($@"
                    <div class=""flex gap-4"">
                        <button type=""button"" id=""{btid}""
                            onclick=""tfPick('{safeQid}','True','{btid}','{bfid}')""
                            class=""tf-btn flex-1 py-4 rounded-2xl border-2 border-gray-200 bg-white text-gray-600 font-black text-sm uppercase tracking-widest hover:bg-gray-50 transition-all"">
                            True
                        </button>
                        <button type=""button"" id=""{bfid}""
                            onclick=""tfPick('{safeQid}','False','{btid}','{bfid}')""
                            class=""tf-btn flex-1 py-4 rounded-2xl border-2 border-gray-200 bg-white text-gray-600 font-black text-sm uppercase tracking-widest hover:bg-gray-50 transition-all"">
                            False
                        </button>
                    </div>");
                }
                else
                {
                    string safeQid = HttpUtility.HtmlAttributeEncode(qid);
                    html.Append($@"
                    <textarea rows=""3""
                        onchange=""recordAnswer('{safeQid}', this.value.trim())""
                        oninput=""recordAnswer('{safeQid}', this.value.trim())""
                        placeholder=""Type your answer here...""
                        class=""w-full px-5 py-4 bg-gray-50 border-2 border-gray-200 rounded-2xl text-math-dark-blue font-semibold text-sm
                               focus:border-math-blue focus:outline-none resize-none transition-colors""></textarea>");
                }

                html.Append("</div>");
                cardRows.Rows.Add(html.ToString());
                num++;
            }

            rptQuestions.DataSource = cardRows;
            rptQuestions.DataBind();
        }

        private DataTable GetOptions(string questionId)
        {
            const string sql = @"
                SELECT optionID, optionLabel, optionText, isCorrect
                FROM   dbo.questionOptionTable WHERE questionID=@qid ORDER BY optionLabel";
            var dt = new DataTable();
            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@qid", questionId);
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt;
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;
            var lit = (Literal)e.Item.FindControl("litQuestionCard");
            lit.Text = ((DataRowView)e.Item.DataItem)["CardHtml"].ToString();
        }

        // SUBMIT
        protected void btnSubmitAssessment_Click(object sender, EventArgs e)
        {
            string assessmentId = hdnAssessmentId.Value;
            string attemptId = hdnAttemptId.Value;
            string json = hdnAnswersJson.Value;
            string userId = CurrentUserId;

            if (string.IsNullOrEmpty(json)) json = "[]";

            List<SubmittedAnswer> submitted;
            try { submitted = new JavaScriptSerializer().Deserialize<List<SubmittedAnswer>>(json); }
            catch { submitted = new List<SubmittedAnswer>(); }

            int totalScore = 0, totalPossible = 0;

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        // Load all questions
                        var qMap = new Dictionary<string, QuestionGrade>(StringComparer.OrdinalIgnoreCase);
                        using (var cmd = new SqlCommand(@"
                            SELECT questionID, questionType, correctAnswer, points
                            FROM   dbo.questionTable WHERE assessmentID=@aid", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@aid", assessmentId);
                            using (var r = cmd.ExecuteReader())
                                while (r.Read())
                                    qMap[r["questionID"].ToString()] = new QuestionGrade
                                    {
                                        Type = r["questionType"].ToString(),
                                        CorrectAnswer = r["correctAnswer"].ToString(),
                                        Points = Convert.ToInt32(r["points"])
                                    };
                        }

                        // Resolve MCQ correct label from options table
                        foreach (var kv in qMap)
                        {
                            if (kv.Value.Type.Equals("MCQ", StringComparison.OrdinalIgnoreCase) ||
                                kv.Value.Type.Equals("mcq", StringComparison.OrdinalIgnoreCase))
                            {
                                using (var cmd = new SqlCommand(@"
                                    SELECT optionLabel FROM dbo.questionOptionTable
                                    WHERE  questionID=@qid AND isCorrect=1", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@qid", kv.Key);
                                    kv.Value.CorrectAnswer = cmd.ExecuteScalar()?.ToString() ?? "";
                                }
                            }
                        }

                        foreach (var sa in submitted)
                        {
                            if (!qMap.TryGetValue(sa.QuestionId, out var qg)) continue;
                            totalPossible += qg.Points;

                            string given = (sa.Answer ?? "").Trim();
                            bool isCorrect = string.Equals(given, qg.CorrectAnswer.Trim(),
                                                             StringComparison.OrdinalIgnoreCase);
                            int awarded = isCorrect ? qg.Points : 0;
                            totalScore += awarded;

                            bool isMcqOrTf =
                                qg.Type.Equals("MCQ", StringComparison.OrdinalIgnoreCase) ||
                                qg.Type.Equals("mcq", StringComparison.OrdinalIgnoreCase) ||
                                qg.Type.Equals("TF", StringComparison.OrdinalIgnoreCase) ||
                                qg.Type.Equals("true_false", StringComparison.OrdinalIgnoreCase);

                            object selOption = isMcqOrTf ? (object)given : DBNull.Value;
                            object answerText = isMcqOrTf ? (object)DBNull.Value : given;
                            string answerId = GenerateAnswerId(conn, tx);

                            using (var cmd = new SqlCommand(@"
                                IF EXISTS (SELECT 1 FROM dbo.studentAnswerTable
                                           WHERE attemptID=@atid AND questionID=@qid)
                                    UPDATE dbo.studentAnswerTable
                                    SET    selectedOption=@sel, answerText=@txt,
                                           isCorrect=@correct, pointsAwarded=@pts,
                                           answeredAt=SYSUTCDATETIME()
                                    WHERE  attemptID=@atid AND questionID=@qid
                                ELSE
                                    INSERT INTO dbo.studentAnswerTable
                                        (answerID,attemptID,userID,questionID,
                                         selectedOption,answerText,isCorrect,pointsAwarded,answeredAt)
                                    VALUES
                                        (@ansId,@atid,@uid,@qid,
                                         @sel,@txt,@correct,@pts,SYSUTCDATETIME())", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@ansId", answerId);
                                cmd.Parameters.AddWithValue("@atid", attemptId);
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@qid", sa.QuestionId);
                                cmd.Parameters.AddWithValue("@sel", selOption);
                                cmd.Parameters.AddWithValue("@txt", answerText);
                                cmd.Parameters.AddWithValue("@correct", isCorrect);
                                cmd.Parameters.AddWithValue("@pts", awarded);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        double pct = totalPossible > 0
                            ? Math.Round((double)totalScore / totalPossible * 100, 2) : 0;

                        using (var cmd = new SqlCommand(@"
                            UPDATE dbo.assessmentAttemptTable
                            SET score=@score, totalMarks=@total, percentage=@pct
                            WHERE attemptID=@atid", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@score", totalScore);
                            cmd.Parameters.AddWithValue("@total", totalPossible);
                            cmd.Parameters.AddWithValue("@pct", pct);
                            cmd.Parameters.AddWithValue("@atid", attemptId);
                            cmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                    catch { tx.Rollback(); throw; }
                }
            }

            Response.Redirect(
                $"studentAssessmentResult.aspx?attemptId={attemptId}&assessmentId={assessmentId}");
        }

        private string GenerateAnswerId(SqlConnection conn, SqlTransaction tx)
        {
            const string sql = @"
                SELECT ISNULL(MAX(CAST(SUBSTRING(answerID,3,LEN(answerID)) AS INT)),0)+1
                FROM   dbo.studentAnswerTable
                WHERE  answerID LIKE 'SA%'
                  AND  ISNUMERIC(SUBSTRING(answerID,3,LEN(answerID)))=1";
            using (var cmd = new SqlCommand(sql, conn, tx))
                return "SA" + Convert.ToInt32(cmd.ExecuteScalar()).ToString("D3");
        }

        private class SubmittedAnswer
        {
            public string QuestionId { get; set; }
            public string Answer { get; set; }
        }

        private class QuestionGrade
        {
            public string Type { get; set; }
            public string CorrectAnswer { get; set; }
            public int Points { get; set; }
        }
    }
}


