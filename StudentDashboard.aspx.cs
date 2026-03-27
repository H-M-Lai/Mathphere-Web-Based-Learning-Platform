using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Assignment
{
    public partial class StudentDashboard : System.Web.UI.Page
    {
        private string CS => ConfigurationManager
            .ConnectionStrings["MathSphereDB"].ConnectionString;

        private Dictionary<string, string> _settings;

        private Dictionary<string, string> GetSystemSettings()
        {
            if (_settings != null) return _settings;
            _settings = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            const string sql = "SELECT SettingKey, SettingValue FROM dbo.SystemSettings";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            _settings[dr["SettingKey"].ToString()] = dr["SettingValue"].ToString();
                }
            }
            catch { }
            if (!_settings.ContainsKey("StreakBonus7Day")) _settings["StreakBonus7Day"] = "100";
            if (!_settings.ContainsKey("DailyActivityWindowHours")) _settings["DailyActivityWindowHours"] = "24";
            if (!_settings.ContainsKey("InactivityThresholdDays")) _settings["InactivityThresholdDays"] = "3";
            return _settings;
        }

        private int SettingInt(string key, int fallback = 0)
        {
            var s = GetSystemSettings();
            return s.TryGetValue(key, out string v) && int.TryParse(v, out int i) ? i : fallback;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string userId = (Session["UserID"] as string)?.Trim()
                         ?? (Session["userID"] as string)?.Trim();

            if (!string.IsNullOrWhiteSpace(userId))
            {
                Session.Remove("IsGuest");
                if (!IsPostBack) LoadDashboard(userId);
                return;
            }

            if (Session["IsGuest"] is bool g && g)
            {
                Response.Redirect("~/BrowseModule.aspx", true);
                return;
            }

            Response.Redirect("~/Login.aspx", true);
        }

        private void LoadDashboard(string userId)
        {
            LoadStudentInfo(userId,
                out string fullName, out string avatarUrl,
                out int streak, out int totalXp);

            litStudentName.Text = System.Web.HttpUtility.HtmlEncode(fullName);
            litStudentNameSide.Text = System.Web.HttpUtility.HtmlEncode(GetFirstName(fullName));
            imgLeaderboardUser.ImageUrl = ResolveAvatarUrl(avatarUrl);

            int streakBonus = SettingInt("StreakBonus7Day", 100);
            int displayXp = (streak >= 7) ? totalXp + streakBonus : totalXp;
            litSideXP.Text = displayXp.ToString("N0");

            FireInactivityReminderIfNeeded(userId, SettingInt("InactivityThresholdDays", 3));

            LoadRankAndTop3(userId, out int yourRank);
            litGlobalRank.Text = yourRank > 0 ? yourRank.ToString() : "—";
            litSideRank.Text = yourRank > 0 ? yourRank.ToString() : "—";

            BindTopMissions(userId);
        }

        private void LoadStudentInfo(string userId,
            out string fullName, out string avatarUrl,
            out int streak, out int totalXp)
        {
            fullName = "Student"; avatarUrl = ""; streak = 0; totalXp = 0;
            const string sql = @"
                SELECT u.fullName,
                       ISNULL(u.AvatarUrl,'')     AS AvatarUrl,
                       ISNULL(s.currentStreak, 0) AS Streak,
                       ISNULL(x.TotalXP, 0)       AS TotalXP
                FROM dbo.userTable u
                LEFT JOIN dbo.StudentStreak s ON s.userID = u.userID
                LEFT JOIN (
                    SELECT userID, SUM(points) AS TotalXP
                    FROM   dbo.studentScoreEventTable
                    GROUP  BY userID
                ) x ON x.userID = u.userID
                WHERE u.userID = @uid";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        if (dr.Read())
                        {
                            fullName = dr["fullName"]?.ToString() ?? "Student";
                            avatarUrl = dr["AvatarUrl"]?.ToString() ?? "";
                            streak = Convert.ToInt32(dr["Streak"]);
                            totalXp = Convert.ToInt32(dr["TotalXP"]);
                        }
                }
            }
            catch { }
        }

        private void FireInactivityReminderIfNeeded(string userId, int thresholdDays)
        {
            // Table: dbo.userLoginTable (renamed from StudentLoginDaily)
            const string sql = @"
                DECLARE @lastLogin date;
                SELECT @lastLogin = MAX(loginDate)
                FROM   dbo.userLoginTable
                WHERE  userID = @uid;

                IF @lastLogin IS NOT NULL
                   AND DATEDIFF(day, @lastLogin, CAST(GETDATE() AS date)) >= @days
                   AND NOT EXISTS (
                       SELECT 1 FROM dbo.notificationTable
                       WHERE  userID    = @uid
                         AND  type      = 'Inactivity'
                         AND  isRead    = 0
                         AND  createdAt >= DATEADD(day, -@days, GETDATE()))
                BEGIN
                    INSERT INTO dbo.notificationTable
                        (notificationID, userID, title, message, type, linkUrl, isRead, createdAt)
                    VALUES (
                        'N' + RIGHT('000000000' + CAST(
                            ISNULL((
                                SELECT MAX(CAST(SUBSTRING(LTRIM(RTRIM(notificationID)), 2,
                                           LEN(LTRIM(RTRIM(notificationID))) - 1) AS bigint))
                                FROM   dbo.notificationTable
                                WHERE  LTRIM(RTRIM(notificationID)) LIKE 'N%'
                                  AND  ISNUMERIC(SUBSTRING(LTRIM(RTRIM(notificationID)), 2, 20)) = 1
                            ), 0) + 1
                        AS nvarchar(9)), 9),
                        @uid,
                        'We miss you!',
                        'You have not been active for ' + CAST(@days AS nvarchar) + ' days. Come back and keep your streak alive!',
                        'Inactivity',
                        '~/StudentDashboard.aspx',
                        0,
                        GETDATE()
                    );
                END";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@days", thresholdDays);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private void BindTopMissions(string userId)
        {
            var dt = new DataTable();
            const string sql = @"
                SELECT TOP 4
                    m.moduleID,
                    m.moduleTitle,
                    c.courseName,
                    CAST(ROUND(
                        CAST(
                            SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END)
                        AS float)
                        /
                        NULLIF(COUNT(mb.blockID), 0)
                        * 100
                    , 0) AS int)                                 AS Progress,
                    SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) AS DoneBlocks,
                    COUNT(mb.blockID)                            AS TotalBlocks,
                    MAX(sbp.completedAt)                         AS LastActiveAt
                FROM dbo.studentEnrolmentTable   e
                INNER JOIN dbo.courseTable        c  ON  c.courseID  = e.courseID
                                                    AND  c.status    = 'Active'
                INNER JOIN dbo.moduleTable        m  ON  m.courseID  = c.courseID
                                                    AND  m.Status    = 'Active'
                INNER JOIN dbo.moduleBlockTable   mb ON  mb.moduleID = m.moduleID
                LEFT  JOIN dbo.studentBlockProgressTable sbp
                                                   ON  sbp.blockID  = mb.blockID
                                                   AND sbp.userID   = e.userID
                WHERE e.userID      = @uid
                  AND e.enrolStatus = 1
                GROUP BY m.moduleID, m.moduleTitle, c.courseName
                HAVING
                    SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) > 0
                    AND
                    SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END)
                        < COUNT(mb.blockID)
                ORDER BY
                    CAST(
                        SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END)
                    AS float) / NULLIF(COUNT(mb.blockID),0) DESC,
                    MAX(sbp.completedAt) DESC";

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }
            catch
            {
                pnlNoMissions.Visible = true;
                rptTopMissions.Visible = false;
                return;
            }

            if (dt.Rows.Count == 0)
            {
                pnlNoMissions.Visible = true;
                rptTopMissions.Visible = false;
                return;
            }

            dt.Columns.Add("AccentClass", typeof(string));
            dt.Columns.Add("BadgeClass", typeof(string));
            dt.Columns.Add("Icon", typeof(string));
            for (int i = 0; i < dt.Rows.Count; i++) ApplyMissionCardStyle(dt.Rows[i], i);

            pnlNoMissions.Visible = false;
            rptTopMissions.Visible = true;
            rptTopMissions.DataSource = dt;
            rptTopMissions.DataBind();
        }

        private void ApplyMissionCardStyle(DataRow row, int index)
        {
            switch (index % 3)
            {
                case 0:
                    row["AccentClass"] = "bg-math-blue shadow-math-blue/20";
                    row["BadgeClass"] = "bg-math-blue/10 text-math-blue border border-math-blue/10";
                    row["Icon"] = "pentagon";
                    break;
                case 1:
                    row["AccentClass"] = "bg-math-green shadow-math-green/20";
                    row["BadgeClass"] = "bg-math-green/10 text-math-green border border-math-green/10";
                    row["Icon"] = "reorder";
                    break;
                default:
                    row["AccentClass"] = "bg-primary text-math-dark-blue shadow-primary/15";
                    row["BadgeClass"] = "bg-primary/25 text-math-dark-blue border border-primary/30";
                    row["Icon"] = "monitoring";
                    break;
            }
        }

        private void LoadRankAndTop3(string userId, out int yourRank)
        {
            yourRank = 0;
            const string sql = @"
                WITH xp AS (
                    SELECT u.userID,
                           u.fullName,
                           ISNULL(u.AvatarUrl,'')    AS AvatarUrl,
                           ISNULL(SUM(s.points), 0)  AS TotalXP
                    FROM dbo.userTable u
                    LEFT JOIN dbo.studentScoreEventTable s ON s.userID = u.userID
                    WHERE u.accountStatus = 1
                      AND ISNULL(u.isDeleted,0) != 1
                    GROUP BY u.userID, u.fullName, u.AvatarUrl
                )
                SELECT *, DENSE_RANK() OVER (ORDER BY TotalXP DESC) AS RankNo
                FROM   xp
                ORDER  BY RankNo";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        int counter = 0;
                        while (dr.Read())
                        {
                            counter++;
                            int rank = Convert.ToInt32(dr["RankNo"]);
                            string uid = dr["userID"]?.ToString()?.Trim() ?? "";
                            string name = dr["fullName"]?.ToString() ?? "";
                            string avatar = dr["AvatarUrl"]?.ToString() ?? "";
                            int xp = Convert.ToInt32(dr["TotalXP"]);

                            if (counter == 1) { imgRank1.ImageUrl = ResolveAvatarUrl(avatar); litRank1Name.Text = System.Web.HttpUtility.HtmlEncode(name); litRank1XP.Text = xp.ToString("N0"); }
                            else if (counter == 2) { imgRank2.ImageUrl = ResolveAvatarUrl(avatar); litRank2Name.Text = System.Web.HttpUtility.HtmlEncode(name); litRank2XP.Text = xp.ToString("N0"); }
                            else if (counter == 3) { imgRank3.ImageUrl = ResolveAvatarUrl(avatar); litRank3Name.Text = System.Web.HttpUtility.HtmlEncode(name); litRank3XP.Text = xp.ToString("N0"); }

                            if (uid == userId) yourRank = rank;
                        }
                    }
                }
            }
            catch { }
        }

        private string ResolveAvatarUrl(string avatarUrl)
        {
            if (string.IsNullOrWhiteSpace(avatarUrl))
                return ResolveUrl("~/Image/default-avatar.png");
            if (avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                return avatarUrl;
            return ResolveUrl("~/" + avatarUrl.TrimStart('~', '/'));
        }

        private string GetFirstName(string fullName)
        {
            fullName = (fullName ?? "").Trim();
            if (fullName.Length == 0) return "You";
            var parts = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return parts.Length > 0 ? parts[0] : fullName;
        }

        protected void btnReview_Click(object sender, EventArgs e) => Response.Redirect("ReviewPastAttempt.aspx");
        protected void btnFullLeaderboard_Click(object sender, EventArgs e) => Response.Redirect("Leaderboard.aspx");
    }
}