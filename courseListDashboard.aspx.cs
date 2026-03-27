using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class courselistDashboard : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private const int PageSize = 5;

        private int CurrentPage
        {
            get { return ViewState["Page"] != null ? (int)ViewState["Page"] : 1; }
            set { ViewState["Page"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userID"] == null)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                AutoArchiveExpiredCourses();
                BindCourses();

                string success = Request.QueryString["success"];
                string status = Request.QueryString["status"];
                string newId = Request.QueryString["newId"];

                if (success == "1" && !string.IsNullOrEmpty(newId))
                {
                    pnlSuccess.Visible = true;
                    lblSuccess.Text = $"Course {newId} created successfully as {status}.";
                }
            }
        }

        private void AutoArchiveExpiredCourses()
        {
            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.courseTable
                    SET    status = 'Archived'
                    WHERE  endAt       < GETDATE()
                      AND  status     != 'Archived'
                      AND  autoArchive = 1", conn))
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private void BindCourses()
        {
            string teacherId = Session["userID"]?.ToString();
            if (string.IsNullOrEmpty(teacherId))
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            DataTable all = GetCoursesFromDatabase(teacherId);

            int totalRows = all.Rows.Count;
            int totalPages = (int)Math.Ceiling((double)totalRows / PageSize);
            if (totalPages < 1) totalPages = 1;
            if (CurrentPage > totalPages) CurrentPage = totalPages;
            if (CurrentPage < 1) CurrentPage = 1;

            pnlEmpty.Visible = (totalRows == 0);

            int start = (CurrentPage - 1) * PageSize;
            int end = Math.Min(start + PageSize, totalRows);

            DataTable page = all.Clone();
            for (int i = start; i < end; i++)
                page.ImportRow(all.Rows[i]);

            int showFrom = totalRows == 0 ? 0 : start + 1;
            litCourseCount.Text = totalRows == 0
                ? "No courses yet"
                : $"{showFrom}–{end} of {totalRows} course{(totalRows == 1 ? "" : "s")}";

            rptCourses.DataSource = page;
            rptCourses.DataBind();

            RenderPager(totalPages);
        }

        private void RenderPager(int totalPages)
        {
            if (totalPages <= 1) { litPager.Text = ""; return; }

            var sb = new System.Text.StringBuilder();

            sb.Append($"<button type='button' onclick='changePage({CurrentPage - 1})'");
            if (CurrentPage <= 1) sb.Append(" disabled");
            sb.Append(" class='size-10 flex items-center justify-center rounded-full border border-gray-200 bg-white text-gray-400 transition-all hover:border-blue-200 hover:text-blue-600 disabled:opacity-30 disabled:cursor-not-allowed'>");
            sb.Append("<span class='material-symbols-outlined'>chevron_left</span></button>");

            for (int i = 1; i <= totalPages; i++)
            {
                sb.Append(i == CurrentPage
                    ? $"<button type='button' class='size-10 flex items-center justify-center rounded-full bg-math-blue text-white font-black shadow-lg shadow-math-blue/20'>{i}</button>"
                    : $"<button type='button' onclick='changePage({i})' class='size-10 flex items-center justify-center rounded-full border border-gray-200 bg-white text-gray-600 font-black transition-all hover:border-blue-200 hover:text-blue-600'>{i}</button>");
            }

            sb.Append($"<button type='button' onclick='changePage({CurrentPage + 1})'");
            if (CurrentPage >= totalPages) sb.Append(" disabled");
            sb.Append(" class='size-10 flex items-center justify-center rounded-full border border-gray-200 bg-white text-gray-400 transition-all hover:border-blue-200 hover:text-blue-600 disabled:opacity-30 disabled:cursor-not-allowed'>");
            sb.Append("<span class='material-symbols-outlined'>chevron_right</span></button>");

            litPager.Text = sb.ToString();
        }

        protected void btnChangePage_Click(object sender, EventArgs e)
        {
            if (int.TryParse(hdnPageTarget.Value, out int pg))
                CurrentPage = pg;
            BindCourses();
        }

        protected void btnArchive_Click(object sender, EventArgs e)
        {
            string courseId = hdnActionCourseId.Value;
            if (string.IsNullOrEmpty(courseId)) return;

            string current = GetCourseStatus(courseId);
            string newStatus = current == "Archived" ? "Active" : "Archived";

            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "UPDATE dbo.courseTable SET status=@status WHERE courseID=@cid", conn))
            {
                cmd.Parameters.AddWithValue("@status", newStatus);
                cmd.Parameters.AddWithValue("@cid", courseId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            BindCourses();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            string courseId = hdnActionCourseId.Value;
            if (string.IsNullOrEmpty(courseId)) return;

            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        Execute(conn, tx, @"
                            DELETE sa FROM dbo.studentAnswerTable sa
                            JOIN   dbo.assessmentAttemptTable aa ON aa.attemptID   = sa.attemptID
                            JOIN   dbo.assessmentTable        a  ON a.assessmentID = aa.assessmentID
                            WHERE  a.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE aa FROM dbo.assessmentAttemptTable aa
                            JOIN   dbo.assessmentTable a ON a.assessmentID = aa.assessmentID
                            WHERE  a.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE qa FROM dbo.QuizAttempt qa
                            JOIN   dbo.quizTable        q  ON q.quizID   = qa.quizID
                            JOIN   dbo.moduleBlockTable mb  ON mb.blockID = q.blockID
                            JOIN   dbo.moduleTable      m   ON m.moduleID = mb.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE qo FROM dbo.questionOptionTable qo
                            JOIN   dbo.questionTable   q ON q.questionID   = qo.questionID
                            JOIN   dbo.assessmentTable a ON a.assessmentID = q.assessmentID
                            WHERE  a.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE q FROM dbo.questionTable q
                            JOIN   dbo.assessmentTable a ON a.assessmentID = q.assessmentID
                            WHERE  a.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE qo FROM dbo.quizOptionTable qo
                            JOIN   dbo.quizQuestionTable qq ON qq.questionID = qo.questionID
                            JOIN   dbo.quizTable         q  ON q.quizID     = qq.quizID
                            JOIN   dbo.moduleBlockTable  mb ON mb.blockID   = q.blockID
                            JOIN   dbo.moduleTable       m  ON m.moduleID   = mb.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE qq FROM dbo.quizQuestionTable qq
                            JOIN   dbo.quizTable        q  ON q.quizID   = qq.quizID
                            JOIN   dbo.moduleBlockTable mb  ON mb.blockID = q.blockID
                            JOIN   dbo.moduleTable      m   ON m.moduleID = mb.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE q FROM dbo.quizTable q
                            JOIN   dbo.moduleBlockTable mb ON mb.blockID = q.blockID
                            JOIN   dbo.moduleTable      m  ON m.moduleID = mb.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx,
                            "DELETE FROM dbo.assessmentTable WHERE courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE bc FROM dbo.blockContentTable bc
                            JOIN   dbo.moduleBlockTable mb ON mb.blockID = bc.blockID
                            JOIN   dbo.moduleTable      m  ON m.moduleID = mb.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE mb FROM dbo.moduleBlockTable mb
                            JOIN   dbo.moduleTable m ON m.moduleID = mb.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE fc FROM dbo.flashcardCompletionTable fc
                            JOIN   dbo.flashcardTable f ON f.flashcardID = fc.flashcardID
                            JOIN   dbo.moduleTable    m ON m.moduleID    = f.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE f FROM dbo.flashcardTable f
                            JOIN   dbo.moduleTable m ON m.moduleID = f.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE fs FROM dbo.flashcardSetTable fs
                            JOIN   dbo.moduleTable m ON m.moduleID = fs.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE sp FROM dbo.studentBlockProgressTable sp
                            JOIN   dbo.moduleBlockTable mb ON mb.blockID = sp.blockID
                            JOIN   dbo.moduleTable      m  ON m.moduleID = mb.moduleID
                            WHERE  m.courseID = @cid", courseId);

                        Execute(conn, tx, @"
                            DELETE FROM dbo.studentProgressTable
                            WHERE moduleID IN (
                                SELECT moduleID FROM dbo.moduleTable WHERE courseID = @cid
                            )", courseId);

                        Execute(conn, tx, @"
                            DELETE FROM dbo.studentModuleCompletionTable
                            WHERE moduleID IN (
                                SELECT moduleID FROM dbo.moduleTable WHERE courseID = @cid
                            )", courseId);

                        Execute(conn, tx, @"
                            DELETE FROM dbo.moduleAccessRuleTable
                            WHERE moduleID IN (
                                SELECT moduleID FROM dbo.moduleTable WHERE courseID = @cid
                            )", courseId);

                        Execute(conn, tx,
                            "DELETE FROM dbo.studentScoreEventTable WHERE courseID = @cid", courseId);

                        Execute(conn, tx,
                            "DELETE FROM dbo.studentEnrolmentTable WHERE courseID = @cid", courseId);

                        Execute(conn, tx,
                            "DELETE FROM dbo.moduleTable WHERE courseID = @cid", courseId);

                        Execute(conn, tx,
                            "DELETE FROM dbo.courseTable WHERE courseID = @cid", courseId);

                        tx.Commit();
                        CurrentPage = 1;
                        BindCourses();
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        ScriptManager.RegisterStartupScript(this, GetType(), "delErr",
                            $"alert('Delete failed: {ex.Message.Replace("'", "\\'")}');", true);
                    }
                }
            }
        }

        private void Execute(SqlConnection conn, SqlTransaction tx, string sql, string courseId)
        {
            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@cid", courseId);
                cmd.ExecuteNonQuery();
            }
        }

        private string GetCourseStatus(string courseId)
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT status FROM dbo.courseTable WHERE courseID=@cid", conn))
            {
                cmd.Parameters.AddWithValue("@cid", courseId);
                conn.Open();
                return cmd.ExecuteScalar()?.ToString() ?? "";
            }
        }

        private DataTable GetCoursesFromDatabase(string teacherId)
        {
            var dt = new DataTable();
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT
                    c.courseID,
                    c.courseName,
                    c.status,
                    c.createdAt,
                    c.endAt,
                    ModuleCount      = (SELECT COUNT(*)
                                        FROM dbo.moduleTable m
                                        WHERE m.courseID = c.courseID),
                    EnrolledStudents = (SELECT COUNT(DISTINCT e.userID)
                                        FROM dbo.studentEnrolmentTable e
                                        WHERE e.courseID = c.courseID AND e.enrolStatus = 1)
                FROM  dbo.courseTable c
                WHERE c.teacherID = @tid
                ORDER BY c.createdAt DESC", conn))
            {
                cmd.Parameters.AddWithValue("@tid", teacherId);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }

            dt.Columns.Add("Icon", typeof(string));
            dt.Columns.Add("StartDate", typeof(string));
            dt.Columns.Add("EndDate", typeof(string));

            foreach (DataRow row in dt.Rows)
            {
                row["Icon"] = GuessIcon(row["courseName"].ToString());
                row["StartDate"] = row["createdAt"] != DBNull.Value
                    ? Convert.ToDateTime(row["createdAt"]).ToString("MMM dd, yyyy") : "—";
                row["EndDate"] = row["endAt"] != DBNull.Value
                    ? Convert.ToDateTime(row["endAt"]).ToString("MMM dd, yyyy") : "—";
            }

            return dt;
        }

        protected void rptCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row = (DataRowView)e.Item.DataItem;
            string status = row["status"].ToString();

            var litIcon = (Literal)e.Item.FindControl("litIconContainer");
            litIcon.Text = $@"
<div class=""size-12 rounded-2xl {GetIconBgClass(status)} flex items-center justify-center {GetIconColorClass(status)} shadow-inner"">
    <span class=""material-symbols-outlined text-2xl"" style=""font-variation-settings:'FILL' 1"">{row["Icon"]}</span>
</div>";

            var litAvatars = (Literal)e.Item.FindControl("litStudentAvatars");
            litAvatars.Text = GetStudentAvatars(Convert.ToInt32(row["EnrolledStudents"]));

            var litValidity = (Literal)e.Item.FindControl("litValidity");
            litValidity.Text = $@"
<div class=""text-sm font-bold text-gray-600"">
    <span class=""block"">{row["StartDate"]}</span>
    <span class=""text-gray-300 text-xs"">to</span>
    <span class=""block"">{row["EndDate"]}</span>
</div>";

            var litStatus = (Literal)e.Item.FindControl("litStatus");
            litStatus.Text = GetStatusBadge(status);
        }

        private string GuessIcon(string name)
        {
            string n = (name ?? "").ToLowerInvariant();
            if (n.Contains("algebra")) return "functions";
            if (n.Contains("geometry")) return "change_history";
            if (n.Contains("calculus")) return "integration_instructions";
            if (n.Contains("stat")) return "analytics";
            if (n.Contains("trig")) return "timeline";
            return "menu_book";
        }

        private string GetIconBgClass(string status)
        {
            switch (status)
            {
                case "Active": return "bg-blue-50";
                case "Draft": return "bg-yellow-50";
                case "Archived": return "bg-green-50";
                default: return "bg-gray-100";
            }
        }

        private string GetIconColorClass(string status)
        {
            switch (status)
            {
                case "Active": return "text-blue-600";
                case "Draft": return "text-yellow-500";
                case "Archived": return "text-green-600";
                default: return "text-gray-400";
            }
        }

        private string GetStudentAvatars(int count)
        {
            if (count <= 0)
                return @"<div class=""size-8 rounded-full border-2 border-white bg-gray-200 flex items-center justify-center text-[10px] font-black text-gray-400"">0</div>";

            string[] initials = { "JW", "AR", "ST" };
            string[] colors = { "bg-blue-100", "bg-green-100", "bg-yellow-100" };
            string html = "";
            int show = Math.Min(3, count);
            for (int i = 0; i < show; i++)
                html += $@"<div class=""size-8 rounded-full border-2 border-white {colors[i]} flex items-center justify-center text-[10px] font-bold"">{initials[i]}</div>";
            if (count > 3)
                html += $@"<div class=""size-8 rounded-full border-2 border-white bg-gray-200 flex items-center justify-center text-[10px] font-black text-gray-600"">+{count - 3}</div>";
            return html;
        }

        private string GetStatusBadge(string status)
        {
            string badge, dot;
            switch (status)
            {
                case "Active": badge = "bg-green-50 text-green-600"; dot = "bg-green-500"; break;
                case "Draft": badge = "bg-yellow-50 text-yellow-600"; dot = "bg-yellow-400"; break;
                case "Archived": badge = "bg-blue-50 text-blue-600"; dot = "bg-blue-500"; break;
                default: badge = "bg-gray-100 text-gray-400"; dot = "bg-gray-400"; break;
            }
            return $@"<span class=""inline-flex items-center gap-1.5 px-3 py-1 rounded-full {badge} text-xs font-black uppercase tracking-wider"">
                          <span class=""size-2 rounded-full {dot}""></span>{status}
                      </span>";
        }
    }
}

