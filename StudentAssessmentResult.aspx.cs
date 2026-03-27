using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class studentAssessmentResult : System.Web.UI.Page
    {
        private readonly string connectionString =
            System.Configuration.ConfigurationManager
                .ConnectionStrings["MathSphereDB"].ConnectionString;

        public string ScorePct { get; private set; } = "0";

        private string CurrentUserId => ((Session["UserID"] ?? Session["userID"]) as string)?.Trim() ?? "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(CurrentUserId))
            { Response.Redirect("~/Login.aspx", true); return; }

            if (!IsPostBack)
            {
                string attemptId = (Request.QueryString["attemptId"] ?? "").Trim();
                string assessmentId = (Request.QueryString["assessmentId"] ?? "").Trim();

                if (string.IsNullOrEmpty(attemptId))
                { Response.Redirect("~/StudentDashboard.aspx"); return; }

                LoadResults(attemptId, assessmentId);
            }
        }

        private void LoadResults(string attemptId, string assessmentId)
        {
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Attempt summary
                // assessmentAttemptTable: score, totalMarks, percentage, attemptDate
                // assessmentTable:        title, moduleID, passingScore, totalMarks
                int score = 0;
                int totalMarks = 0;
                int passingScore = 0;
                string title = "";
                string moduleId = "";

                using (var cmd = new SqlCommand(@"
                    SELECT a.title,
                           ISNULL(a.moduleID,'')       AS moduleID,
                           ISNULL(a.passingScore, 0)   AS passingScore,
                           ISNULL(at2.score, 0)        AS score,
                           ISNULL(at2.totalMarks, 0)   AS totalMarks,
                           ISNULL(at2.percentage, 0)   AS percentage
                    FROM   dbo.assessmentAttemptTable at2
                    JOIN   dbo.assessmentTable        a  ON a.assessmentID = at2.assessmentID
                    WHERE  at2.attemptID = @atid AND at2.userID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@atid", attemptId);
                    cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) { Response.Redirect("~/StudentDashboard.aspx"); return; }

                        title = r["title"].ToString();
                        moduleId = r["moduleID"].ToString();
                        passingScore = Convert.ToInt32(r["passingScore"]);
                        score = Convert.ToInt32(r["score"]);
                        totalMarks = Convert.ToInt32(r["totalMarks"]);
                        int pct = Convert.ToInt32(r["percentage"]);
                        ScorePct = pct.ToString();

                        litAssessmentTitle.Text = HttpUtility.HtmlEncode(title);
                        litScore.Text = score.ToString();
                        litTotalPossible.Text = totalMarks.ToString();
                    }
                }

                // Pass / Fail banner
                bool passed = (passingScore == 0) || (score >= passingScore);
                pnlPassFail.Controls.Add(new LiteralControl(passed
                    ? @"<span class=""inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-math-green/20 text-math-green text-xs font-black uppercase tracking-widest mb-2"">
                           <span class=""material-symbols-outlined text-sm fill-icon"">check_circle</span> Passed
                       </span>"
                    : @"<span class=""inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-red-100 text-red-600 text-xs font-black uppercase tracking-widest mb-2"">
                           <span class=""material-symbols-outlined text-sm fill-icon"">cancel</span> Did not pass
                       </span>"));

                // Per-question results
                // studentAnswerTable columns: answerID, attemptID, userID, questionID, selectedOption, answerText, isCorrect, pointsAwarded, answeredAt
                var qResult = new DataTable();
                using (var cmd = new SqlCommand(@"
                    SELECT q.questionID,
                           q.questionNumber,
                           q.questionText,
                           q.questionType,
                           q.correctAnswer,
                           q.points,
                           ISNULL(sa.selectedOption, '') AS selectedOption,
                           ISNULL(sa.answerText,     '') AS answerText,
                           ISNULL(sa.isCorrect,       0) AS isCorrect,
                           ISNULL(sa.pointsAwarded,   0) AS pointsAwarded
                    FROM   dbo.questionTable q
                    LEFT JOIN dbo.studentAnswerTable sa
                           ON sa.questionID = q.questionID AND sa.attemptID = @atid
                    WHERE  q.assessmentID = @aid
                    ORDER  BY q.questionNumber", conn))
                {
                    cmd.Parameters.AddWithValue("@atid", attemptId);
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    new SqlDataAdapter(cmd).Fill(qResult);
                }

                int correct = 0, wrong = 0;
                var cardRows = new DataTable();
                cardRows.Columns.Add("CardHtml");

                foreach (DataRow row in qResult.Rows)
                {
                    bool isCorrect = Convert.ToBoolean(row["isCorrect"]);
                    if (isCorrect) correct++; else wrong++;

                    string qid = row["questionID"].ToString();
                    string type = row["questionType"].ToString();
                    // For MCQ/TF the answer is in selectedOption; for short answer it's in answerText
                    string given = !string.IsNullOrEmpty(row["selectedOption"].ToString())
                                          ? row["selectedOption"].ToString()
                                          : row["answerText"].ToString();
                    string correctA = row["correctAnswer"].ToString();
                    int pts = Convert.ToInt32(row["points"]);
                    int awarded = Convert.ToInt32(row["pointsAwarded"]);

                    string cardCls = isCorrect ? "correct-card" : "incorrect-card";
                    string badgeCls = isCorrect ? "correct-badge" : "incorrect-badge";
                    string badgeTxt = isCorrect ? "Correct" : "Incorrect";
                    string icon = isCorrect ? "check_circle" : "cancel";

                    var html = new StringBuilder();
                    html.Append($@"
                    <div class=""bg-white border-2 border-gray-100 rounded-3xl p-7 {cardCls}"">
                        <div class=""flex items-start justify-between gap-4 mb-4"">
                            <div class=""flex items-center gap-3"">
                                <span class=""size-9 rounded-xl bg-math-dark-blue text-white flex items-center justify-center text-sm font-black flex-shrink-0"">{row["questionNumber"]}</span>
                                <span class=""px-3 py-1 {badgeCls} text-[10px] font-black rounded-full flex items-center gap-1"">
                                    <span class=""material-symbols-outlined text-xs fill-icon"">{icon}</span>{badgeTxt}
                                </span>
                            </div>
                            <span class=""text-xs font-black text-gray-500"">{awarded} / {pts} pts</span>
                        </div>
                        <p class=""text-sm font-bold text-math-dark-blue mb-4 leading-relaxed"">{HttpUtility.HtmlEncode(row["questionText"].ToString())}</p>");

                    bool isMcq = type.Equals("MCQ", StringComparison.OrdinalIgnoreCase) ||
                                 type.Equals("mcq", StringComparison.OrdinalIgnoreCase);
                    bool isTf = type.Equals("TF", StringComparison.OrdinalIgnoreCase) ||
                                 type.Equals("true_false", StringComparison.OrdinalIgnoreCase);

                    if (isMcq)
                    {
                        var opts = new DataTable();
                        using (var ocmd = new SqlCommand(@"
                            SELECT optionLabel, optionText, isCorrect
                            FROM   dbo.questionOptionTable
                            WHERE  questionID=@qid ORDER BY optionLabel", conn))
                        {
                            ocmd.Parameters.AddWithValue("@qid", qid);
                            new SqlDataAdapter(ocmd).Fill(opts);
                        }
                        html.Append(@"<div class=""space-y-2"">");
                        foreach (DataRow opt in opts.Rows)
                        {
                            string lbl = opt["optionLabel"].ToString();
                            bool optCorr = Convert.ToBoolean(opt["isCorrect"]);
                            bool wasPicked = string.Equals(lbl, given, StringComparison.OrdinalIgnoreCase);
                            string cls; string indicator;
                            if (optCorr)
                            { cls = "opt-correct"; indicator = @"<span class=""material-symbols-outlined text-green-600 text-sm fill-icon"">check_circle</span>"; }
                            else if (wasPicked)
                            { cls = "opt-incorrect"; indicator = @"<span class=""material-symbols-outlined text-red-500 text-sm fill-icon"">cancel</span>"; }
                            else
                            { cls = "bg-gray-50 border-gray-100"; indicator = ""; }

                            html.Append($@"
                            <div class=""flex items-center gap-3 p-3 border-2 rounded-2xl {cls}"">
                                <span class=""size-7 rounded-lg border-2 border-gray-200 bg-white flex items-center justify-center text-xs font-black text-gray-500 flex-shrink-0"">{HttpUtility.HtmlEncode(lbl)}</span>
                                <span class=""text-sm font-semibold text-gray-700 flex-1"">{HttpUtility.HtmlEncode(opt["optionText"].ToString())}</span>
                                {indicator}
                            </div>");
                        }
                        html.Append("</div>");
                    }
                    else if (isTf)
                    {
                        foreach (var tfVal in new[] { "True", "False" })
                        {
                            bool isCorr = string.Equals(tfVal, correctA.Trim(), StringComparison.OrdinalIgnoreCase);
                            bool wasPicked = string.Equals(tfVal, given, StringComparison.OrdinalIgnoreCase);
                            string cls; string indicator;
                            if (isCorr)
                            { cls = "opt-correct"; indicator = @"<span class=""material-symbols-outlined text-green-600 text-sm fill-icon"">check_circle</span>"; }
                            else if (wasPicked)
                            { cls = "opt-incorrect"; indicator = @"<span class=""material-symbols-outlined text-red-500 text-sm fill-icon"">cancel</span>"; }
                            else
                            { cls = "bg-gray-50 border-gray-100"; indicator = ""; }

                            html.Append($@"
                            <div class=""flex items-center justify-between p-3 border-2 rounded-2xl {cls} mb-2"">
                                <span class=""font-black text-sm"">{tfVal}</span>{indicator}
                            </div>");
                        }
                    }
                    else // short answer
                    {
                        string borderCls = isCorrect ? "opt-correct" : "opt-incorrect";
                        html.Append($@"
                        <div class=""space-y-2"">
                            <div class=""p-3 rounded-2xl bg-white border-2 {borderCls}"">
                                <p class=""text-[10px] font-black text-gray-400 uppercase mb-1"">Your Answer</p>
                                <p class=""text-sm font-semibold text-math-dark-blue"">{HttpUtility.HtmlEncode(string.IsNullOrEmpty(given) ? "(no answer)" : given)}</p>
                            </div>");
                        if (!isCorrect)
                            html.Append($@"
                            <div class=""p-3 rounded-2xl opt-correct"">
                                <p class=""text-[10px] font-black text-gray-400 uppercase mb-1"">Correct Answer</p>
                                <p class=""text-sm font-semibold text-math-dark-blue"">{HttpUtility.HtmlEncode(correctA)}</p>
                            </div>");
                        html.Append("</div>");
                    }

                    html.Append("</div>");
                    cardRows.Rows.Add(html.ToString());
                }

                litCorrectCount.Text = correct.ToString();
                litWrongCount.Text = wrong.ToString();
                rptResults.DataSource = cardRows;
                rptResults.DataBind();

                lnkBackToModule.NavigateUrl = string.IsNullOrEmpty(moduleId)
                    ? "~/StudentDashboard.aspx"
                    : $"~/moduleContent.aspx?moduleId={moduleId}";
            }
        }

        protected void rptResults_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;
            var lit = (Literal)e.Item.FindControl("litResultCard");
            lit.Text = ((DataRowView)e.Item.DataItem)["CardHtml"].ToString();
        }
    }
}




