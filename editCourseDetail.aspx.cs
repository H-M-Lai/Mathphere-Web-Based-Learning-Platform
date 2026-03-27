using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace MathSphere
{
    public partial class editCourseDetail : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Must be logged in
            if (Session["userID"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string courseId = Request.QueryString["id"];
                if (string.IsNullOrWhiteSpace(courseId))
                {
                    Response.Redirect("courselistDashboard.aspx");
                    return;
                }

                hdnCourseId.Value = courseId;
                LoadCourseData(courseId);
            }
        }

        private void LoadCourseData(string courseId)
        {
            string teacherId = Session["userID"].ToString();

            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT courseID, courseName, description, createdAt, endAt, status
                FROM dbo.courseTable
                WHERE courseID = @courseId
                  AND teacherID = @teacherId;", conn))
            {
                cmd.Parameters.AddWithValue("@courseId", courseId);
                cmd.Parameters.AddWithValue("@teacherId", teacherId);

                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read())
                    {
                        // Not found OR not owned by this teacher
                        Response.Redirect("courselistDashboard.aspx");
                        return;
                    }

                    txtCourseId.Text = r["courseID"].ToString();
                    txtCourseName.Text = r["courseName"].ToString();
                    txtDescription.Text = r["description"] == DBNull.Value ? "" : r["description"].ToString();

                    // For HTML date input: yyyy-MM-dd
                    DateTime createdAt = Convert.ToDateTime(r["createdAt"]);
                    DateTime endAt = Convert.ToDateTime(r["endAt"]);

                    txtStartDate.Text = createdAt.ToString("yyyy-MM-dd"); // display only
                    txtEndDate.Text = endAt.ToString("yyyy-MM-dd");       // editable
                }
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            string teacherId = Session["userID"].ToString();

            string courseId = hdnCourseId.Value;
            string courseName = txtCourseName.Text.Trim();
            string description = txtDescription.Text.Trim();
            string endStr = txtEndDate.Text.Trim();

            // validation
            if (string.IsNullOrWhiteSpace(courseName))
            {
                pnlValidation.Visible = true;
                lblValidation.Text = "Course name is required.";
                pnlSuccess.Visible = false;
                return;
            }

            if (string.IsNullOrWhiteSpace(endStr))
            {
                pnlValidation.Visible = true;
                lblValidation.Text = "End date is required.";
                pnlSuccess.Visible = false;
                return;
            }

            if (!DateTime.TryParse(endStr, out DateTime newEndAt))
            {
                pnlValidation.Visible = true;
                lblValidation.Text = "Invalid end date.";
                pnlSuccess.Visible = false;
                return;
            }

            // Optional: prevent end date earlier than createdAt
            DateTime createdAt;
            if (!TryGetCreatedAtOwned(courseId, teacherId, out createdAt))
            {
                Response.Redirect("courselistDashboard.aspx");
                return;
            }

            if (newEndAt.Date < createdAt.Date)
            {
                pnlValidation.Visible = true;
                lblValidation.Text = "End date must be after the start date.";
                pnlSuccess.Visible = false;
                return;
            }

            pnlValidation.Visible = false;

            // update
            bool ok = UpdateCourse(courseId, teacherId, courseName, description, newEndAt);

            if (!ok)
            {
                pnlValidation.Visible = true;
                lblValidation.Text = "Update failed. Course may not exist or you don't have permission.";
                pnlSuccess.Visible = false;
                return;
            }

            Response.Redirect("courselistDashboard.aspx?updated=1", false);
            Context.ApplicationInstance.CompleteRequest();

            pnlSuccess.Visible = true;
            lblSuccess.Text = "\"" + HttpUtility.HtmlEncode(courseName) + "\" updated successfully!";

            ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                "showToast('Course updated successfully!');", true);

            // Reload to reflect latest DB values
            LoadCourseData(courseId);
        }

        private bool UpdateCourse(string courseId, string teacherId, string courseName, string description, DateTime endAt)
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                UPDATE dbo.courseTable
                SET courseName = @name,
                    description = @desc,
                    endAt = @endAt
                WHERE courseID = @courseId
                  AND teacherID = @teacherId;", conn))
            {
                cmd.Parameters.AddWithValue("@name", courseName);
                cmd.Parameters.AddWithValue("@endAt", endAt);
                cmd.Parameters.AddWithValue("@courseId", courseId);
                cmd.Parameters.AddWithValue("@teacherId", teacherId);

                if (string.IsNullOrWhiteSpace(description))
                    cmd.Parameters.AddWithValue("@desc", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@desc", description);

                conn.Open();
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        private bool TryGetCreatedAtOwned(string courseId, string teacherId, out DateTime createdAt)
        {
            createdAt = DateTime.MinValue;

            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT createdAt
                FROM dbo.courseTable
                WHERE courseID = @courseId
                  AND teacherID = @teacherId;", conn))
            {
                cmd.Parameters.AddWithValue("@courseId", courseId);
                cmd.Parameters.AddWithValue("@teacherId", teacherId);

                conn.Open();
                var v = cmd.ExecuteScalar();
                if (v == null || v == DBNull.Value) return false;

                createdAt = Convert.ToDateTime(v);
                return true;
            }
        }
    }
}
