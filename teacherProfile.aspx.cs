using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class teacherProfile : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private string CurrentUserId =>
            (Session["UserID"] ?? Session["userID"])?.ToString()?.Trim();

        private bool EnsureTeacherSession()
        {
            if (string.IsNullOrWhiteSpace(CurrentUserId) || Session["RoleName"]?.ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return false;
            }

            return true;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!EnsureTeacherSession()) return;

            if (!IsPostBack)
            {
                LoadTeacherProfile();
                LoadTeachingImpact();
            }
        }

        // Load profile from DB into form fields
        private void LoadTeacherProfile()
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT fullName, email, schoolName, AvatarUrl
                FROM   dbo.userTable
                WHERE  userID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;

                    txtFullName.Text = r["fullName"]?.ToString() ?? "";
                    txtEmail.Text = r["email"]?.ToString() ?? "";
                    txtSchoolName.Text = r["schoolName"]?.ToString() ?? "";

                    string avatar = r["AvatarUrl"]?.ToString();
                    if (!string.IsNullOrWhiteSpace(avatar))
                        imgProfileLarge.ImageUrl = avatar.StartsWith("http")
                            ? avatar
                            : ResolveUrl("~/" + avatar.TrimStart('~', '/'));
                }
            }
        }

        // Save profile changes
        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (!EnsureTeacherSession()) return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string schoolName = txtSchoolName.Text.Trim();

            if (string.IsNullOrWhiteSpace(fullName) || string.IsNullOrWhiteSpace(email))
            {
                ShowSaveResult(false, "Full name and email are required.");
                return;
            }

            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.userTable
                    SET    fullName   = @fullName,
                           email      = @email,
                           schoolName = @schoolName
                    WHERE  userID     = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@fullName", fullName);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@schoolName",
                        string.IsNullOrWhiteSpace(schoolName)
                            ? (object)DBNull.Value : schoolName);
                    cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                Session["FullName"] = fullName;
                ShowSaveResult(true, "Profile updated successfully.");
                LoadTeacherProfile();
            }
            catch (SqlException ex)
            {
                string msg = ex.Number == 2627 || ex.Number == 2601
                    ? "That email is already in use by another account."
                    : "Error saving: " + ex.Message;
                ShowSaveResult(false, msg);
            }
        }

        private void ShowSaveResult(bool success, string message)
        {
            pnlSaveResult.Visible = true;
            pnlSaveResult.CssClass = success
                ? "mb-6 rounded-2xl px-4 py-3 flex items-center gap-2 bg-green-50 border-2 border-green-200"
                : "mb-6 rounded-2xl px-4 py-3 flex items-center gap-2 bg-red-50 border-2 border-red-200";
            lblSaveResult.CssClass = success
                ? "font-bold text-sm text-green-700"
                : "font-bold text-sm text-red-600";
            lblSaveResult.Text = message;
        }

        // Avatar Upload
        protected void btnSaveAvatar_Click(object sender, EventArgs e)
        {
            if (!EnsureTeacherSession()) return;

            if (fuAvatar == null || !fuAvatar.HasFile)
            {
                ShowSaveResult(false, "Please select an image file first.");
                return;
            }

            string ext = Path.GetExtension(fuAvatar.FileName).ToLowerInvariant();
            var allowed = new HashSet<string> { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
            if (!allowed.Contains(ext))
            {
                ShowSaveResult(false, "Invalid file type. Please upload JPG, PNG, GIF, or WEBP.");
                return;
            }

            if (fuAvatar.PostedFile.ContentLength > 2 * 1024 * 1024)
            {
                ShowSaveResult(false, "File is too large. Maximum allowed size is 2 MB.");
                return;
            }

            try
            {
                string avatarsFolder = Server.MapPath("~/Avatars/");
                if (!Directory.Exists(avatarsFolder))
                    Directory.CreateDirectory(avatarsFolder);

                foreach (var old in Directory.GetFiles(avatarsFolder, CurrentUserId + ".*"))
                    File.Delete(old);

                string fileName = CurrentUserId + ext;
                string filePath = Path.Combine(avatarsFolder, fileName);
                fuAvatar.SaveAs(filePath);

                string relativeUrl = "Avatars/" + fileName;

                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.userTable
                    SET    AvatarUrl = @url
                    WHERE  userID    = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@url", relativeUrl);
                    cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                imgProfileLarge.ImageUrl = ResolveUrl("~/" + relativeUrl)
                    + "?v=" + DateTime.UtcNow.Ticks;

                ShowSaveResult(true, "Avatar updated successfully.");
            }
            catch (Exception ex)
            {
                ShowSaveResult(false, "Error saving avatar: " + ex.Message);
            }
        }

        // Reset password redirect
        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            if (!EnsureTeacherSession()) return;

            // Pre-fill email so teacher doesn't have to type it
            string email = txtEmail.Text.Trim();
            if (!string.IsNullOrWhiteSpace(email))
                Response.Redirect("~/ResetPassword.aspx?email="
                    + Server.UrlEncode(email), false);
            else
                Response.Redirect("~/ResetPassword.aspx", false);

            Context.ApplicationInstance.CompleteRequest();
        }

        // Logout
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // Teaching Impact sidebar
        private void LoadTeachingImpact()
        {
            int students = 0, courses = 0, modules = 0, days = 0;

            try
            {
                const string sql = @"
                    SELECT
                        TotalStudents = (
                            SELECT COUNT(DISTINCT e.userID)
                            FROM   dbo.studentEnrolmentTable e
                            JOIN   dbo.courseTable c ON c.courseID = e.courseID
                            WHERE  c.teacherID = @uid AND e.enrolStatus = 1
                        ),
                        ActiveCourses = (
                            SELECT COUNT(*) FROM dbo.courseTable
                            WHERE  teacherID = @uid AND status = 'Active'
                        ),
                        TotalModules = (
                            SELECT COUNT(*) FROM dbo.moduleTable m
                            JOIN   dbo.courseTable c ON c.courseID = m.courseID
                            WHERE  c.teacherID = @uid
                        ),
                        DaysSinceFirst = (
                            SELECT ISNULL(DATEDIFF(DAY, MIN(createdAt), GETDATE()), 0)
                            FROM   dbo.courseTable
                            WHERE  teacherID = @uid
                        )";

                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", CurrentUserId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            students = Convert.ToInt32(r["TotalStudents"]);
                            courses = Convert.ToInt32(r["ActiveCourses"]);
                            modules = Convert.ToInt32(r["TotalModules"]);
                            days = Convert.ToInt32(r["DaysSinceFirst"]);
                        }
                    }
                }
            }
            catch { /* non-critical */ }

            rptImpactCards.DataSource = new List<ImpactCard>
            {
                new ImpactCard { Value = students.ToString(), Subtitle = "Total Students Taught",
                    Icon = "groups",                BorderColor = "#2563eb", ShadowColor = "#1e3a8a",
                    IconBg = "#2563eb",             IconColor = "white" },
                new ImpactCard { Value = courses.ToString(),  Subtitle = "Active Courses",
                    Icon = "local_fire_department", BorderColor = "#f9d006", ShadowColor = "#d4b105",
                    IconBg = "#f9d006",             IconColor = "#1e3a8a" },
                new ImpactCard { Value = modules.ToString(),  Subtitle = "Total Modules",
                    Icon = "check_circle",          BorderColor = "#84cc16", ShadowColor = "#4d7c0f",
                    IconBg = "#84cc16",             IconColor = "white" },
                new ImpactCard { Value = days + "d",          Subtitle = "Days Since First Course",
                    Icon = "calendar_month",        BorderColor = "#1e3a8a", ShadowColor = "#0f2257",
                    IconBg = "#1e3a8a",             IconColor = "white" },
            };
            rptImpactCards.DataBind();
        }

        protected void rptImpactCards_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var card = (ImpactCard)e.Item.DataItem;
            var litCard = (Literal)e.Item.FindControl("litImpactCard");            litCard.Text = $@"
<div class='rounded-[2rem] border border-white/70 bg-white/90 p-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)] transition-all hover:-translate-y-0.5 hover:shadow-[0_22px_46px_rgba(30,58,138,0.12)]'>
    <div class='flex items-center gap-4'>
        <div class='flex h-16 w-16 items-center justify-center rounded-2xl flex-shrink-0' style='background:{card.IconBg};'>
            <span class='material-symbols-outlined text-3xl fill-icon' style='color:{card.IconColor};'>{card.Icon}</span>
        </div>
        <div>
            <div class='text-3xl font-black tracking-tight text-math-dark-blue'>{card.Value}</div>
            <div class='mt-1 text-[11px] font-black uppercase tracking-[0.24em] text-gray-400'>{card.Subtitle}</div>
        </div>
    </div>
</div>";
        }

        public class ImpactCard
        {
            public string Value { get; set; }
            public string Subtitle { get; set; }
            public string Icon { get; set; }
            public string BorderColor { get; set; }
            public string ShadowColor { get; set; }
            public string IconBg { get; set; }
            public string IconColor { get; set; }
        }
    }
}
