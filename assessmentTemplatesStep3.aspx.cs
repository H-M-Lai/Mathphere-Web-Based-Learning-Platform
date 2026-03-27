using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class assessmentTemplateStep3 : System.Web.UI.Page
    {
        private readonly string connectionString =
            System.Configuration.ConfigurationManager
                  .ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string assessmentId = (Request.QueryString["assessmentId"] ?? "").Trim();
                string courseId = (Request.QueryString["courseId"] ?? "").Trim();
                bool isEditMode = string.Equals(Request.QueryString["edit"], "1", StringComparison.OrdinalIgnoreCase);

                if (string.IsNullOrEmpty(assessmentId))
                {
                    Response.Redirect("assessmentTemplates.aspx", true);
                    return;
                }

                ViewState["assessmentId"] = assessmentId;
                ViewState["courseId"] = courseId;
                ViewState["isEditMode"] = isEditMode;

                BindReviewData(assessmentId, courseId);
                ApplyModeUi(isEditMode);
            }
        }

        protected string ResolveModuleBuilderUrl()
        {
            string courseId = (ViewState["courseId"]?.ToString() ?? Request.QueryString["courseId"] ?? "").Trim();
            string assessmentId = (ViewState["assessmentId"]?.ToString() ?? Request.QueryString["assessmentId"] ?? "").Trim();
            string moduleId = "";

            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand("SELECT ISNULL(moduleID,'') FROM dbo.assessmentTable WHERE assessmentID = @aid", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    conn.Open();
                    moduleId = cmd.ExecuteScalar()?.ToString() ?? "";
                }
            }
            catch { moduleId = ""; }

            if (!string.IsNullOrWhiteSpace(moduleId))
                return "moduleBuilder.aspx?id=" + HttpUtility.UrlEncode(moduleId) + "&courseId=" + HttpUtility.UrlEncode(courseId);

            return "fullModuleView.aspx?courseId=" + HttpUtility.UrlEncode(courseId);
        }
