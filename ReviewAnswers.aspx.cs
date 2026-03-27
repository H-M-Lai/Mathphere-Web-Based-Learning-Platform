using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Assignment
{
    public partial class ReviewAnswers : Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private string CurrentUserId => ((Session["UserID"] ?? Session["userID"]) as string)?.Trim() ?? "";

        private class QuestionRow
        {
            public string QuestionId { get; set; }
            public int Number { get; set; }
            public string QuestionText { get; set; }
            public string QuestionType { get; set; }
            public int Points { get; set; }
            public bool IsCorrect { get; set; }
            public int PointsAwarded { get; set; }
            public string Hint { get; set; }
            public bool IsPaper { get; set; }
            public string StudentAnswerText { get; set; }
            public string CorrectAnswerText { get; set; }
            public bool HasTextAnswer { get; set; }
            public List<OptionRow> Options { get; set; } = new List<OptionRow>();
        }

        private class OptionRow
        {
            public string OptionId { get; set; }
            public string OptionLabel { get; set; }
            public string OptionText { get; set; }
            public bool IsCorrect { get; set; }
            public bool WasSelected { get; set; }
            public bool IsPaper { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(CurrentUserId))
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!IsPostBack)
                LoadAttempt();
        }

        private void LoadAttempt()
        {
            string attemptId = Request.QueryString["attemptId"];

            if (string.IsNullOrEmpty(attemptId))
            {
                ShowError("No attempt specified.");
                return;
            }

            LoadAssessmentAttemptDigital(attemptId);
        }

        private void LoadAssessmentAttemptDigital(string attemptId)
        {
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();

                int score = 0, totalMarks = 0;
                decimal percentage = 0;
                string title = "";
                DateTime attemptDate = DateTime.UtcNow;

                using (var cmd = new SqlCommand(@"
                    SELECT aa.score, aa.totalMarks, aa.percentage, aa.attemptDate, a.title
                    FROM   dbo.assessmentAttemptTable aa
                    INNER JOIN dbo.assessmentTable a ON a.assessmentID = aa.assessmentID
                    WHERE  aa.attemptID = @aid AND aa.userID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", attemptId);
                    cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read()) { ShowError("Attempt not found."); return; }
                        score = Convert.ToInt32(rdr["score"]);
                        totalMarks = Convert.ToInt32(rdr["totalMarks"]);
                        percentage = Convert.ToDecimal(rdr["percentage"]);
                        attemptDate = Convert.ToDateTime(rdr["attemptDate"]);
                        title = rdr["title"].ToString();
                    }
                }

                litAttemptTitle.Text = HttpUtility.HtmlEncode(title);
                litAttemptDate.Text = attemptDate.ToString("dd MMM yyyy, HH:mm");
                litScoreFrac.Text = $"{score}/{totalMarks}";

                double ringOffset = 283.0 * (1.0 - (double)percentage / 100.0);
                litRingOffset.Text = ringOffset.ToString("F1", System.Globalization.CultureInfo.InvariantCulture);
                litScorePct.Text = ((int)Math.Round(percentage)).ToString();

                pnlQuizHeader.Visible = true;
                pnlPaperHeader.Visible = false;
                pnlPaperBadge.Visible = false;
                pnlMain.Visible = true;

                var studentAnswers = new Dictionary<string, (string optId, string answerText, bool correct, int pts)>(
                    StringComparer.OrdinalIgnoreCase);

                using (var cmd = new SqlCommand(@"
                    SELECT questionID,
                           ISNULL(selectedOption, '') AS selectedOption,
                           ISNULL(answerText, '')     AS answerText,
                           isCorrect,
                           ISNULL(pointsAwarded, 0)   AS pointsAwarded
                    FROM   dbo.studentAnswerTable
                    WHERE  attemptID = @aid AND userID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", attemptId);
                    cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            studentAnswers[rdr["questionID"].ToString()] = (
                                rdr["selectedOption"].ToString(),
                                rdr["answerText"].ToString(),
                                Convert.ToBoolean(rdr["isCorrect"]),
                                Convert.ToInt32(rdr["pointsAwarded"])
                            );
                        }
                    }
                }

                var questions = new List<QuestionRow>();

                using (var cmd = new SqlCommand(@"
                    SELECT q.questionID,
                           q.questionNumber,
                           q.questionText,
                           ISNULL(q.questionType, '')  AS questionType,
                           ISNULL(q.correctAnswer, '') AS correctAnswer,
                           COALESCE(q.points, 1)       AS points
                    FROM   dbo.questionTable q
                    INNER JOIN dbo.assessmentAttemptTable aa
                           ON aa.assessmentID = q.assessmentID
                    WHERE  aa.attemptID = @aid AND aa.userID = @uid
                    ORDER  BY q.questionNumber", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", attemptId);
                    cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string qid = rdr["questionID"].ToString();
                            bool isCorrect = studentAnswers.ContainsKey(qid) && studentAnswers[qid].correct;
                            int ptsAwarded = studentAnswers.ContainsKey(qid) ? studentAnswers[qid].pts : 0;
                            string questionType = rdr["questionType"].ToString();
                            bool hasTextAnswer = !questionType.Equals("MCQ", StringComparison.OrdinalIgnoreCase)
                                              && !questionType.Equals("mcq", StringComparison.OrdinalIgnoreCase)
                                              && !questionType.Equals("TF", StringComparison.OrdinalIgnoreCase)
                                              && !questionType.Equals("true_false", StringComparison.OrdinalIgnoreCase);

                            questions.Add(new QuestionRow
                            {
                                QuestionId = qid,
                                Number = Convert.ToInt32(rdr["questionNumber"]),
                                QuestionText = rdr["questionText"].ToString(),
                                QuestionType = questionType,
                                Points = Convert.ToInt32(rdr["points"]),
                                IsCorrect = isCorrect,
                                PointsAwarded = ptsAwarded,
                                IsPaper = false,
                                StudentAnswerText = studentAnswers.ContainsKey(qid) ? studentAnswers[qid].answerText : "",
                                CorrectAnswerText = rdr["correctAnswer"].ToString(),
                                HasTextAnswer = hasTextAnswer,
                                Hint = null
                            });
                        }
                    }
                }

                foreach (var q in questions)
                {
                    if (q.HasTextAnswer) continue;

                    string selOpt = studentAnswers.ContainsKey(q.QuestionId)
                        ? studentAnswers[q.QuestionId].optId
                        : null;
                    LoadOptions(conn, q, selOpt);
                }

                rptQuestions.DataSource = questions;
                rptQuestions.DataBind();
            }
        }

        private void LoadOptions(SqlConnection conn, QuestionRow q, string selectedOptionId)
        {
            using (var cmd = new SqlCommand(@"
                SELECT optionID, optionLabel, optionText, isCorrect
                FROM   dbo.questionOptionTable
                WHERE  questionID = @qid
                ORDER  BY optionLabel", conn))
            {
                cmd.Parameters.AddWithValue("@qid", q.QuestionId);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string optId = rdr["optionID"].ToString();
                        q.Options.Add(new OptionRow
                        {
                            OptionId = optId,
                            OptionLabel = rdr["optionLabel"].ToString(),
                            OptionText = rdr["optionText"].ToString(),
                            IsCorrect = Convert.ToBoolean(rdr["isCorrect"]),
                            WasSelected = string.Equals(optId, selectedOptionId, StringComparison.OrdinalIgnoreCase),
                            IsPaper = q.IsPaper
                        });
                    }
                }
            }
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var q = (QuestionRow)e.Item.DataItem;

            var rptOpts = e.Item.FindControl("rptOptions") as Repeater;
            if (rptOpts != null)
            {
                rptOpts.Visible = !q.HasTextAnswer;
                rptOpts.DataSource = q.Options;
                rptOpts.DataBind();
            }

            var pnlTextAnswer = e.Item.FindControl("pnlTextAnswer") as Panel;
            var litStudentAnswerText = e.Item.FindControl("litStudentAnswerText") as Literal;
            var litCorrectAnswerText = e.Item.FindControl("litCorrectAnswerText") as Literal;
            var pnlCorrectAnswerText = e.Item.FindControl("pnlCorrectAnswerText") as Panel;

            if (pnlTextAnswer != null) pnlTextAnswer.Visible = q.HasTextAnswer;
            if (litStudentAnswerText != null)
                litStudentAnswerText.Text = HttpUtility.HtmlEncode(string.IsNullOrWhiteSpace(q.StudentAnswerText) ? "(no answer)" : q.StudentAnswerText);
            if (litCorrectAnswerText != null)
                litCorrectAnswerText.Text = HttpUtility.HtmlEncode(q.CorrectAnswerText ?? "");
            if (pnlCorrectAnswerText != null)
                pnlCorrectAnswerText.Visible = q.HasTextAnswer && !q.IsCorrect;

            var pnlHint = e.Item.FindControl("pnlHint") as Panel;
            if (pnlHint != null)
                pnlHint.Visible = false;

            var pnlCorrect = e.Item.FindControl("pnlCorrectBadge") as Panel;
            var pnlWrong = e.Item.FindControl("pnlWrongBadge") as Panel;
            var pnlPaperPts = e.Item.FindControl("pnlPaperPts") as Panel;

            if (pnlCorrect != null) pnlCorrect.Visible = q.IsCorrect;
            if (pnlWrong != null) pnlWrong.Visible = !q.IsCorrect;
            if (pnlPaperPts != null) pnlPaperPts.Visible = false;

            var litC = e.Item.FindControl("litPtsAwarded") as Literal;
            var litW = e.Item.FindControl("litPtsAwardedWrong") as Literal;
            if (litC != null) litC.Text = q.PointsAwarded.ToString();
            if (litW != null) litW.Text = q.PointsAwarded.ToString();
        }

        protected string GetOptionClass(bool isCorrect, bool wasSelected, bool isPaper)
        {
            const string b = "flex items-center gap-3 p-3 rounded-xl border ";
            if (isCorrect) return b + "bg-math-green/5 border-math-green/30";
            if (wasSelected) return b + "bg-red-50 border-red-200";
            return b + "bg-white border-gray-100";
        }

        protected string GetOptionLabelClass(bool isCorrect, bool wasSelected, bool isPaper)
        {
            const string b = "size-7 shrink-0 rounded-lg flex items-center justify-center font-black text-xs ";
            if (isCorrect) return b + "bg-math-green text-white";
            if (wasSelected) return b + "bg-red-400 text-white";
            return b + "bg-gray-100 text-gray-500";
        }

        protected string GetOptionTextClass(bool isCorrect, bool wasSelected, bool isPaper)
        {
            if (isCorrect) return "flex-1 text-sm font-bold text-math-dark-blue";
            if (wasSelected) return "flex-1 text-sm font-bold text-red-500 line-through";
            return "flex-1 text-sm text-gray-500";
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlMain.Visible = false;
        }
    }
}
