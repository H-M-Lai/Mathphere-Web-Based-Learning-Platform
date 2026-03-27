using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Assignment
{
    public partial class BrowseModule : Page
    {
        private string CS => ConfigurationManager
            .ConnectionStrings["MathSphereDB"].ConnectionString;

        public bool IsGuest =>
            Session["IsGuest"] is bool b && b &&
            string.IsNullOrEmpty((Session["UserID"] ?? Session["userID"])?.ToString()?.Trim());

        private string CurrentUserId =>
            (Session["UserID"] ?? Session["userID"])?.ToString()?.Trim();

        public string SelectedCourseID { get; private set; } = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsGuest && string.IsNullOrEmpty(CurrentUserId))
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                if (IsGuest)
                {
                    pnlGuestBanner.Visible = true;
                    pnlCourseFilters.Visible = false;
                    hfSelectedCourse.Value = "";
                    SelectedCourseID = "";
                    LoadGuestModules("");
                }
                else
                {
                    pnlGuestBanner.Visible = false;
                    pnlCourseFilters.Visible = true;
                    hfSelectedCourse.Value = "";
                    SelectedCourseID = "";
                    LoadCourseFilters();
                    ApplyCourseFilterState();
                    LoadModules("", "");
                }
            }
            else
            {
                SelectedCourseID = hfSelectedCourse.Value ?? "";
            }
        }

        // Guest: no progress, no enrolment check
        private void LoadGuestModules(string search)
        {
            const string sql = @"
                SELECT
                    m.moduleID,
                    m.moduleTitle,
                    CAST(m.isPreviewable AS BIT) AS IsPreviewable,
                    c.courseName,
                    CASE WHEN m.isPreviewable = 1 THEN 'Preview Available' ELSE 'Members Only' END AS PreviewText,
                    CASE
                        WHEN LOWER(c.courseName) LIKE '%algebra%'   THEN 'calculate'
                        WHEN LOWER(c.courseName) LIKE '%geometry%'  THEN 'pentagon'
                        WHEN LOWER(c.courseName) LIKE '%calculus%'  THEN 'functions'
                        WHEN LOWER(c.courseName) LIKE '%statistic%' THEN 'bar_chart'
                        WHEN LOWER(c.courseName) LIKE '%trigon%'    THEN 'change_history'
                        ELSE 'school'
                    END AS Icon,
                    0 AS Progress
                FROM  dbo.moduleTable m
                JOIN  dbo.courseTable c ON c.courseID = m.courseID
                WHERE m.Status = 'Active'
                  AND c.status = 'Active'
                  AND (@s = '' OR m.moduleTitle LIKE '%' + @s + '%')
                ORDER BY m.isPreviewable DESC, c.courseName ASC, m.moduleTitle ASC";

            BindModules(sql, cmd => cmd.Parameters.AddWithValue("@s", search ?? ""));
        }

        // Logged-in: enrolled modules + previewable modules
        // Enrolled modules show live progress from studentBlockProgressTable.
        // Previewable modules are shown to ALL logged-in students even without
        // enrolment — shown at 0% (no course assignment needed).
        // Non-previewable, non-enrolled modules stay hidden.
        private void LoadModules(string search, string courseId)
        {
            const string sql = @"
                -- Part 1: modules the student IS enrolled in (any visibility)
                SELECT
                    m.moduleID,
                    m.moduleTitle,
                    CAST(m.isPreviewable AS BIT) AS IsPreviewable,
                    c.courseName,
                    c.courseID,
                    CASE WHEN m.isPreviewable=1 THEN 'Preview Available' ELSE '' END AS PreviewText,
                    CASE
                        WHEN LOWER(c.courseName) LIKE '%algebra%'   THEN 'calculate'
                        WHEN LOWER(c.courseName) LIKE '%geometry%'  THEN 'pentagon'
                        WHEN LOWER(c.courseName) LIKE '%calculus%'  THEN 'functions'
                        WHEN LOWER(c.courseName) LIKE '%statistic%' THEN 'bar_chart'
                        WHEN LOWER(c.courseName) LIKE '%trigon%'    THEN 'change_history'
                        ELSE 'school'
                    END AS Icon,
                    ISNULL((
                        SELECT CAST(ROUND(
                            CAST(SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) AS float)
                            / NULLIF(COUNT(mb.blockID),0) * 100
                        ,0) AS int)
                        FROM  dbo.moduleBlockTable mb
                        LEFT JOIN dbo.studentBlockProgressTable sbp
                               ON sbp.blockID=mb.blockID AND sbp.userID=@uid
                        WHERE mb.moduleID=m.moduleID
                    ),0) AS Progress
                FROM  dbo.moduleTable           m
                JOIN  dbo.courseTable           c  ON c.courseID=m.courseID
                JOIN  dbo.studentEnrolmentTable se ON se.courseID=c.courseID
                                                  AND se.userID=@uid
                                                  AND se.enrolStatus=1
                WHERE m.Status='Active' AND c.status='Active'
                  AND (@s=''   OR m.moduleTitle LIKE '%'+@s+'%')
                  AND (@cid='' OR c.courseID=@cid)

                UNION

                -- Part 2: previewable modules the student is NOT enrolled in
                SELECT
                    m.moduleID,
                    m.moduleTitle,
                    CAST(1 AS BIT)       AS IsPreviewable,
                    c.courseName,
                    c.courseID,
                    'Preview Available'  AS PreviewText,
                    CASE
                        WHEN LOWER(c.courseName) LIKE '%algebra%'   THEN 'calculate'
                        WHEN LOWER(c.courseName) LIKE '%geometry%'  THEN 'pentagon'
                        WHEN LOWER(c.courseName) LIKE '%calculus%'  THEN 'functions'
                        WHEN LOWER(c.courseName) LIKE '%statistic%' THEN 'bar_chart'
                        WHEN LOWER(c.courseName) LIKE '%trigon%'    THEN 'change_history'
                        ELSE 'school'
                    END AS Icon,
                    0 AS Progress
                FROM  dbo.moduleTable m
                JOIN  dbo.courseTable c ON c.courseID=m.courseID
                WHERE m.Status='Active' AND c.status='Active'
                  AND m.isPreviewable=1
                  AND (@s=''   OR m.moduleTitle LIKE '%'+@s+'%')
                  AND (@cid='' OR c.courseID=@cid)
                  AND NOT EXISTS (
                      SELECT 1 FROM dbo.studentEnrolmentTable se2
                      WHERE se2.courseID=c.courseID
                        AND se2.userID=@uid
                        AND se2.enrolStatus=1
                  )

                ORDER BY 4 ASC, 2 ASC";

            BindModules(sql, cmd =>
            {
                cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                cmd.Parameters.AddWithValue("@s", search ?? "");
                cmd.Parameters.AddWithValue("@cid", courseId ?? "");
            });
        }

        private void BindModules(string sql, Action<SqlCommand> paramBinder)
        {
            var dt = new DataTable();
            try
            {
                using (var conn = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    paramBinder(cmd);
                    conn.Open();
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex)
            {
                litDbError.Text = "<p class=\"text-red-500 font-bold p-4\">DB Error: " + System.Web.HttpUtility.HtmlEncode(ex.Message) + "</p>";
                litDbError.Visible = true;
                rptModules.DataSource = dt;
                rptModules.DataBind();
                pnlEmptyState.Visible = false;
                return;
            }

            rptModules.DataSource = dt;
            rptModules.DataBind();
            pnlEmptyState.Visible = (dt.Rows.Count == 0);
        }

        private void LoadCourseFilters()
        {
            const string sql = @"
                SELECT DISTINCT c.courseID, c.courseName
                FROM  dbo.courseTable           c
                JOIN  dbo.studentEnrolmentTable se ON  se.courseID = c.courseID
                                                   AND se.userID   = @uid
                                                   AND se.enrolStatus = 1
                WHERE c.status = 'Active'
                ORDER BY c.courseName ASC";

            var dt = new DataTable();
            try
            {
                using (var conn = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                    conn.Open();
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch { /* non-fatal */ }

            rptCourseFilters.DataSource = dt;
            rptCourseFilters.DataBind();
        }
        private void ApplyCourseFilterState()
        {
            string allTopicsClass = string.IsNullOrEmpty(SelectedCourseID)
                ? "course-filter-btn active"
                : "course-filter-btn";
            btnAllTopics.CssClass = allTopicsClass;
            btnAllTopics.Attributes["class"] = allTopicsClass;

            foreach (RepeaterItem item in rptCourseFilters.Items)
            {
                var btn = item.FindControl("btnCourseFilter") as Button;
                if (btn == null) continue;

                string courseId = (btn.CommandArgument ?? string.Empty).Trim();
            btn.Attributes["data-course-id"] = courseId;
            btn.OnClientClick = "return browseApplyFilterState(this, '" + courseId.Replace("'", "\\'") + "');";
            string courseClass = string.Equals(courseId, SelectedCourseID ?? string.Empty, StringComparison.OrdinalIgnoreCase)
                ? "course-filter-btn active"
                : "course-filter-btn";
            btn.CssClass = courseClass;
            btn.Attributes["class"] = courseClass;
            }
        }


        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SelectedCourseID = hfSelectedCourse.Value ?? "";
            if (!IsGuest)
            {
                LoadCourseFilters();
                ApplyCourseFilterState();
            }
            if (IsGuest) LoadGuestModules(txtSearch.Text.Trim());
            else LoadModules(txtSearch.Text.Trim(), SelectedCourseID);
        }

        protected void btnCourse_Click(object sender, EventArgs e)
        {
            SelectedCourseID = "";
            hfSelectedCourse.Value = "";
            LoadCourseFilters();
            ApplyCourseFilterState();
            LoadModules(txtSearch.Text.Trim(), "");
        }

        protected void rptCourseFilters_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "FilterByCourse") return;
            SelectedCourseID = e.CommandArgument?.ToString() ?? "";
            hfSelectedCourse.Value = SelectedCourseID;
            LoadCourseFilters();
            ApplyCourseFilterState();
            LoadModules(txtSearch.Text.Trim(), SelectedCourseID);
        }


        protected void rptCourseFilters_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var btn = e.Item.FindControl("btnCourseFilter") as Button;
            if (btn == null) return;

            string courseId = (btn.CommandArgument ?? string.Empty).Trim();
            btn.Attributes["data-course-id"] = courseId;
            btn.OnClientClick = "return browseApplyFilterState(this, '" + courseId.Replace("'", "\\'") + "');";
            btn.Attributes["class"] = string.Equals(courseId, SelectedCourseID ?? string.Empty, StringComparison.OrdinalIgnoreCase)
                ? "course-filter-btn active"
                : "course-filter-btn";
        }
        protected void rptModules_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "StartMission" || IsGuest) return;
            string moduleId = e.CommandArgument?.ToString().Trim();
            if (!string.IsNullOrEmpty(moduleId))
            {
                Response.Redirect(
                    "~/moduleOverview.aspx?moduleId=" + Uri.EscapeDataString(moduleId), false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }
    }
}