private void ApplyModeUi(bool isEditMode)
        {
            if (isEditMode)
            {
                litStepMode.Text = "Edit Published Assessment";
                btnPublish.Text = "Save Changes";
                btnPreviousStep.Visible = false;
            }
            else
            {
                litStepMode.Text = "Step 3: Review &amp; Save";
                btnPublish.Text = "Publish Assessment";
                btnPreviousStep.Visible = true;
            }
        }

        private void BindReviewData(string assessmentId, string courseId)
        {
            const string summarySQL = @"
                SELECT a.title,
                       ISNULL(a.timeLimitMinutes, 60)  AS timeLimitMinutes,
                       ISNULL(a.totalMarks, 0)         AS totalMarks,
                       ISNULL(a.passingScore, 60)      AS passingScore,
                       ISNULL(a.shuffleQuestions, 0)  AS shuffleQuestions,
                       ISNULL(a.isPublished, 0)        AS isPublished,
                       m.moduleTitle,
                       c.courseName
                FROM   dbo.assessmentTable a
                LEFT JOIN dbo.moduleTable m ON m.moduleID = a.moduleID
                LEFT JOIN dbo.courseTable c ON c.courseID = a.courseID
                WHERE  a.assessmentID = @aid;";

            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(summarySQL, conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    conn.Open();

                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowAlert("Assessment not found.");
                            return;
                        }

                        string title = r["title"].ToString();
                        int timeLimit = Convert.ToInt32(r["timeLimitMinutes"]);
                        int passScore = Convert.ToInt32(r["passingScore"]);
                        bool shuffle = r["shuffleQuestions"] != DBNull.Value && Convert.ToBoolean(r["shuffleQuestions"]);
                        string courseName = r["courseName"] == DBNull.Value ? "" : r["courseName"].ToString();

                        lblAssessmentName.Text = title;
                        lblTimeDisplay.Text = timeLimit + " Min";

                        hfTemplateName.Value = title;
                        hfTimeLimit.Value = timeLimit.ToString();
                        hfPassScore.Value = passScore.ToString();

                        pnlShuffleBadge.Visible = shuffle;
                        hfShuffleOn.Value = shuffle ? "1" : "0";
                        hfRequirePassOn.Value = passScore > 0 ? "1" : "0";

                        lblCourseName.Text = string.IsNullOrWhiteSpace(courseName) ? "this course" : courseName;

                        lnkCreateAnother.NavigateUrl =
                            "assessmentTemplates.aspx" +
                            (string.IsNullOrWhiteSpace(courseId)
                                ? ""
                                : "?courseId=" + HttpUtility.UrlEncode(courseId));
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading summary: " + ex.Message);
                return;
            }

            const string questSQL = @"
                SELECT questionNumber AS OrderNum,
                       questionText,
                       points,
                       CASE
                           WHEN points <= 5 THEN 'Easy'
                           WHEN points <= 10 THEN 'Medium'
                           ELSE 'Hard'
                       END AS Difficulty
                FROM dbo.questionTable
                WHERE assessmentID = @aid
                ORDER BY questionNumber ASC;";

            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(questSQL, conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    conn.Open();

                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    int totalQ = dt.Rows.Count;
                    lblTotalQuestions.Text = totalQ.ToString();

                    int totalPts = 0;
                    foreach (DataRow row in dt.Rows)
                        totalPts += Convert.ToInt32(row["points"]);

                    lblTotalPoints.Text = totalPts.ToString();

                    const int previewMax = 3;
                    var preview = dt.Clone();
                    for (int i = 0; i < Math.Min(previewMax, totalQ); i++)
                        preview.ImportRow(dt.Rows[i]);

                    rptReviewQuestions.DataSource = preview;
                    rptReviewQuestions.DataBind();

                    int remaining = totalQ - Math.Min(previewMax, totalQ);
                    if (remaining > 0)
                    {
                        litMoreQsLabel.Text = remaining + " more question" + (remaining == 1 ? "" : "s") + " selected";
                        pnlMoreQsRow.Visible = true;
                    }
                    else
                    {
                        pnlMoreQsRow.Visible = false;
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading questions: " + ex.Message);
                return;
            }

            string backUrl =
                "assessmentTemplateStep2.aspx" +
                "?assessmentId=" + HttpUtility.UrlEncode(assessmentId) +
                "&courseId=" + HttpUtility.UrlEncode(courseId ?? "");

            btnPreviousStep.OnClientClick =
                "window.location.href='" + backUrl.Replace("'", "\\'") + "'; return false;";
        }

        protected void rptReviewQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            Literal litBadge = (Literal)e.Item.FindControl("litDiffBadge");
            string diff = row["Difficulty"].ToString();

            string cls = diff == "Easy" ? "bg-math-green/10 text-math-green"
                       : diff == "Medium" ? "bg-math-blue/10 text-math-blue"
                       : diff == "Hard" ? "bg-primary/10 text-primary"
                                         : "bg-gray-100 text-gray-400";

            litBadge.Text =
                $@"<span class=""px-3 py-1 {cls} text-[10px] font-black rounded-full uppercase tracking-tighter"">{diff}</span>";
        }

        protected void btnUpdateConfig_Click(object sender, EventArgs e)
        {
            string assessmentId = ViewState["assessmentId"]?.ToString();
            if (string.IsNullOrEmpty(assessmentId))
            {
                ShowAlert("Assessment ID is missing.");
                return;
            }

            SaveAssessmentSettings(assessmentId, publishAlso: false);
            BindReviewData(assessmentId, ViewState["courseId"]?.ToString() ?? "");
            ApplyModeUi((ViewState["isEditMode"] as bool?) == true);
        }

        protected void btnPublish_Click(object sender, EventArgs e)
        {
            string assessmentId = ViewState["assessmentId"]?.ToString();
            if (string.IsNullOrEmpty(assessmentId))
            {
                ShowAlert("Assessment ID missing. Please restart the wizard.");
                return;
            }

            SaveAssessmentSettings(assessmentId, publishAlso: true);
            pnlSuccessModal.Visible = true;
        }

        private void SaveAssessmentSettings(string assessmentId, bool publishAlso)
        {
            int timeLimit = int.TryParse(hfTimeLimit.Value, out int tl) ? tl : 60;
            int passScore = int.TryParse(hfPassScore.Value, out int ps) ? ps : 60;
            bool shuffle = hfShuffleOn.Value == "1";
            string newTitle = (hfTemplateName.Value ?? "").Trim();

            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.assessmentTable
                    SET    title            = CASE WHEN @title <> '' THEN @title ELSE title END,
                           timeLimitMinutes = @timeLimit,
                           passingScore     = @passScore,
                           shuffleQuestions = @shuffle,
                           isPublished      = CASE WHEN @publishAlso = 1 THEN 1 ELSE isPublished END,
                           updatedAt        = SYSUTCDATETIME()
                    WHERE  assessmentID = @aid;", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    cmd.Parameters.AddWithValue("@title", newTitle);
                    cmd.Parameters.AddWithValue("@timeLimit", timeLimit);
                    cmd.Parameters.AddWithValue("@passScore", passScore);
                    cmd.Parameters.AddWithValue("@shuffle", shuffle);
                    cmd.Parameters.AddWithValue("@publishAlso", publishAlso ? 1 : 0);

                    conn.Open();
                    int rows = cmd.ExecuteNonQuery();

                    if (rows == 0)
                    {
                        ShowAlert("Assessment not found.");
                        return;
                    }
                }

                BindReviewData(assessmentId, ViewState["courseId"]?.ToString() ?? "");
            }
            catch (Exception ex)
            {
                ShowAlert("Error saving assessment: " + ex.Message);
            }
        }

        private void ShowAlert(string msg)
        {
            string safe = (msg ?? "")
                .Replace("\\", "\\\\")
                .Replace("'", "\\'")
                .Replace("\r", "")
                .Replace("\n", " ");

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                "Alert_" + Guid.NewGuid().ToString("N"),
                $"alert('{safe}');",
                true);
        }
    }
}

