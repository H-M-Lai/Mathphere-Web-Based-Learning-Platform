using System;
using System.Configuration;
using System.Data.SqlClient;

namespace MathSphere
{
    public partial class teacherCreateCourse : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userID"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                litPreviewId.Text = "Will be assigned on creation (e.g. " + PeekNextCourseId() + ")";
            }
        }

        protected void btnLaunchCourse_Click(object sender, EventArgs e)
        {
            // Server-side validation
            if (string.IsNullOrWhiteSpace(txtCourseName.Text))
            {
                ShowError("Please enter a Course Name.");
                return;
            }

            if (string.IsNullOrEmpty(hdnEndDate.Value))
            {
                ShowError("Please set the Course Validity (end date) before launching.");
                return;
            }

            // Parse dates
            DateTime startDate = DateTime.MinValue;
            DateTime endDate;

            if (!string.IsNullOrEmpty(hdnStartDate.Value))
                DateTime.TryParse(hdnStartDate.Value, out startDate);

            if (!DateTime.TryParse(hdnEndDate.Value, out endDate))
            {
                ShowError("Invalid end date. Please set the Course Validity again.");
                return;
            }

            // Determine status on the SERVER (don't trust JS hdnStatus alone)
            string status;
            if (startDate != DateTime.MinValue && startDate.Date <= DateTime.Today)
                status = "Active";
            else if (startDate == DateTime.MinValue)
                // No start date set — treat creation date as start
                status = "Active";
            else
                status = "Draft";

            // Parse autoArchive
            bool autoArchive = true;
            bool.TryParse(hdnAutoArchive.Value, out autoArchive);

            string teacherId = Session["userID"].ToString();

            // Save to DB
            string newCourseId;
            string errorMsg;
            bool saved = SaveCourse(
                courseName: txtCourseName.Text.Trim(),
                description: txtDescription.Text.Trim(),
                teacherID: teacherId,
                status: status,
                endAt: endDate,
                autoArchive: autoArchive,
                newCourseId: out newCourseId,
                errorMsg: out errorMsg
            );

            if (!saved)
            {
                ShowError("Error creating course: " + errorMsg);
                return;
            }

            Response.Redirect(
                "courselistDashboard.aspx?success=1&status=" +
                Uri.EscapeDataString(status) +
                "&newId=" + Uri.EscapeDataString(newCourseId),
                false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // -
        //  Save course — returns true on success, false on failure
        //  Out params: newCourseId and errorMsg
        // -
        private bool SaveCourse(string courseName, string description,
                                string teacherID, string status,
                                DateTime endAt, bool autoArchive,
                                out string newCourseId, out string errorMsg)
        {
            newCourseId = null;
            errorMsg = null;

            try
            {
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction(System.Data.IsolationLevel.Serializable))
                    {
                        try
                        {
                            newCourseId = GenerateNextCourseId(conn, tx);

                            // courseTable columns:
                            // courseID, courseName, description, teacherID,
                            // status, createdAt(default), endAt, autoArchive
                            const string sql = @"
                                INSERT INTO dbo.courseTable
                                    (courseID, courseName, description,
                                     teacherID, status, endAt, autoArchive)
                                VALUES
                                    (@courseID, @courseName, @description,
                                     @teacherID, @status, @endAt, @autoArchive)";

                            using (var cmd = new SqlCommand(sql, conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@courseID", newCourseId);
                                cmd.Parameters.AddWithValue("@courseName", courseName);
                                cmd.Parameters.AddWithValue("@teacherID", teacherID);
                                cmd.Parameters.AddWithValue("@status", status);
                                cmd.Parameters.AddWithValue("@endAt", endAt);
                                cmd.Parameters.AddWithValue("@autoArchive", autoArchive ? 1 : 0);
                                cmd.Parameters.AddWithValue("@description",
                                    string.IsNullOrWhiteSpace(description)
                                        ? (object)DBNull.Value : description);
                                cmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            return true;
                        }
                        catch (Exception ex)
                        {
                            tx.Rollback();
                            errorMsg = ex.Message;
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMsg = ex.Message;
                return false;
            }
        }

        private string GenerateNextCourseId(SqlConnection conn, SqlTransaction tx)
        {
            const string sql = @"
                SELECT ISNULL(
                    MAX(TRY_CAST(SUBSTRING(courseID, 2, LEN(courseID)-1) AS INT))
                , 0)
                FROM dbo.courseTable
                WHERE courseID LIKE 'C[0-9]%'";

            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                int maxNum = (int)cmd.ExecuteScalar();
                return "C" + (maxNum + 1).ToString("D3");
            }
        }

        private string PeekNextCourseId()
        {
            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    SELECT ISNULL(
                        MAX(TRY_CAST(SUBSTRING(courseID, 2, LEN(courseID)-1) AS INT))
                    , 0)
                    FROM dbo.courseTable
                    WHERE courseID LIKE 'C[0-9]%'", conn))
                {
                    conn.Open();
                    int maxNum = (int)cmd.ExecuteScalar();
                    return "C" + (maxNum + 1).ToString("D3");
                }
            }
            catch { return "C001"; }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblError.Text = message;
        }
    }
}
