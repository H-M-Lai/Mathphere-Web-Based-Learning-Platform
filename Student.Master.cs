using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace MathSphere
{
    public partial class Student : MasterPage
    {
        private string CS => ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        public bool IsGuest =>
            Session["IsGuest"] is bool b && b &&
            string.IsNullOrWhiteSpace(Convert.ToString(Session["UserID"]));

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsGuest)
            {
                if (!IsPostBack)
                    BindGuestHeader();
                return;
            }

            string userId = Convert.ToString(Session["UserID"])?.Trim();

            if (string.IsNullOrWhiteSpace(userId))
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!IsStudent(userId))
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                BindHeader(userId);
            }
        }

        private void BindGuestHeader()
        {
            litStreak.Text = "0";
            litXP.Text = "0";
            imgAvatar.ImageUrl = ResolveAvatarUrl("");
        }

        private void BindHeader(string userId)
        {
            litStreak.Text = GetCurrentStreak(userId).ToString();
            litXP.Text = GetTotalXp(userId).ToString("N0");

            string avatarUrl = GetAvatarUrl(userId);
            imgAvatar.ImageUrl = ResolveAvatarUrl(avatarUrl);
        }

        private bool IsStudent(string userId)
        {
            const string sql = @"
                SELECT COUNT(1)
                FROM dbo.userRoleTable ur
                JOIN dbo.Role r ON r.roleID = ur.roleID
                WHERE ur.userID = @uid AND r.roleName = 'Student';";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = userId;
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        // Falls back to 0 if the streak is stale or the student has never completed a block yet.
        private int GetCurrentStreak(string userId)
        {
            const string sql = @"
                SELECT TOP 1 ISNULL(currentStreak, 0) AS currentStreak,
                             lastActivityDate
                FROM dbo.StudentStreak
                WHERE userID = @uid;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = userId;
                con.Open();

                using (var rdr = cmd.ExecuteReader())
                {
                    if (!rdr.Read()) return 0;

                    int stored = rdr["currentStreak"] == DBNull.Value ? 0 : Convert.ToInt32(rdr["currentStreak"]);
                    DateTime? lastActivity = rdr["lastActivityDate"] == DBNull.Value
                        ? (DateTime?)null
                        : Convert.ToDateTime(rdr["lastActivityDate"]).Date;

                    return CalcDisplayStreak(stored, lastActivity);
                }
            }
        }

        private int CalcDisplayStreak(int stored, DateTime? lastActivity)
        {
            if (stored <= 0 || lastActivity == null) return 0;

            DateTime today = DateTime.UtcNow.AddHours(8).Date;
            return (lastActivity.Value == today || lastActivity.Value == today.AddDays(-1)) ? stored : 0;
        }

        private int GetTotalXp(string userId)
        {
            const string sql = @"
                SELECT ISNULL(SUM(points), 0)
                FROM dbo.studentScoreEventTable
                WHERE userID = @uid;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = userId;
                con.Open();
                var val = cmd.ExecuteScalar();
                return (val == null || val == DBNull.Value) ? 0 : Convert.ToInt32(val);
            }
        }

        private string GetAvatarUrl(string userId)
        {
            const string sql = @"
                SELECT ISNULL(AvatarUrl, '')
                FROM dbo.userTable
                WHERE userID = @uid;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = userId;
                con.Open();
                return Convert.ToString(cmd.ExecuteScalar()) ?? "";
            }
        }

        private string ResolveAvatarUrl(string avatarUrl)
        {
            if (string.IsNullOrWhiteSpace(avatarUrl))
                return "~/Image/default-avatar.png";
            if (avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                return avatarUrl;
            return "~/" + avatarUrl.TrimStart('~', '/');
        }
    }
}

