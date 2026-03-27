using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Web;

namespace MathSphere
{
    public partial class Login : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private const int MAX_FAILED = 5;
        private const int LOCKOUT_MINUTES = 15;

        protected void Page_Load(object sender, EventArgs e)
        {
            lnkGoogle.NavigateUrl = GoogleAuthUrl("login");

            if (!IsPostBack)
            {
                string googleError = Request.QueryString["error"];
                if (!string.IsNullOrWhiteSpace(googleError))
                {
                    lblGoogleError.Text = Server.HtmlEncode(googleError);
                    pnlGoogleError.Visible = true;
                }

                if (Session["UserID"] != null)
                {
                    string role = Session["RoleName"]?.ToString() ?? "Student";
                    switch (role.ToLower())
                    {
                        case "admin": Response.Redirect("~/adminDashboard.aspx"); break;
                        case "teacher": Response.Redirect("~/teacherDashboard.aspx"); break;
                        default: Response.Redirect("~/studentDashboard.aspx"); break;
                    }
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;
            pnlCaptchaError.Visible = false;

            if (!RecaptchaHelper.Verify(Request))
            {
                pnlCaptchaError.Visible = true;
                return;
            }

            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    SELECT u.userID, u.fullName, u.passwordHash,
                           u.accountStatus,
                           ISNULL(u.isDeleted,        0) AS isDeleted,
                           ISNULL(u.failedLoginCount,  0) AS failedLoginCount,
                           u.lockedUntil,
                           RTRIM(r.roleName) AS roleName
                    FROM   dbo.userTable u
                    LEFT JOIN dbo.userRoleTable ur ON RTRIM(ur.userID) = RTRIM(u.userID)
                    LEFT JOIN dbo.Role r            ON RTRIM(r.roleID)  = RTRIM(ur.roleID)
                    WHERE  LOWER(u.email) = @email", conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            reader.Close();
                            MathSphere.adminDashboard.LogActivity(
                                "Login Failed",
                                $"Unknown email attempted: {Truncate(email, 80)}",
                                "Warning", "Low");
                            ShowError($"No account found for <strong>{Server.HtmlEncode(email)}</strong>. " +
                                      $"<a href='Register.aspx' class='underline font-black'>Register as student</a> or " +
                                      $"<a href='teacherRegistration.aspx' class='underline font-black'>Register as teacher</a>.");
                            return;
                        }

                        string userId = reader["userID"].ToString().Trim();
                        string fullName = reader["fullName"].ToString();
                        string passwordHash = reader["passwordHash"].ToString();
                        bool isActive = Convert.ToBoolean(reader["accountStatus"]);
                        bool isDeleted = Convert.ToBoolean(reader["isDeleted"]);
                        int failCount = Convert.ToInt32(reader["failedLoginCount"]);
                        DateTime? lockedUntil = reader["lockedUntil"] == DBNull.Value
                                                    ? (DateTime?)null
                                                    : Convert.ToDateTime(reader["lockedUntil"]);
                        string roleName = reader["roleName"]?.ToString()?.Trim() ?? "Student";
                        reader.Close();

                        if (isDeleted)
                        { ShowError("This account has been permanently deleted. Please contact support."); return; }

                        if (!isActive)
                        { ShowError("Your account has been disabled. Please contact an administrator."); return; }

                        // Lockout check
                        if (lockedUntil.HasValue && lockedUntil.Value > DateTime.UtcNow)
                        {
                            int minsLeft = (int)Math.Ceiling((lockedUntil.Value - DateTime.UtcNow).TotalMinutes);
                            ShowError($"Too many failed attempts. Account locked for {minsLeft} more minute{(minsLeft == 1 ? "" : "s")}.");
                            MathSphere.adminDashboard.LogActivity(
                                "Login Blocked",
                                $"{Truncate(fullName, 60)} ({userId}) attempted login while locked.",
                                "Warning", "Medium");
                            return;
                        }

                        // Password check
                        if (!VerifyPassword(password, passwordHash))
                        {
                            int newFailCount = failCount + 1;
                            bool shouldLock = newFailCount >= MAX_FAILED;

                            using (var upd = new SqlCommand(@"
                                UPDATE dbo.userTable
                                SET    failedLoginCount  = @cnt,
                                       lastFailedLoginAt = SYSUTCDATETIME(),
                                       lockedUntil       = @lockUntil
                                WHERE  RTRIM(userID) = @uid", conn))
                            {
                                upd.Parameters.AddWithValue("@cnt", newFailCount);
                                upd.Parameters.AddWithValue("@uid", userId);
                                upd.Parameters.AddWithValue("@lockUntil",
                                    shouldLock
                                        ? (object)DateTime.UtcNow.AddMinutes(LOCKOUT_MINUTES)
                                        : DBNull.Value);
                                upd.ExecuteNonQuery();
                            }

                            MathSphere.adminDashboard.LogActivity(
                                "Login Failed",
                                $"{Truncate(fullName, 60)} ({userId}) — attempt {newFailCount}/{MAX_FAILED}.",
                                "Warning",
                                newFailCount >= MAX_FAILED ? "High" : "Low");

                            if (shouldLock)
                            {
                                CreateSecurityAlert(userId, fullName, email, newFailCount);
                                ShowError($"Too many failed attempts. Your account has been locked for {LOCKOUT_MINUTES} minutes.");
                            }
                            else
                            {
                                int remaining = MAX_FAILED - newFailCount;
                                ShowError($"Incorrect password. " +
                                          $"<a href='ResetPassword.aspx' class='underline font-black'>Forgot your password?</a> " +
                                          $"({remaining} attempt{(remaining == 1 ? "" : "s")} remaining before lockout)");
                            }
                            return;
                        }

                        // SUCCESS
                        using (var upd = new SqlCommand(@"
                            UPDATE dbo.userTable
                            SET    failedLoginCount  = 0,
                                   lastFailedLoginAt = NULL,
                                   lockedUntil       = NULL
                            WHERE  RTRIM(userID) = @uid", conn))
                        {
                            upd.Parameters.AddWithValue("@uid", userId);
                            upd.ExecuteNonQuery();
                        }

                        // Records login for ALL roles (student, teacher, admin)
                        // so the Platform Activity chart shows everyone
                        RecordLoginDaily(conn, userId);

                        System.Threading.ThreadPool.QueueUserWorkItem(_ =>
                        {
                            try { InactivityNotifier.CheckAndNotifyInactiveStudents(); }
                            catch { }
                        });


                        MathSphere.adminDashboard.LogActivity(
                            "Login",
                            $"{Truncate(fullName, 60)} ({roleName}) logged in.",
                            "OK", "Low");

                        Session["UserID"] = userId;
                        Session["FullName"] = fullName;
                        Session["RoleName"] = roleName;
                        Session["IsAdmin"] = roleName.Equals("Admin", StringComparison.OrdinalIgnoreCase);

                        switch (roleName.ToLower())
                        {
                            case "admin": Response.Redirect("~/adminDashboard.aspx", true); break;
                            case "teacher": Response.Redirect("~/teacherDashboard.aspx", true); break;
                            default: Response.Redirect("~/studentDashboard.aspx", true); break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("A system error occurred. Please try again.");
                System.Diagnostics.Debug.WriteLine("Login error: " + ex.Message);
            }
        }

        // -
        //  CreateSecurityAlert
        // -
        private void CreateSecurityAlert(string userId, string fullName,
                                         string email, int attempts)
        {
            try
            {
                using (var con = new SqlConnection(cs))
                {
                    con.Open();

                    // Guard: skip if an open Security alert already exists
                    // for this user (prevents duplicate alerts per lockout window)
                    using (var chk = new SqlCommand(@"
                        SELECT COUNT(*) FROM dbo.adminAlertTable
                        WHERE  alertType   = 'Security'
                          AND  alertStatus = 'Open'
                          AND  description LIKE @pattern", con))
                    {
                        chk.Parameters.AddWithValue("@pattern", $"%{userId}%");
                        if ((int)chk.ExecuteScalar() > 0) return;
                    }

                    // Generate next alertID in AL001, AL002… format
                    string alertId;
                    using (var idCmd = new SqlCommand(@"
                        SELECT ISNULL(MAX(CAST(SUBSTRING(alertID,3,LEN(alertID)) AS INT)),0)+1
                        FROM   dbo.adminAlertTable
                        WHERE  alertID LIKE 'AL%'
                          AND  ISNUMERIC(SUBSTRING(alertID,3,LEN(alertID)))=1", con))
                    {
                        alertId = "AL" + Convert.ToInt32(idCmd.ExecuteScalar()).ToString("D3");
                    }

                    // Only inserts columns confirmed to exist in adminAlertTable:
                    // alertID, alertType, title, description,
                    // priority, alertStatus, createdAt, resolvedAt, resolvedBy
                    using (var ins = new SqlCommand(@"
                        INSERT INTO dbo.adminAlertTable
                            (alertID, alertType, title, description,
                             priority, alertStatus, createdAt, resolvedAt, resolvedBy)
                        VALUES
                            (@id, 'Security', 'Multiple Failed Logins', @desc,
                             'High', 'Open', SYSUTCDATETIME(), NULL, NULL)", con))
                    {
                        ins.Parameters.AddWithValue("@id", alertId);
                        ins.Parameters.AddWithValue("@desc",
                            $"{attempts} failed login attempts for {Truncate(fullName, 40)} ({userId}) — {Truncate(email, 40)}.");
                        ins.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[CreateSecurityAlert] " + ex.Message);
            }
        }

        // -
        //  RecordLoginDaily
        //
        //  Writes to userLoginTable for ALL roles — student, teacher, admin.
        //  The dashboard chart joins to userRoleTable to split by role,
        //  so inserting all users here makes the chart show everyone.
        // -
        private static void RecordLoginDaily(SqlConnection conn, string userId)
        {
            try
            {
                // Only insert once per user per day (idempotent)
                using (var cmd = new SqlCommand(@"
                    IF NOT EXISTS (
                        SELECT 1 FROM dbo.userLoginTable
                        WHERE  RTRIM(userID)  = @uid
                          AND  loginDate = CAST(SYSUTCDATETIME() AS DATE)
                    )
                    BEGIN
                        DECLARE @nextId NVARCHAR(10)
                        SELECT  @nextId = 'SL' +
                            RIGHT('000000000' + CAST(
                                ISNULL(MAX(CAST(SUBSTRING(loginID,3,LEN(loginID)) AS INT)),0)+1
                            AS NVARCHAR), 8)
                        FROM dbo.userLoginTable
                        WHERE loginID LIKE 'SL%'
                          AND ISNUMERIC(SUBSTRING(loginID,3,LEN(loginID)))=1

                        INSERT INTO dbo.userLoginTable (loginID, userID, loginDate)
                        VALUES (@nextId, @uid, CAST(SYSUTCDATETIME() AS DATE))
                    END", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine("[RecordLoginDaily] " + ex.Message); }
        }

        // Password verification
        private bool VerifyPassword(string password, string storedHash)
        {
            if (string.IsNullOrWhiteSpace(storedHash)) return false;

            // Plain-text fallback for seeded/dev accounts
            if (!storedHash.Contains(":") && storedHash != "GOOGLE_AUTH")
                return password == storedHash;

            if (storedHash == "GOOGLE_AUTH") return false;

            if (TryVerifyPbkdf2(password, storedHash, 100000)) return true;
            if (TryVerifyPbkdf2(password, storedHash, 10000)) return true;
            return false;
        }

        private static bool TryVerifyPbkdf2(string password, string storedHash, int iterations)
        {
            try
            {
                var parts = storedHash.Split(':');
                if (parts.Length != 2) return false;
                byte[] salt = Convert.FromBase64String(parts[0]);
                byte[] expected = Convert.FromBase64String(parts[1]);
                using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations, HashAlgorithmName.SHA256))
                {
                    byte[] actual = pbkdf2.GetBytes(32);
                    if (actual.Length != expected.Length) return false;
                    int diff = 0;
                    for (int i = 0; i < actual.Length; i++) diff |= actual[i] ^ expected[i];
                    return diff == 0;
                }
            }
            catch { return false; }
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            pnlError.Visible = true;
        }

        private static string Truncate(string s, int max) =>
            string.IsNullOrEmpty(s) ? "" : s.Length <= max ? s : s.Substring(0, max);

        protected string GoogleAuthUrl(string state)
        {
            string clientId = ConfigurationManager.AppSettings["GoogleClientId"];
            string redirectUri = ConfigurationManager.AppSettings["GoogleRedirectUri"];
            System.Diagnostics.Debug.WriteLine($"OAuth redirectUri being sent: {redirectUri}");
            return "https://accounts.google.com/o/oauth2/v2/auth" +
                   "?client_id=" + HttpUtility.UrlEncode(clientId) +
                   "&redirect_uri=" + HttpUtility.UrlEncode(redirectUri) +
                   "&response_type=code" +
                   "&scope=openid%20email%20profile" +
                   "&state=" + HttpUtility.UrlEncode(state) +
                   "&prompt=select_account";
        }
    }
}
