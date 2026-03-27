using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;

namespace MathSphere
{
    public partial class systemSetting : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        // Picked up by the inline toast script in the .aspx
        protected string toastFlag = "0";

        // -
        //  Page Load
        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["IsAdmin"] == null || !(bool)Session["IsAdmin"])
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                LoadSettings();
                LoadLastUpdated();
                LoadStats();
            }
        }

        // -
        //  Load settings FROM dbo.SystemSettings into form fields
        // -
        private void LoadSettings()
        {
            txtFlashcardCompletion.Text = SystemSettingsHelper.GetInt("FlashcardCompletion", 10).ToString(CultureInfo.InvariantCulture);
            txtQuizPerfectScore.Text = SystemSettingsHelper.GetInt("QuizPerfectScore", 50).ToString(CultureInfo.InvariantCulture);
            txtStreakBonus.Text = SystemSettingsHelper.GetInt("StreakBonus7Day", 100).ToString(CultureInfo.InvariantCulture);
            txtInactivityThreshold.Text = SystemSettingsHelper.GetInt("InactivityThresholdDays", 3).ToString(CultureInfo.InvariantCulture);

            int hours = Clamp(SystemSettingsHelper.GetInt("DailyActivityWindowHours", 24), 1, 48);
            rngActivityWindow.Value = hours.ToString(CultureInfo.InvariantCulture);
            activityWindowValue.InnerHtml = $"{hours} <span class=\"text-xs uppercase\">Hours</span>";
        }

        // -
        //  Save settings TO dbo.SystemSettings (single transaction)
        //  Also logs to SysActivityLogTable using the EXACT columns:
        //    EventType, Description, CreatedAt, Status, Priority
        // -
        protected void btnSave_Click(object sender, EventArgs e)
        {
            int flashcard = ParseInt(txtFlashcardCompletion.Text, 10);
            int quiz = ParseInt(txtQuizPerfectScore.Text, 50);
            int streak = ParseInt(txtStreakBonus.Text, 100);
            int inactivity = ParseInt(txtInactivityThreshold.Text, 3);
            int hours = Clamp(ParseInt(rngActivityWindow.Value, 24), 1, 48);

            string actorId = Convert.ToString(Session["UserID"] ?? "");

            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (var tx = con.BeginTransaction())
                    {
                        try
                        {
                            // Upsert each setting
                            Upsert(con, tx, "FlashcardCompletion", flashcard.ToString(CultureInfo.InvariantCulture), actorId);
                            Upsert(con, tx, "QuizPerfectScore", quiz.ToString(CultureInfo.InvariantCulture), actorId);
                            Upsert(con, tx, "StreakBonus7Day", streak.ToString(CultureInfo.InvariantCulture), actorId);
                            Upsert(con, tx, "InactivityThresholdDays", inactivity.ToString(CultureInfo.InvariantCulture), actorId);
                            Upsert(con, tx, "DailyActivityWindowHours", hours.ToString(CultureInfo.InvariantCulture), actorId);

                            // Log to SysActivityLogTable
                            // Columns: EventType NVARCHAR(100), Description NVARCHAR(100),
                            //          CreatedAt DATETIME DEFAULT getdate(), Status NVARCHAR(50), Priority NVARCHAR(50)
                            using (var log = new SqlCommand(@"
                                INSERT INTO dbo.SysActivityLogTable
                                    (EventType, Description, CreatedAt, Status, Priority)
                                VALUES
                                    ('System Settings', 'Admin updated system settings.', GETDATE(), 'Success', 'Low');",
                                con, tx))
                            {
                                log.ExecuteNonQuery();
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

                // Sync slider label after postback
                rngActivityWindow.Value = hours.ToString(CultureInfo.InvariantCulture);
                activityWindowValue.InnerHtml = $"{hours} <span class=\"text-xs uppercase\">Hours</span>";

                toastFlag = "1";
                LoadLastUpdated();
                LoadStats();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SystemSettings save error: " + ex.Message);
            }
        }

        // -
        //  Load "Last saved by" metadata from dbo.SystemSettings
        // -
        private void LoadLastUpdated()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 1
                        s.UpdatedAt,
                        ISNULL(u.fullName, s.UpdatedByUserID) AS UpdatedBy
                    FROM  dbo.SystemSettings s
                    LEFT JOIN dbo.userTable u
                        ON u.userID = s.UpdatedByUserID
                       AND ISNULL(u.isDeleted, 0) = 0
                    WHERE s.UpdatedAt IS NOT NULL
                    ORDER BY s.UpdatedAt DESC;", con))
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            DateTime dt = Convert.ToDateTime(r["UpdatedAt"]);
                            litLastUpdated.Text = dt.ToLocalTime()
                                .ToString("dd MMM yyyy, h:mm tt", CultureInfo.InvariantCulture);
                            litLastUpdatedBy.Text = System.Web.HttpUtility.HtmlEncode(
                                r["UpdatedBy"]?.ToString() ?? "—");
                        }
                        else
                        {
                            litLastUpdated.Text = "Never";
                            litLastUpdatedBy.Text = "—";
                        }
                    }
                }
            }
            catch
            {
                litLastUpdated.Text = "Unavailable";
                litLastUpdatedBy.Text = "—";
            }
        }

        // -
        //  Live stats cards — uses actual DB column names verified from schema
        //
        //  userTable      : userID, accountStatus (bit), CreatedAt (datetime2),
        //                   isDeleted (bit, nullable)
        //  userRoleTable  : userID, roleID
        //  Role           : roleID, roleName
        // -
        private void LoadStats()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    ;WITH base AS (
                        SELECT
                            u.userID,
                            u.accountStatus,
                            u.CreatedAt,
                            ISNULL(u.isDeleted, 0)       AS isDeleted,
                            LOWER(ISNULL(r.roleName,'')) AS roleName
                        FROM      dbo.userTable u
                        LEFT JOIN dbo.userRoleTable ur ON ur.userID = u.userID
                        LEFT JOIN dbo.Role r           ON r.roleID  = ur.roleID
                    )
                    SELECT
                        SUM(CASE WHEN isDeleted = 0 THEN 1 ELSE 0 END)
                            AS totalUsers,
                        SUM(CASE WHEN isDeleted = 0 AND accountStatus = 1 THEN 1 ELSE 0 END)
                            AS activeUsers,
                        SUM(CASE WHEN isDeleted = 0 AND roleName IN ('admin','teacher') THEN 1 ELSE 0 END)
                            AS staffCount,
                        SUM(CASE WHEN isDeleted = 0
                                  AND CreatedAt >= DATEADD(DAY, -7, SYSUTCDATETIME())
                             THEN 1 ELSE 0 END)
                            AS newLast7Days
                    FROM base;", con))
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) return;

                        int total = Convert.ToInt32(r["totalUsers"], CultureInfo.InvariantCulture);
                        int active = Convert.ToInt32(r["activeUsers"], CultureInfo.InvariantCulture);
                        int staff = Convert.ToInt32(r["staffCount"], CultureInfo.InvariantCulture);
                        int growth7 = Convert.ToInt32(r["newLast7Days"], CultureInfo.InvariantCulture);

                        litStaffCount.Text = staff.ToString(CultureInfo.InvariantCulture);
                        litActiveRate.Text = total == 0
                            ? "0%"
                            : (active * 100.0 / total).ToString("0.0", CultureInfo.InvariantCulture) + "%";
                        litGrowth.Text = growth7.ToString(CultureInfo.InvariantCulture);
                    }
                }
            }
            catch { /* keep default zeros */ }
        }

        // -
        //  MERGE upsert helper for dbo.SystemSettings
        // -
        private void Upsert(SqlConnection con, SqlTransaction tx,
            string key, string value, string actorId)
        {
            using (var cmd = new SqlCommand(@"
                MERGE dbo.SystemSettings AS target
                USING (SELECT @key AS SettingKey) AS source
                    ON target.SettingKey = source.SettingKey
                WHEN MATCHED THEN
                    UPDATE SET
                        SettingValue    = @value,
                        UpdatedAt       = SYSUTCDATETIME(),
                        UpdatedByUserID = @uid
                WHEN NOT MATCHED THEN
                    INSERT (SettingKey, SettingValue, UpdatedAt, UpdatedByUserID)
                    VALUES (@key, @value, SYSUTCDATETIME(), @uid);",
                con, tx))
            {
                cmd.Parameters.AddWithValue("@key", key);
                cmd.Parameters.AddWithValue("@value", value);
                cmd.Parameters.AddWithValue("@uid",
                    string.IsNullOrWhiteSpace(actorId) ? (object)DBNull.Value : actorId);
                cmd.ExecuteNonQuery();
            }
        }

        // Helpers
        private static int ParseInt(string input, int fallback) =>
            int.TryParse(input, NumberStyles.Integer,
                CultureInfo.InvariantCulture, out int p) ? p : fallback;

        private static int Clamp(int v, int min, int max) =>
            v < min ? min : v > max ? max : v;
    }
}

