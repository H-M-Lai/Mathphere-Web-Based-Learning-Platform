using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class courseDetail : System.Web.UI.Page
    {
        private string CS => ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private string CourseId => (Request.QueryString["courseId"] ?? "").Trim();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(CourseId))
            {
                Response.Redirect("courselistDashboard.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                BindCourseHeader();
                BindModules();
                BindAssessments();

                lnkNewAssessment.NavigateUrl =
                    ResolveUrl("~/assessmentTemplates.aspx?courseId=" + HttpUtility.UrlEncode(CourseId));

                lnkFullSyllabus.NavigateUrl =
                    ResolveUrl("~/fullModuleView.aspx?courseId=" + HttpUtility.UrlEncode(CourseId));
            }
        }

        private void BindCourseHeader()
        {
            const string sql = @"
        SELECT TOP 1
            c.courseName,
            c.status,
            c.createdAt,
            c.endAt
        FROM dbo.courseTable c
        WHERE c.courseID = @cid;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@cid", CourseId);
                con.Open();

                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        string courseName = r["courseName"].ToString();
                        string status = r["status"].ToString();
                        string startDate = r["createdAt"] != DBNull.Value
                            ? Convert.ToDateTime(r["createdAt"]).ToString("MMM dd, yyyy") : "—";
                        string endDate = r["endAt"] != DBNull.Value
                            ? Convert.ToDateTime(r["endAt"]).ToString("MMM dd, yyyy") : "—";

                        litPageTitle.Text = courseName;
                        litCourseName.Text = courseName;
                        litCourseInfo.Text = $"{status} · {startDate} – {endDate}";
                    }
                    else
                    {
                        litPageTitle.Text = "Course Detail";
                        litCourseName.Text = "Course";
                        litCourseInfo.Text = "";
                    }
                }
            }

            litCourseIcon.Text = "functions";
            litEnrolledCount.Text = GetScalarInt(@"
        SELECT COUNT(*)
        FROM dbo.studentEnrolmentTable
        WHERE courseID = @cid;", "@cid", CourseId).ToString();

        }

        private void BindModules()
        {
            const string sql = @"
        SELECT
            moduleID,
            moduleTitle,
            ROW_NUMBER() OVER (ORDER BY moduleID) AS ModuleNo
        FROM dbo.moduleTable
        WHERE courseID = @cid
        ORDER BY moduleID;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@cid", CourseId);
                con.Open();

                var dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);
                rptModules.DataSource = dt;
                rptModules.DataBind();
                pnlNoModules.Visible = (dt.Rows.Count == 0);

            }
        }

        protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            string moduleId = row["moduleID"].ToString();
            string title = row["moduleTitle"].ToString();
            string modNo = row["ModuleNo"].ToString();

            string html = $@"
        <div class=""min-w-[180px] bg-white border-2 border-gray-100 rounded-[1.75rem] p-5 shadow-sm cursor-default select-none"">
            <div class=""size-11 rounded-xl bg-math-blue/10 flex items-center justify-center mb-3"">
                <span class=""material-symbols-outlined text-math-blue"">widgets</span>
            </div>
            <div class=""text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1"">Module {modNo}</div>
            <div class=""text-math-dark-blue font-black leading-tight"">{HttpUtility.HtmlEncode(title)}</div>
        </div>";

            ((Literal)e.Item.FindControl("litModuleCard")).Text = html;
        }

        private void BindAssessments()
        {
            const string sql = @"
                SELECT
                    assessmentID,
                    title,
                    moduleID,
                    ISNULL(totalMarks, 0) AS totalMarks,
                    ISNULL(timeLimitMinutes, 0) AS timeLimitMinutes,
                    ISNULL(passingScore, 0) AS passingScore,
                    ISNULL(isPublished, 0) AS isPublished,
                    createdAt
                FROM dbo.assessmentTable
                WHERE courseID = @cid
                ORDER BY createdAt DESC, assessmentID DESC;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@cid", CourseId);
                con.Open();

                var dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);
                rptAssessments.DataSource = dt;
                rptAssessments.DataBind();
                pnlNoAssessments.Visible = (dt.Rows.Count == 0);

            }
        }

        protected void rptAssessments_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView row = (DataRowView)e.Item.DataItem;

            string assessmentId = row["assessmentID"].ToString();
            string title = row["title"].ToString();
            int totalMarks = Convert.ToInt32(row["totalMarks"]);
            int timeLimit = Convert.ToInt32(row["timeLimitMinutes"]);
            int passingScore = Convert.ToInt32(row["passingScore"]);
            bool isPublished = Convert.ToBoolean(row["isPublished"]);

            string editUrl = ResolveUrl("~/assessmentTemplates.aspx?assessmentId=" +
                HttpUtility.UrlEncode(assessmentId) +
                "&courseId=" + HttpUtility.UrlEncode(CourseId) +
                "&edit=1");

            string badge = isPublished
                ? @"<span class=""inline-flex items-center gap-1 px-3 py-1 rounded-full bg-math-green/10 border border-math-green/20 text-math-green text-[10px] font-black uppercase tracking-widest"">
                        <span class=""material-symbols-outlined text-sm fill-icon"">check_circle</span> Published
                   </span>"
                : @"<span class=""inline-flex items-center gap-1 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-primary text-[10px] font-black uppercase tracking-widest"">
                        <span class=""material-symbols-outlined text-sm"">schedule</span> Draft
                   </span>";

            string html = $@"
                <div class=""bg-gray-50 border-2 border-gray-100 rounded-[1.75rem] p-6 hover:border-math-blue/20 transition-all"">
                    <div class=""flex items-start justify-between gap-4 mb-4"">
                        <div>
                            <div class=""text-math-dark-blue font-black text-xl leading-tight mb-2"">{HttpUtility.HtmlEncode(title)}</div>
                            {badge}
                        </div>
                        <div class=""size-11 rounded-xl bg-math-green/10 flex items-center justify-center flex-shrink-0"">
                            <span class=""material-symbols-outlined text-math-green text-2xl"">assignment</span>
                        </div>
                    </div>

                    <div class=""grid grid-cols-3 gap-3 mb-5"">
                        <div class=""bg-white rounded-xl border border-gray-100 px-4 py-3"">
                            <div class=""text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1"">Marks</div>
                            <div class=""text-math-dark-blue font-black"">{totalMarks}</div>
                        </div>
                        <div class=""bg-white rounded-xl border border-gray-100 px-4 py-3"">
                            <div class=""text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1"">Time</div>
                            <div class=""text-math-dark-blue font-black"">{timeLimit} min</div>
                        </div>
                        <div class=""bg-white rounded-xl border border-gray-100 px-4 py-3"">
                            <div class=""text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1"">Pass</div>
                            <div class=""text-math-dark-blue font-black"">{passingScore}%</div>
                        </div>
                    </div>

                    <div class=""flex gap-3 flex-wrap"">
                        <a href=""{editUrl}""
                           class=""inline-flex items-center gap-2 bg-math-blue/10 text-math-blue border-2 border-math-blue/20 font-black text-xs uppercase tracking-widest px-4 py-2.5 rounded-2xl hover:bg-math-blue/20 transition-colors"">
                            <span class=""material-symbols-outlined text-base"">edit</span>
                            Edit
                        </a>

                        <button type=""button""
                                onclick=""showDeleteAssessmentModal('{HttpUtility.JavaScriptStringEncode(assessmentId)}','{HttpUtility.JavaScriptStringEncode(title)}')""
                                class=""inline-flex items-center gap-2 bg-red-50 text-red-500 border-2 border-red-100 font-black text-xs uppercase tracking-widest px-4 py-2.5 rounded-2xl hover:bg-red-100 transition-colors"">
                            <span class=""material-symbols-outlined text-base"">delete</span>
                            Delete
                        </button>
                    </div>
                </div>";

            ((Literal)e.Item.FindControl("litAssessmentCard")).Text = html;
        }

        protected void btnDeleteAssessment_Click(object sender, EventArgs e)
        {
            string assessmentId = (hdnDeleteAssessmentId.Value ?? "").Trim();
            if (string.IsNullOrWhiteSpace(assessmentId)) return;

            try
            {
                using (var con = new SqlConnection(CS))
                {
                    con.Open();
                    using (var tx = con.BeginTransaction())
                    {
                        try
                        {
                            using (var cmd = new SqlCommand(@"
                                DELETE qo
                                FROM dbo.questionOptionTable qo
                                INNER JOIN dbo.questionTable q ON q.questionID = qo.questionID
                                WHERE q.assessmentID = @aid;", con, tx))
                            {
                                cmd.Parameters.AddWithValue("@aid", assessmentId);
                                cmd.ExecuteNonQuery();
                            }

                            using (var cmd = new SqlCommand(@"
                                DELETE FROM dbo.questionTable
                                WHERE assessmentID = @aid;", con, tx))
                            {
                                cmd.Parameters.AddWithValue("@aid", assessmentId);
                                cmd.ExecuteNonQuery();
                            }

                            using (var cmd = new SqlCommand(@"
                                DELETE FROM dbo.assessmentAttemptTable
                                WHERE assessmentID = @aid;", con, tx))
                            {
                                cmd.Parameters.AddWithValue("@aid", assessmentId);
                                cmd.ExecuteNonQuery();
                            }

                            using (var cmd = new SqlCommand(@"
                                DELETE FROM dbo.assessmentTable
                                WHERE assessmentID = @aid;", con, tx))
                            {
                                cmd.Parameters.AddWithValue("@aid", assessmentId);
                                cmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }

                BindAssessments();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(
                    this,
                    GetType(),
                    "delA_" + Guid.NewGuid().ToString("N"),
                    "alert('" + HttpUtility.JavaScriptStringEncode("Error deleting assessment: " + ex.Message) + "');",
                    true);
            }
        }

        private int GetScalarInt(string sql, string paramName, string value)
        {
            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue(paramName, value);
                con.Open();
                object result = cmd.ExecuteScalar();
                return result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
            }
        }
    }
}