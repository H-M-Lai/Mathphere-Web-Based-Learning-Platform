using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;

namespace MathSphere
{
    public static class InactivityNotifier
    {
        private static string CS =>
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        public static void CheckAndNotifyInactiveStudents()
        {
            int thresholdDays = SystemSettingsHelper.GetInt("InactivityThresholdDays", 3);

            try
            {
                using (var con = new SqlConnection(CS))
                {
                    con.Open();

                    var students = new List<(string id, string email, string name, DateTime lastActive)>();

                    using (var cmd = new SqlCommand(@"
                        SELECT u.userID, u.email, u.fullName,
                               ISNULL(ss.lastActivityDate,
                                   CAST(u.CreatedAt AS DATE)) AS lastActive
                        FROM   dbo.userTable u
                        JOIN   dbo.userRoleTable ur ON ur.userID = u.userID
                        JOIN   dbo.Role r            ON r.roleID  = ur.roleID
                        LEFT JOIN dbo.StudentStreak ss ON ss.userID = u.userID
                        WHERE  r.roleName      = 'Student'
                          AND  u.accountStatus = 1
                          AND  ISNULL(u.isDeleted, 0) = 0
                          AND  DATEDIFF(DAY,
                                 ISNULL(ss.lastActivityDate,
                                     CAST(u.CreatedAt AS DATE)),
                                 CAST(SYSUTCDATETIME() AS DATE)) >= @threshold
                          AND  NOT EXISTS (
                              SELECT 1 FROM dbo.notificationTable n
                              WHERE  n.userID = u.userID
                                AND  n.type   = 'Inactivity'
                                AND  n.createdAt >= DATEADD(DAY,
                                         -@threshold, SYSUTCDATETIME())
                          );", con))
                    {
                        cmd.Parameters.AddWithValue("@threshold", thresholdDays);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                                students.Add((
                                    r["userID"].ToString(),
                                    r["email"].ToString(),
                                    r["fullName"].ToString(),
                                    Convert.ToDateTime(r["lastActive"])
                                ));
                    }

                    foreach (var s in students)
                    {
                        InsertInAppNotification(con, s.id, thresholdDays);

                        try
                        {
                            EmailService.SendInactivityReminder(
                                s.email, s.name, thresholdDays, s.lastActive);
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine(
                                "[InactivityNotifier] Email failed for "
                                + s.id + ": " + ex.Message);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[InactivityNotifier] " + ex.Message);
            }
        }

        private static void InsertInAppNotification(
            SqlConnection con, string userId, int days)
        {
            try
            {
                string nid;
                using (var cmd = new SqlCommand(@"
                    SELECT 'NT' + RIGHT('00000000' + CAST(
                        ISNULL(MAX(TRY_CAST(
                            SUBSTRING(LTRIM(RTRIM(notificationID)), 3,
                                LEN(notificationID)) AS INT)), 0) + 1
                    AS NVARCHAR(8)), 8)
                    FROM dbo.notificationTable
                    WHERE notificationID LIKE 'NT[0-9]%';", con))
                    nid = cmd.ExecuteScalar()?.ToString() ?? "NT00000001";

                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.notificationTable
                        (notificationID, userID, title, message,
                         type, isRead, createdAt)
                    VALUES
                        (@nid, @uid,
                         N'🔥 Don''t lose your streak!',
                         @msg,
                         'Inactivity', 0, SYSUTCDATETIME());", con))
                {
                    cmd.Parameters.AddWithValue("@nid", nid);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@msg",
                        $"You haven't been active for {days} days. " +
                        "Log in and keep your streak alive!");
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[InactivityNotifier.InsertInApp] " + ex.Message);
            }
        }
    }
}