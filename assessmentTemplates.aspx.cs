using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class assessmentTemplates : System.Web.UI.Page
    {
        private readonly string connectionString =
            System.Configuration.ConfigurationManager
                .ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string courseId = (Request.QueryString["courseId"] ?? "").Trim();
                string assessmentId = (Request.QueryString["assessmentId"] ?? "").Trim();

                hdnCourseId.Value = courseId;
                hdnAssessmentId.Value = assessmentId;

                hdnCreatedBy.Value =
                    (Session["UserID"]?.ToString() ??
                     Session["userID"]?.ToString() ??
                     "").Trim();

                if (string.IsNullOrEmpty(courseId) && string.IsNullOrEmpty(assessmentId))
                {
                    Response.Redirect("courselistDashboard.aspx", true);
                    return;
                }

                if (!string.IsNullOrEmpty(assessmentId))
                {
                    if (string.IsNullOrEmpty(courseId))
                    {
                        courseId = GetCourseIdFromAssessment(assessmentId);
                        hdnCourseId.Value = courseId;
                    }
                    BindModules(courseId);
                    LoadAssessment(assessmentId);
                }
                else
                {
                    BindModules(courseId);
                    hdnEasyCount.Value = "8";
                    hdnMediumCount.Value = "8";
                    hdnHardCount.Value = "4";
                    hdnTimeLimitMinutes.Value = "60";
                    hdnShuffleQuestions.Value = "true";
                    hdnRequireQuizPass.Value = "false";
                    RenderDonutChart(8, 8, 4);
                    RegisterCompositionScript(8, 8, 4, 60, true, false);
                }
            }
        }

        private string GetCourseIdFromAssessment(string assessmentId)
        {
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(
                    "SELECT courseID FROM dbo.assessmentTable WHERE assessmentID=@aid", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    conn.Open();
                    return cmd.ExecuteScalar()?.ToString() ?? "";
                }
            }
            catch { return ""; }
        }

        private void BindModules(string courseId)
        {
            string sql = string.IsNullOrEmpty(courseId)
                ? "SELECT moduleID, moduleTitle FROM dbo.moduleTable ORDER BY moduleTitle"
                : "SELECT moduleID, moduleTitle FROM dbo.moduleTable WHERE courseID=@cid ORDER BY moduleTitle";
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(courseId))
                        cmd.Parameters.AddWithValue("@cid", courseId);
                    conn.Open();
                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);
                    ddlTargetModule.Items.Clear();
                    ddlTargetModule.Items.Add(new ListItem("-- Select a Module --", ""));
                    foreach (DataRow row in dt.Rows)
                        ddlTargetModule.Items.Add(
                            new ListItem(row["moduleTitle"]?.ToString() ?? "",
                                         row["moduleID"]?.ToString() ?? ""));
                }
            }
            catch (Exception ex) { ShowAlert("Error loading modules: " + ex.Message); }
        }

        private void LoadAssessment(string assessmentId)
        {
            // Now reads shuffleQuestions from DB
            const string sql = @"
                SELECT moduleID, title, timeLimitMinutes, isPublished,
                       ISNULL(shuffleQuestions, 0) AS shuffleQuestions
                FROM   dbo.assessmentTable
                WHERE  assessmentID = @id";
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", assessmentId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            txtTemplateName.Text = r["title"]?.ToString() ?? "";

                            string moduleId = r["moduleID"]?.ToString() ?? "";
                            var li = ddlTargetModule.Items.FindByValue(moduleId);
                            if (li != null) ddlTargetModule.SelectedValue = moduleId;

                            hdnTimeLimitMinutes.Value = r["timeLimitMinutes"] == DBNull.Value
                                ? "60" : r["timeLimitMinutes"].ToString();

                            hdnIsPublished.Value = r["isPublished"] == DBNull.Value
                                ? "false"
                                : Convert.ToBoolean(r["isPublished"]).ToString().ToLowerInvariant();

                            // Load shuffle from DB
                            bool shuffle = r["shuffleQuestions"] != DBNull.Value
                                           && Convert.ToBoolean(r["shuffleQuestions"]);
                            hdnShuffleQuestions.Value = shuffle ? "true" : "false";
                        }
                        else
                        {
                            ShowAlert("Assessment not found.");
                            return;
                        }
                    }
                }
                LoadDifficultyComposition(assessmentId);
            }
            catch (Exception ex) { ShowAlert("Error loading assessment: " + ex.Message); }
        }

        private void LoadDifficultyComposition(string assessmentId)
        {
            const string sql = @"
                SELECT
                    SUM(CASE WHEN points <= 5              THEN 1 ELSE 0 END) AS easy,
                    SUM(CASE WHEN points > 5 AND points<=10 THEN 1 ELSE 0 END) AS medium,
                    SUM(CASE WHEN points > 10              THEN 1 ELSE 0 END) AS hard
                FROM dbo.questionTable WHERE assessmentID=@id";
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", assessmentId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            int easy = r["easy"] == DBNull.Value ? 0 : Convert.ToInt32(r["easy"]);
                            int medium = r["medium"] == DBNull.Value ? 0 : Convert.ToInt32(r["medium"]);
                            int hard = r["hard"] == DBNull.Value ? 0 : Convert.ToInt32(r["hard"]);
                            if (easy + medium + hard == 0) { easy = 8; medium = 8; hard = 4; }

                            hdnEasyCount.Value = easy.ToString();
                            hdnMediumCount.Value = medium.ToString();
                            hdnHardCount.Value = hard.ToString();

                            RenderDonutChart(easy, medium, hard);
                            RegisterCompositionScript(
                                easy, medium, hard,
                                SafeInt(hdnTimeLimitMinutes.Value, 60),
                                hdnShuffleQuestions.Value == "true",
                                hdnRequireQuizPass.Value == "true");
                            return;
                        }
                    }
                }
            }
            catch { /* fall through */ }

            hdnEasyCount.Value = "8"; hdnMediumCount.Value = "8"; hdnHardCount.Value = "4";
            RenderDonutChart(8, 8, 4);
            RegisterCompositionScript(8, 8, 4, SafeInt(hdnTimeLimitMinutes.Value, 60),
                hdnShuffleQuestions.Value == "true", hdnRequireQuizPass.Value == "true");
        }

        protected void ddlTargetModule_SelectedIndexChanged(object sender, EventArgs e)
        {
            string moduleId = ddlTargetModule.SelectedValue;
            if (string.IsNullOrEmpty(moduleId))
            {
                hdnEasyCount.Value = "8"; hdnMediumCount.Value = "8"; hdnHardCount.Value = "4";
                RenderDonutChart(8, 8, 4);
                RegisterCompositionScript(8, 8, 4, SafeInt(hdnTimeLimitMinutes.Value, 60),
                    hdnShuffleQuestions.Value == "true", hdnRequireQuizPass.Value == "true");
                return;
            }

            const string sql = @"
                SELECT
                    SUM(CASE WHEN q.points <= 5              THEN 1 ELSE 0 END) AS easy,
                    SUM(CASE WHEN q.points > 5 AND q.points<=10 THEN 1 ELSE 0 END) AS medium,
                    SUM(CASE WHEN q.points > 10              THEN 1 ELSE 0 END) AS hard
                FROM dbo.questionTable q
                JOIN dbo.assessmentTable a ON a.assessmentID = q.assessmentID
                WHERE a.moduleID = @mid";
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@mid", moduleId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            int easy = r["easy"] == DBNull.Value ? 0 : Convert.ToInt32(r["easy"]);
                            int medium = r["medium"] == DBNull.Value ? 0 : Convert.ToInt32(r["medium"]);
                            int hard = r["hard"] == DBNull.Value ? 0 : Convert.ToInt32(r["hard"]);
                            if (easy + medium + hard == 0) { easy = 8; medium = 8; hard = 4; }

                            hdnEasyCount.Value = easy.ToString();
                            hdnMediumCount.Value = medium.ToString();
                            hdnHardCount.Value = hard.ToString();

                            RenderDonutChart(easy, medium, hard);
                            RegisterCompositionScript(
                                easy, medium, hard,
                                SafeInt(hdnTimeLimitMinutes.Value, 60),
                                hdnShuffleQuestions.Value == "true",
                                hdnRequireQuizPass.Value == "true");
                            return;
                        }
                    }
                }
            }
            catch { /* fall through */ }

            hdnEasyCount.Value = "8"; hdnMediumCount.Value = "8"; hdnHardCount.Value = "4";
            RenderDonutChart(8, 8, 4);
            RegisterCompositionScript(8, 8, 4, SafeInt(hdnTimeLimitMinutes.Value, 60),
                hdnShuffleQuestions.Value == "true", hdnRequireQuizPass.Value == "true");
        }

        protected void btnSaveConfig_Click(object sender, EventArgs e)
        {
            string courseId = hdnCourseId.Value.Trim();
            string assessmentId = hdnAssessmentId.Value.Trim();
            string createdBy = hdnCreatedBy.Value.Trim();
            string title = txtTemplateName.Text.Trim();
            string moduleId = ddlTargetModule.SelectedValue.Trim();

            int timeLimit = SafeInt(hdnTimeLimitMinutes.Value, 60);
            int easy = SafeInt(hdnEasyCount.Value, 0);
            int medium = SafeInt(hdnMediumCount.Value, 0);
            int hard = SafeInt(hdnHardCount.Value, 0);
            // Read shuffle from hidden field
            bool shuffle = hdnShuffleQuestions.Value == "true";

            if (easy + medium + hard == 0)
            { ShowAlert("Please set at least one question count."); return; }
            if (string.IsNullOrWhiteSpace(title))
            { ShowAlert("Please enter a template name."); return; }
            if (string.IsNullOrWhiteSpace(moduleId))
            { ShowAlert("Please select a target module."); return; }
            if (string.IsNullOrWhiteSpace(courseId))
            { ShowAlert("Course ID is missing."); return; }
            if (string.IsNullOrWhiteSpace(createdBy))
            { ShowAlert("Session expired. Please log in again."); return; }

            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            if (string.IsNullOrEmpty(assessmentId))
                            {
                                assessmentId = GenerateAssessmentId(conn, tx);

                                // INSERT includes shuffleQuestions
                                using (var cmd = new SqlCommand(@"
                                    INSERT INTO dbo.assessmentTable
                                        (assessmentID, courseID, moduleID, title, description,
                                         timeLimitMinutes, totalMarks, passingScore,
                                         isPublished, shuffleQuestions, createdBy, createdAt)
                                    VALUES
                                        (@aid, @cid, @mid, @title, NULL,
                                         @time, 0, 0, 0, @shuffle, @createdBy, SYSUTCDATETIME())",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                                    cmd.Parameters.AddWithValue("@cid", courseId);
                                    cmd.Parameters.AddWithValue("@mid", moduleId);
                                    cmd.Parameters.AddWithValue("@title", title);
                                    cmd.Parameters.AddWithValue("@time", timeLimit);
                                    cmd.Parameters.AddWithValue("@shuffle", shuffle);
                                    cmd.Parameters.AddWithValue("@createdBy", createdBy);
                                    cmd.ExecuteNonQuery();
                                }
                                hdnAssessmentId.Value = assessmentId;
                            }
                            else
                            {
                                // UPDATE includes shuffleQuestions
                                using (var cmd = new SqlCommand(@"
                                    UPDATE dbo.assessmentTable
                                    SET    moduleID         = @mid,
                                           title            = @title,
                                           timeLimitMinutes = @time,
                                           shuffleQuestions = @shuffle,
                                           updatedAt        = SYSUTCDATETIME()
                                    WHERE  assessmentID = @aid",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@mid", moduleId);
                                    cmd.Parameters.AddWithValue("@title", title);
                                    cmd.Parameters.AddWithValue("@time", timeLimit);
                                    cmd.Parameters.AddWithValue("@shuffle", shuffle);
                                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            tx.Commit();
                        }
                        catch (Exception inner)
                        {
                            tx.Rollback();
                            throw new Exception("DB error: " + inner.Message, inner);
                        }
                    }
                }

                Response.Redirect(
                    "assessmentTemplateStep2.aspx" +
                    "?assessmentId=" + HttpUtility.UrlEncode(assessmentId) +
                    "&courseId=" + HttpUtility.UrlEncode(courseId) +
                    "&easy=" + easy +
                    "&medium=" + medium +
                    "&hard=" + hard +
                    "&title=" + HttpUtility.UrlEncode(title),
                    false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex) { ShowAlert("Error saving: " + ex.Message); }
        }

        private string GenerateAssessmentId(SqlConnection conn, SqlTransaction tx)
        {
            const string sql = @"
                SELECT ISNULL(
                    MAX(TRY_CAST(SUBSTRING(assessmentID,2,LEN(assessmentID)-1) AS INT)), 0
                ) + 1
                FROM dbo.assessmentTable
                WHERE assessmentID LIKE 'A%'
                  AND LEN(assessmentID) BETWEEN 2 AND 10
                  AND TRY_CAST(SUBSTRING(assessmentID,2,LEN(assessmentID)-1) AS INT) IS NOT NULL";
            using (var cmd = new SqlCommand(sql, conn, tx))
                return "A" + Convert.ToInt32(cmd.ExecuteScalar()).ToString("D3");
        }

        private void RenderDonutChart(int easy, int medium, int hard)
        {
            int total = easy + medium + hard;
            if (total == 0) total = 1;
            double C = 2 * Math.PI * 40;
            double ea = (double)easy / total * C;
            double ma = (double)medium / total * C;
            double ha = (double)hard / total * C;
            string c = C.ToString("F1", CultureInfo.InvariantCulture);
            string e = ea.ToString("F1", CultureInfo.InvariantCulture);
            string m = ma.ToString("F1", CultureInfo.InvariantCulture);
            string h = ha.ToString("F1", CultureInfo.InvariantCulture);
            string em = (ea + ma).ToString("F1", CultureInfo.InvariantCulture);

            litDonutChart.Text = $@"
<svg class='rotate-[-90deg] size-full donut-chart' viewBox='0 0 100 100'>
    <circle cx='50' cy='50' fill='transparent' r='40' stroke='#84cc16'
            stroke-dasharray='{e} {c}' stroke-dashoffset='0'
            stroke-width='20' class='donut-circle'></circle>
    <circle cx='50' cy='50' fill='transparent' r='40' stroke='#2563eb'
            stroke-dasharray='{m} {c}' stroke-dashoffset='-{e}'
            stroke-width='20' class='donut-circle'></circle>
    <circle cx='50' cy='50' fill='transparent' r='40' stroke='#f9d006'
            stroke-dasharray='{h} {c}' stroke-dashoffset='-{em}'
            stroke-width='20' class='donut-circle'></circle>
</svg>";
        }

        private void RegisterCompositionScript(int easy, int medium, int hard,
                                               int timeLimit, bool shuffle, bool requireQuizPass)
        {
            string js = $@"
                setCompositionValues({easy}, {medium}, {hard});
                var t = document.getElementById('txtTimeLimit');
                if (t) t.value = {timeLimit};
                var titleMain  = document.getElementById('{txtTemplateName.ClientID}');
                var titleRight = document.getElementById('rightPanelTitle');
                if (titleMain && titleRight) titleRight.value = titleMain.value || '';
                setToggleState('btnShuffleToggle','{hdnShuffleQuestions.ClientID}',{shuffle.ToString().ToLowerInvariant()},'lime');
            ";
            ScriptManager.RegisterStartupScript(
                this, GetType(),
                "syncAssessmentUi_" + Guid.NewGuid().ToString("N"),
                js, true);
        }

        private int SafeInt(string value, int fallback) =>
            int.TryParse(value, out int r) ? r : fallback;

        private void ShowAlert(string message)
        {
            string safe = (message ?? "")
                .Replace("\\", "\\\\").Replace("'", "\\'")
                .Replace("\r", "").Replace("\n", " ");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "alert_" + Guid.NewGuid().ToString("N"), $"alert('{safe}');", true);
        }
    }
}
