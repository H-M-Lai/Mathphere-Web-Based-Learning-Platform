using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace Assignment
{
    public partial class StudentProfile : System.Web.UI.Page
    {
        private string CS => ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;
        private string UserId => (Session["UserID"] as string)?.Trim();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(UserId))
            { Response.Redirect("~/Login.aspx", true); return; }

            if (!IsPostBack) LoadProfile();
        }

        private void LoadProfile()
        {

            const string sql = @"
                SELECT
                    u.fullName,
                    u.email,
                    ISNULL(u.schoolName, '') AS schoolName,
                    ISNULL(u.AvatarUrl,  '') AS AvatarUrl,

                    -- Total XP
                    ISNULL((
                        SELECT SUM(points)
                        FROM   dbo.studentScoreEventTable
                        WHERE  userID = u.userID
                    ), 0) AS TotalXP,

                    -- Streak from StudentStreak (correct table name)
                    ISNULL(ss.currentStreak,  0) AS currentStreak,
                    ss.lastActivityDate,

                    -- Courses completed: course is done when every block in
                    -- every module of that course is completed by this student
                    ISNULL((
                        SELECT COUNT(DISTINCT m.courseID)
                        FROM   dbo.moduleTable           m
                        JOIN   dbo.studentEnrolmentTable se
                               ON  se.courseID    = m.courseID
                               AND se.userID      = u.userID
                               AND se.enrolStatus = 1
                        WHERE  NOT EXISTS (
                            SELECT 1
                            FROM   dbo.moduleTable        m2
                            JOIN   dbo.moduleBlockTable   mb  ON mb.moduleID = m2.moduleID
                            LEFT JOIN dbo.studentBlockProgressTable sbp
                                   ON sbp.blockID = mb.blockID
                                  AND sbp.userID  = u.userID
                            WHERE  m2.courseID = m.courseID
                              AND  ISNULL(sbp.isCompleted, 0) = 0
                        )
                    ), 0) AS CoursesCompleted,

                    -- Modules completed this week (for weekly goal)
                    ISNULL((
                        SELECT COUNT(*)
                        FROM   dbo.studentModuleCompletionTable smc
                        WHERE  smc.userID               = u.userID
                          AND  smc.completionPercentage >= 100
                          AND  smc.completionDate >= DATEADD(
                                   DAY, 1 - DATEPART(WEEKDAY, GETDATE()),
                                   CAST(GETDATE() AS DATE))
                    ), 0) AS ModulesThisWeek,

                    -- Blocks completed (study-time proxy: 5 min each)
                    ISNULL((
                        SELECT COUNT(*)
                        FROM   dbo.studentBlockProgressTable sbp2
                        WHERE  sbp2.userID      = u.userID
                          AND  sbp2.isCompleted = 1
                    ), 0) AS BlocksCompleted

                FROM dbo.userTable u
                LEFT JOIN dbo.StudentStreak ss ON ss.userID = u.userID
                WHERE u.userID = @uid";

            string fullName, email, schoolName, avatarUrl;
            int xp, streak, coursesCompleted, modulesThisWeek, blocksCompleted;
            DateTime? lastActivity = null;

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@uid", UserId);
                con.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) { Response.Redirect("~/Login.aspx", true); return; }

                    fullName = dr["fullName"].ToString();
                    email = dr["email"].ToString();
                    schoolName = dr["schoolName"].ToString();
                    avatarUrl = dr["AvatarUrl"].ToString();
                    xp = Convert.ToInt32(dr["TotalXP"]);
                    int rawStreak = Convert.ToInt32(dr["currentStreak"]);
                    coursesCompleted = Convert.ToInt32(dr["CoursesCompleted"]);
                    modulesThisWeek = Convert.ToInt32(dr["ModulesThisWeek"]);
                    blocksCompleted = Convert.ToInt32(dr["BlocksCompleted"]);

                    if (dr["lastActivityDate"] != DBNull.Value)
                        lastActivity = Convert.ToDateTime(dr["lastActivityDate"]).Date;

                    streak = CalcDisplayStreak(rawStreak, lastActivity);
                }
            }

            // Form fields
            txtFullName.Text = fullName;
            txtEmail.Text = email;
            txtSchoolName.Text = schoolName;

            // Avatar
            string resolved = ResolveAvatarUrl(avatarUrl);
            imgMainAvatar.ImageUrl = resolved;
            hfAvatarOriginal.Value = ResolveUrl(resolved);

            // Stat cards
            litStatXP.Text = xp.ToString("N0") + " XP";
            litStatStreak.Text = streak + " day" + (streak != 1 ? "s" : "");
            litStatCourses.Text = coursesCompleted.ToString();

            int totalMinutes = blocksCompleted * 5;
            litStatTime.Text = totalMinutes >= 60
                ? (totalMinutes / 60) + "h " + (totalMinutes % 60) + "m"
                : totalMinutes + "m";

            // Weekly goal
            const int weeklyTarget = 3;
            int goalProgress = Math.Min(modulesThisWeek, weeklyTarget);
            int goalPct = (int)Math.Round((double)goalProgress / weeklyTarget * 100);
            litGoalName.Text = $"Complete {weeklyTarget} modules this week";
            litGoalProgressText.Text = $"{goalProgress} / {weeklyTarget} modules";
            litGoalPercent.Text = goalPct + "%";
            pnlProgressBar.Style["width"] = goalPct + "%";

            // Session sync
            Session["FullName"] = fullName;
            Session["Email"] = email;
            Session["SchoolName"] = schoolName;
            Session["AvatarUrl"] = avatarUrl;
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string newName = (txtFullName.Text ?? "").Trim();
            string newEmail = (txtEmail.Text ?? "").Trim();
            string newSchool = (txtSchoolName.Text ?? "").Trim();

            const string sql = @"
                IF EXISTS (
                    SELECT 1 FROM dbo.userTable
                    WHERE  email = @email AND userID <> @uid
                )
                BEGIN SELECT -1; RETURN; END

                UPDATE dbo.userTable
                SET    fullName   = @name,
                       email      = @email,
                       schoolName = @school
                WHERE  userID = @uid;
                SELECT 1;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@uid", UserId);
                cmd.Parameters.AddWithValue("@name", newName);
                cmd.Parameters.AddWithValue("@email", newEmail);
                cmd.Parameters.AddWithValue("@school",
                    string.IsNullOrWhiteSpace(newSchool) ? (object)DBNull.Value : newSchool);
                con.Open();
                if (Convert.ToInt32(cmd.ExecuteScalar()) == -1)
                { ShowMsg("This email is already used by another account.", true); return; }
            }

            Session["FullName"] = newName;
            Session["Email"] = newEmail;
            Session["SchoolName"] = newSchool;
            ShowMsg("Profile updated successfully! ✓", false);
        }

        protected void btnChangeAvatar_Click(object sender, EventArgs e)
        {
            if (!fuAvatar.HasFile) { ShowMsg("Please choose an image first.", true); return; }

            string ext = Path.GetExtension(fuAvatar.FileName).ToLowerInvariant();
            if (!new HashSet<string> { ".png", ".jpg", ".jpeg", ".gif", ".webp" }.Contains(ext))
            { ShowMsg("Only PNG / JPG / JPEG / GIF / WEBP files are allowed.", true); return; }

            if (fuAvatar.PostedFile.ContentLength > 2 * 1024 * 1024)
            { ShowMsg("Image too large — maximum 2 MB.", true); return; }

            string folder = Server.MapPath("~/Image/Avatars/");
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
            foreach (var old in Directory.GetFiles(folder, UserId + ".*"))
                try { File.Delete(old); } catch { }

            string fileName = UserId + ext;
            fuAvatar.SaveAs(Path.Combine(folder, fileName));
            string relUrl = "Image/Avatars/" + fileName;

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand("UPDATE dbo.userTable SET AvatarUrl=@url WHERE userID=@uid", con))
            {
                cmd.Parameters.AddWithValue("@url", relUrl);
                cmd.Parameters.AddWithValue("@uid", UserId);
                con.Open();
                cmd.ExecuteNonQuery();
            }

            string resolved = ResolveUrl("~/" + relUrl) + "?v=" + DateTime.UtcNow.Ticks;
            imgMainAvatar.ImageUrl = resolved;
            hfAvatarOriginal.Value = resolved;
            Session["AvatarUrl"] = relUrl;

            var masterImg = Master?.FindControl("imgAvatar") as System.Web.UI.WebControls.Image;
            if (masterImg != null) masterImg.ImageUrl = resolved;

            btnChangeAvatar.CssClass = btnChangeAvatar.CssClass
                .Replace("opacity-100 pointer-events-auto", "opacity-50 pointer-events-none");
            lblAvatarHint.Visible = false;
            ShowMsg("Avatar updated successfully! 🎉", false);
        }

        protected void btnResetPassword_Click(object sender, EventArgs e) =>
            Response.Redirect("~/ResetPassword.aspx", true);

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx", true);
        }

        // Streak is only live if student was active today or yesterday (MY/SG UTC+8)
        private int CalcDisplayStreak(int stored, DateTime? lastActivity)
        {
            if (stored <= 0 || lastActivity == null) return 0;
            DateTime today = DateTime.UtcNow.AddHours(8).Date;
            return (lastActivity.Value == today || lastActivity.Value == today.AddDays(-1))
                ? stored : 0;
        }

        private string ResolveAvatarUrl(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return "~/Image/default-avatar.png";
            if (url.StartsWith("http", StringComparison.OrdinalIgnoreCase)) return url;
            return "~/" + url.TrimStart('~', '/');
        }

        private void ShowMsg(string text, bool isError)
        {
            lblMessage.Visible = true;
            lblMessage.CssClass = isError
                ? "text-red-500 font-black text-sm flex-1 text-center sm:text-left"
                : "text-math-green font-black text-sm flex-1 text-center sm:text-left";
            lblMessage.Text = text;
        }
    }
}