using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;

namespace Assignment
{
    public partial class ReviewPastAttempt : Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        // Page model
        private class AttemptRow
        {
            public string AttemptId { get; set; }
            public string AssessmentId { get; set; }
            public string Title { get; set; }
            public bool IsPaperBased { get; set; }
            public int Score { get; set; }
            public int TotalMarks { get; set; }
            public decimal Percentage { get; set; }
            public DateTime AttemptDate { get; set; }
        }

        // Page load
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadAttempts();
        }

        // Button handlers
        protected void btnBackDashboard_Click(object sender, EventArgs e)
        {
            Response.Redirect("StudentDashboard.aspx");
        }

        protected void btnGoMissions_Click(object sender, EventArgs e)
        {
            Response.Redirect("Missions.aspx");
        }

        protected void rptAttempts_ItemCommand1(object source, RepeaterCommandEventArgs e)
        {
            // Navigation is handled via HyperLink controls; no PostBack commands needed.
        }

        // Main loader
        private void LoadAttempts()
        {
            string userId = Session["UserID"]?.ToString();
            string moduleId = Request.QueryString["moduleId"];

            var allAttempts = new List<AttemptRow>();

            if (string.IsNullOrEmpty(userId))
            {
                pnlContent.Visible = false;
                pnlEmpty.Visible = true;
                pnlSummary.Visible = false;
                return;
            }

            string moduleFilter = string.IsNullOrEmpty(moduleId)
                ? ""
                : @"AND a.assessmentID IN (
                SELECT assessmentID FROM dbo.assessmentTable
                WHERE courseID IN (
                    SELECT courseID FROM dbo.moduleTable WHERE moduleID = @mid
                )
            )";

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand($@"
            SELECT
                aa.attemptID,
                aa.assessmentID,
                a.title,
                aa.score,
                aa.totalMarks,
                COALESCE(aa.percentage,
                    CASE WHEN aa.totalMarks > 0
                         THEN CAST(aa.score AS DECIMAL(5,2)) / aa.totalMarks * 100
                         ELSE 0 END) AS percentage,
                aa.attemptDate
            FROM dbo.assessmentAttemptTable aa
            INNER JOIN dbo.assessmentTable a ON a.assessmentID = aa.assessmentID
            WHERE aa.userID = @uid {moduleFilter}
            ORDER BY aa.attemptDate DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    if (!string.IsNullOrEmpty(moduleId))
                        cmd.Parameters.AddWithValue("@mid", moduleId);

                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            allAttempts.Add(new AttemptRow
                            {
                                AttemptId = rdr["attemptID"].ToString(),
                                AssessmentId = rdr["assessmentID"].ToString(),
                                Title = rdr["title"].ToString(),
                                IsPaperBased = false,
                                Score = Convert.ToInt32(rdr["score"]),
                                TotalMarks = Convert.ToInt32(rdr["totalMarks"]),
                                Percentage = Convert.ToDecimal(rdr["percentage"]),
                                AttemptDate = Convert.ToDateTime(rdr["attemptDate"])
                            });
                        }
                    }
                }
            }

            allAttempts.Sort((x, y) => y.AttemptDate.CompareTo(x.AttemptDate));

            if (allAttempts.Count == 0)
            {
                pnlContent.Visible = false;
                pnlEmpty.Visible = true;
                pnlSummary.Visible = false;
                return;
            }

            pnlContent.Visible = true;
            pnlEmpty.Visible = false;

            rptAttempts.DataSource = allAttempts;
            rptAttempts.DataBind();

            BindSummary(allAttempts);
        }

        // Summary panel
        private void BindSummary(List<AttemptRow> attempts)
        {
            pnlSummary.Visible = true;

            decimal sumPct = 0;
            int bestPct = -1;
            var seenAssessments = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (var a in attempts)
            {
                sumPct += a.Percentage;
                seenAssessments.Add(a.AssessmentId);
                int pct = (int)Math.Round(a.Percentage);
                if (pct > bestPct) bestPct = pct;
            }

            decimal overallMastery = attempts.Count > 0 ? sumPct / attempts.Count : 0;

            double ringOffset = 283.0 * (1.0 - (double)overallMastery / 100.0);
            litMasteryOffset.Text = ringOffset.ToString("F1",
                System.Globalization.CultureInfo.InvariantCulture);
            litMasteryPct.Text = ((int)Math.Round(overallMastery)).ToString();

            litStatAttempts.Text = attempts.Count.ToString();
            litStatAssessments.Text = seenAssessments.Count.ToString();
            litStatQuizAvg.Text = overallMastery.ToString("0") + "%";
            litStatBestQuiz.Text = bestPct >= 0 ? bestPct + "%" : "—";
        }

        // Repeater ItemDataBound
        protected void rptAttempts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row = (AttemptRow)e.Item.DataItem;

            // Score ring values (quiz)
            var litRingOffset = e.Item.FindControl("litRingOffset") as Literal;
            var litScorePct = e.Item.FindControl("litScorePct") as Literal;
            if (litRingOffset != null && litScorePct != null)
            {
                double offset = 283.0 * (1.0 - (double)row.Percentage / 100.0);
                litRingOffset.Text = offset.ToString("F1",
                    System.Globalization.CultureInfo.InvariantCulture);
                litScorePct.Text = ((int)Math.Round(row.Percentage)).ToString();
            }

            // Score fraction
            var litScoreFrac = e.Item.FindControl("litScoreFrac") as Literal;
            if (litScoreFrac != null)
                litScoreFrac.Text = $"{row.Score}/{row.TotalMarks}";

            // Date
            var litDate = e.Item.FindControl("litAttemptDate") as Literal;
            if (litDate != null)
                litDate.Text = row.AttemptDate.ToString("dd MMM yyyy, HH:mm");

            // Title
            var litTitle = e.Item.FindControl("litAttemptTitle") as Literal;
            if (litTitle != null)
                litTitle.Text = System.Web.HttpUtility.HtmlEncode(row.Title);

            // In ReviewPastAttempt.aspx.cs rptAttempts_ItemDataBound, change both links to:
            var lnkReview = e.Item.FindControl("lnkReviewAnswers") as HyperLink;
            if (lnkReview != null)
                lnkReview.NavigateUrl = $"ReviewAnswers.aspx?attemptId={row.AttemptId}";

            var lnkKey = e.Item.FindControl("lnkAnswerKey") as HyperLink;
            if (lnkKey != null)
                lnkKey.NavigateUrl = $"ReviewAnswers.aspx?attemptId={row.AttemptId}";

            // Show/hide panels
            var pnlQuizCard = e.Item.FindControl("pnlQuizCard") as Panel;
            var pnlPaperCard = e.Item.FindControl("pnlPaperCard") as Panel;
            var pnlQuizActions = e.Item.FindControl("pnlQuizActions") as Panel;
            var pnlPaperActions = e.Item.FindControl("pnlPaperActions") as Panel;
            var pnlPaperNote = e.Item.FindControl("pnlPaperNote") as Panel;

            if (pnlQuizCard != null) pnlQuizCard.Visible = !row.IsPaperBased;
            if (pnlPaperCard != null) pnlPaperCard.Visible = row.IsPaperBased;
            if (pnlQuizActions != null) pnlQuizActions.Visible = !row.IsPaperBased;
            if (pnlPaperActions != null) pnlPaperActions.Visible = row.IsPaperBased;
            if (pnlPaperNote != null) pnlPaperNote.Visible = row.IsPaperBased;
        }
    }
}
