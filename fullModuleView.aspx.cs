using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class fullModuleView : System.Web.UI.Page
    {
        private readonly string connectionString =
            System.Configuration.ConfigurationManager
                  .ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth guard is in Teacher.master.cs
            if (!IsPostBack)
            {
                string courseId = (Request.QueryString["courseId"] ?? "").Trim();
                if (string.IsNullOrWhiteSpace(courseId))
                {
                    Response.Redirect("~/courselistDashboard.aspx");
                    return;
                }

                LoadCourseHeader(courseId);
                BindModules(courseId);
            }
        }

        // Course header
        private void LoadCourseHeader(string courseId)
        {
            DataTable dt = GetCourseData(courseId);
            if (dt.Rows.Count == 0) return;

            DataRow row = dt.Rows[0];
            litCourseName.Text = HttpUtility.HtmlEncode(row["CourseName"].ToString());
            litCourseSubtitle.Text = HttpUtility.HtmlEncode(row["CourseSubtitle"].ToString());
            litModuleCount.Text = row["ModuleCount"].ToString();
            litTotalItems.Text = row["TotalItems"].ToString();

            lnkCourseDetail.NavigateUrl =
                "~/courseDetail.aspx?id=" + HttpUtility.UrlEncode(courseId);
        }

        private DataTable GetCourseData(string courseId)
        {
            const string sql = @"
                SELECT
                    c.courseName                                              AS CourseName,
                    ISNULL(c.description, '')                                 AS CourseSubtitle,
                    (SELECT COUNT(*)
                     FROM   dbo.moduleTable
                     WHERE  courseID = c.courseID)                            AS ModuleCount,
                    (SELECT COUNT(*)
                     FROM   dbo.moduleBlockTable mb
                     JOIN   dbo.moduleTable      m  ON m.moduleID = mb.moduleID
                     WHERE  m.courseID = c.courseID)                          AS TotalItems
                FROM  dbo.courseTable c
                WHERE c.courseID = @cid;";

            var dt = new DataTable();
            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            using (var da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@cid", courseId);
                da.Fill(dt);
            }
            return dt;
        }

        // Modules repeater
        private void BindModules(string courseId)
        {
            var dt = GetModulesData(courseId);
            rptModules.DataSource = dt;
            rptModules.DataBind();
            pnlNoModules.Visible = (dt.Rows.Count == 0);

        }

        private DataTable GetModulesData(string courseId)
        {
            const string sql = @"
                SELECT
                    m.moduleID,
                    m.courseID,
                    m.moduleTitle,
                    m.isPreviewable,
                    m.status,
                    (SELECT COUNT(*)
                     FROM   dbo.moduleBlockTable mb
                     WHERE  mb.moduleID = m.moduleID) AS ItemCount
                FROM  dbo.moduleTable m
                WHERE m.courseID = @cid
                ORDER BY TRY_CAST(SUBSTRING(m.moduleID, 2, 10) AS INT);";

            var dt = new DataTable();
            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            using (var da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@cid", courseId);
                da.Fill(dt);
            }
            return dt;
        }

        // ADD MODULE
        protected void btnSaveModule_Click(object sender, EventArgs e)
        {
            string courseId = (Request.QueryString["courseId"] ?? "").Trim();
            string title = (txtNewModuleTitle.Text ?? "").Trim();
            string status = ddlNewModuleStatus.SelectedValue;

            if (string.IsNullOrWhiteSpace(title))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                    "showToast('Please enter a module title.', 'error');", true);
                return;
            }

            string newModuleId = null;

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction(IsolationLevel.Serializable))
                {
                    try
                    {
                        using (var cmd = new SqlCommand(@"
                            SELECT ISNULL(
                                MAX(CAST(SUBSTRING(moduleID, 2, LEN(moduleID)-1) AS INT)), 0)
                            FROM   dbo.moduleTable
                            WHERE  moduleID LIKE 'M[0-9]%';", conn, tx))
                        {
                            int maxNum = Convert.ToInt32(cmd.ExecuteScalar());
                            newModuleId = "M" + (maxNum + 1).ToString("D3");
                        }

                        using (var cmd = new SqlCommand(@"
                            INSERT INTO dbo.moduleTable
                                (moduleID, courseID, moduleTitle, Status, isPreviewable)
                            VALUES
                                (@moduleID, @courseID, @title, @status, 0);", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@moduleID", newModuleId);
                            cmd.Parameters.AddWithValue("@courseID", courseId);
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@status", status);
                            cmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                            "showToast('Failed to create module. Please try again.', 'error');", true);
                        return;
                    }
                }
            }

            Response.Redirect(
                "~/moduleBuilder.aspx?id=" + Uri.EscapeDataString(newModuleId) +
                "&courseId=" + Uri.EscapeDataString(courseId));
        }

        // EDIT MODULE
        protected void btnSaveEditModule_Click(object sender, EventArgs e)
        {
            string moduleId = hdnEditModuleId.Value;
            string title = (txtEditModuleTitle.Text ?? "").Trim();
            string status = ddlEditModuleStatus.SelectedValue;

            if (string.IsNullOrWhiteSpace(title))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                    "showToast('Please enter a module title.', 'error');", true);
                return;
            }

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                UPDATE dbo.moduleTable
                SET    moduleTitle = @title,
                       status      = @status
                WHERE  moduleID    = @mid;", conn))
            {
                cmd.Parameters.AddWithValue("@title", title);
                cmd.Parameters.AddWithValue("@status", status);
                cmd.Parameters.AddWithValue("@mid", moduleId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ScriptManager.RegisterStartupScript(this, GetType(), "afterSave",
                "closeEditModuleModal(); showToast('Module updated successfully.');", true);

            BindModules(Request.QueryString["courseId"] ?? "");
        }

        // DELETE MODULE (cascade)
        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string moduleId = hdnDeleteModuleId.Value;
            string courseId = (Request.QueryString["courseId"] ?? "").Trim();

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Block content (deepest FK)
                        Exec(conn, tx, @"
                            DELETE bc FROM dbo.blockContentTable bc
                            JOIN   dbo.moduleBlockTable mb ON mb.blockID = bc.blockID
                            WHERE  mb.moduleID = @mid;", moduleId);

                        // 2. Module blocks
                        Exec(conn, tx,
                            "DELETE FROM dbo.moduleBlockTable WHERE moduleID = @mid;",
                            moduleId);

                        // 3. Access rules (FK ? moduleTable)
                        Exec(conn, tx,
                            "DELETE FROM dbo.moduleAccessRuleTable WHERE moduleID = @mid;",
                            moduleId);

                        // 4. Module itself
                        Exec(conn, tx,
                            "DELETE FROM dbo.moduleTable WHERE moduleID = @mid;",
                            moduleId);

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                            "showToast('Failed to delete module.', 'error');", true);
                        return;
                    }
                }
            }

            ScriptManager.RegisterStartupScript(this, GetType(), "afterDelete",
                "closeDeleteModal(); showToast('Module deleted successfully.');", true);

            BindModules(courseId);
        }

        private static void Exec(SqlConnection conn, SqlTransaction tx, string sql, string moduleId)
        {
            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@mid", moduleId);
                cmd.ExecuteNonQuery();
            }
        }

        // Repeater: module row
        protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row = (DataRowView)e.Item.DataItem;
            var lit = (Literal)e.Item.FindControl("litModuleRow");

            string moduleId = HttpUtility.HtmlEncode(row["moduleID"].ToString());
            string title = HttpUtility.HtmlEncode(row["moduleTitle"].ToString());
            string status = (row["status"]?.ToString() ?? "").ToLower();
            string itemCount = row["ItemCount"] != DBNull.Value
                                ? row["ItemCount"].ToString() : "0";
            string jsTitle = HttpUtility.JavaScriptStringEncode(row["moduleTitle"].ToString());
            string courseId = HttpUtility.HtmlEncode(
                                Request.QueryString["courseId"] ?? "");
            string builderUrl = "moduleBuilder.aspx?id=" + moduleId + "&courseId=" + courseId;

            // Visual classes by status
            string barClass, rowClass, badgeClass, badgeLabel;
            switch (status)
            {
                case "current":
                    barClass = "bar-blue"; rowClass = "module-row is-active";
                    badgeClass = "badge badge-blue"; badgeLabel = "Currently Active"; break;
                case "active":
                    barClass = "bar-green"; rowClass = "module-row";
                    badgeClass = "badge badge-green"; badgeLabel = "Active"; break;
                case "drafting":
                    barClass = "bar-yellow"; rowClass = "module-row is-drafting";
                    badgeClass = "badge badge-yellow"; badgeLabel = "Drafting"; break;
                default:
                    barClass = "bar-gray"; rowClass = "module-row is-locked";
                    badgeClass = "badge badge-gray"; badgeLabel = "Locked"; break;
            }

            string opacity = status == "locked" ? "opacity-40" : "";
            string countColor = status == "current"
                ? "text-math-blue font-black" : "font-black text-math-dark-blue";

            string actionButtons = status == "locked"
                ? $@"<button type=""button"" onclick=""openEditModuleModal('{moduleId}','{jsTitle}','{status}')"" class=""action-btn lock"" title=""Unlock Module""><span class=""material-symbols-outlined text-lg"">lock_open</span></button>
                     <button type=""button"" onclick=""openDeleteModal('{moduleId}','{jsTitle}')"" class=""action-btn del"" title=""Delete""><span class=""material-symbols-outlined text-lg"">delete</span></button>"
                : $@"<button type=""button"" onclick=""openEditModuleModal('{moduleId}','{jsTitle}','{status}')"" class=""action-btn edit"" title=""Edit""><span class=""material-symbols-outlined text-lg"">edit</span></button>
                     <button type=""button"" onclick=""window.location.href='{builderUrl}'"" class=""action-btn view"" title=""Open Module Builder""><span class=""material-symbols-outlined text-lg"">grid_view</span></button>
                     <button type=""button"" onclick=""openDeleteModal('{moduleId}','{jsTitle}')"" class=""action-btn del"" title=""Delete""><span class=""material-symbols-outlined text-lg"">delete</span></button>";

            lit.Text = $@"
<div class=""{rowClass} p-6 flex flex-col md:flex-row items-center gap-6"">
    <div class=""status-bar {barClass}""></div>
    <div class=""flex-1 pl-3 {opacity}"">
        <div class=""flex items-center gap-3 mb-1"">
            <span class=""text-[10px] font-black uppercase tracking-widest text-gray-400"">{moduleId}</span>
            <span class=""{badgeClass}"">{badgeLabel}</span>
        </div>
        <h3 class=""text-xl font-black text-math-dark-blue"">{title}</h3>
    </div>
    <div class=""flex items-center gap-8 pr-2"">
        <div class=""text-center {opacity}"">
            <span class=""block text-sm {countColor}"">{itemCount} Items</span>
            <span class=""text-[10px] font-black uppercase tracking-widest text-gray-400"">Content</span>
        </div>
        <div class=""flex items-center gap-2"">
            {actionButtons}
        </div>
    </div>
</div>";
        }
    }
}
