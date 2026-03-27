using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;

namespace MathSphere
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        private string CS => ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        // Page_Load
        //
        //   always re-show the correct panel on every request (GET and POST)
        //   so the Panel is Visible=true before the button event handler runs.
        protected void Page_Load(object sender, EventArgs e)
        {
            string token = (Request.QueryString["token"] ?? "").Trim();

            if (!string.IsNullOrWhiteSpace(token))
            {
                if (!IsPostBack)
                {
                    // On first GET: validate the token and decide which panel to show
                    string userId = ValidateToken(token);
                    if (userId == null)
                    {
                        ShowPanel("invalid");
                        return;
                    }
                    // Store in ViewState so btnReset_Click can retrieve it
                    ViewState["ResetToken"] = token;
                }
                // On BOTH GET and POST with a token in the URL:
                // keep the reset form panel visible so its child controls are rendered
                ShowPanel("reset");
            }
            else
            {
                ShowPanel("request");
            }
        }

        private void ShowPanel(string which)
        {
            pnlRequestForm.Visible = (which == "request");
            pnlResetForm.Visible = (which == "reset");
            pnlTokenInvalid.Visible = (which == "invalid");
        }

        // Step 1: Request reset link
        protected void btnSendLink_Click(object sender, EventArgs e)
        {
            pnlRequestError.Visible = false;
            pnlEmailSent.Visible = false;

            string email = (txtRequestEmail.Text ?? "").Trim().ToLower();

            if (string.IsNullOrWhiteSpace(email) ||
    !Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                pnlRequestError.Visible = true;
                lblRequestError.Text = "Please enter a valid email address.";
                return;
            }

            try
            {
                string fullName = null, userId = null;
                bool isGoogle = false;

                using (var conn = new SqlConnection(CS))
                using (var cmd = new SqlCommand(@"
                    SELECT userID, fullName, passwordHash
                    FROM   dbo.userTable
                    WHERE  LOWER(email)        = @email
                      AND  ISNULL(isDeleted,0) = 0
                      AND  accountStatus       = 1", conn))
                {
                    cmd.Parameters.Add("@email", System.Data.SqlDbType.NVarChar, 50).Value = email;
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            userId = r["userID"].ToString();
                            fullName = r["fullName"].ToString();
                            string ph = r["passwordHash"] == DBNull.Value
                                        ? null : r["passwordHash"].ToString();
                            isGoogle = string.IsNullOrWhiteSpace(ph);
                        }
                    }
                }

                if (userId != null && !isGoogle)
                {
                    // Invalidate any open tokens for this user
                    using (var conn = new SqlConnection(CS))
                    using (var cmd = new SqlCommand(@"
                        UPDATE dbo.PasswordResetTokens
                        SET    IsUsed = 1
                        WHERE  UserID = @uid AND IsUsed = 0", conn))
                    {
                        cmd.Parameters.Add("@uid", System.Data.SqlDbType.VarChar, 10).Value = userId;
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }

                    string newToken = GenerateToken();
                    DateTime expiry = DateTime.UtcNow.AddMinutes(30);

                    using (var conn = new SqlConnection(CS))
                    using (var cmd = new SqlCommand(@"
                        INSERT INTO dbo.PasswordResetTokens
                            (Token, UserID, Email, ExpiresAt, IsUsed)
                        VALUES
                            (@token, @uid, @email, @expiry, 0)", conn))
                    {
                        cmd.Parameters.Add("@token", System.Data.SqlDbType.VarChar, 100).Value = newToken;
                        cmd.Parameters.Add("@uid", System.Data.SqlDbType.VarChar, 10).Value = userId;
                        cmd.Parameters.Add("@email", System.Data.SqlDbType.VarChar, 255).Value = email;
                        cmd.Parameters.Add("@expiry", System.Data.SqlDbType.DateTime).Value = expiry;
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }

                    string baseUrl = $"{Request.Url.Scheme}://{Request.Url.Authority}{Request.ApplicationPath.TrimEnd('/')}";
                    string resetLink = $"{baseUrl}/ResetPassword.aspx?token={HttpUtility.UrlEncode(newToken)}";
                    string ce = email, cn = fullName, cl = resetLink;
                    Task.Run(() =>
                    {
                        try { EmailService.SendPasswordResetLink(ce, cn, cl); }
                        catch (Exception ex)
                        { System.Diagnostics.Debug.WriteLine("Email error: " + ex.Message); }
                    });
                }

                // Always show success — never reveal whether the email exists
                pnlEmailSent.Visible = true;
                btnSendLink.Enabled = false;
            }
            catch (Exception ex)
            {
                pnlRequestError.Visible = true;
                lblRequestError.Text = "A system error occurred. Please try again.";
                System.Diagnostics.Debug.WriteLine("SendLink error: " + ex.Message);
            }
        }

        // Step 2: Set new password
        protected void btnReset_Click(object sender, EventArgs e)
        {
            pnlResetError.Visible = false;

            // Prefer ViewState; fall back to query string (both hold the same token)
            string token = (ViewState["ResetToken"]?.ToString()
                         ?? Request.QueryString["token"] ?? "").Trim();

            if (string.IsNullOrWhiteSpace(token))
            {
                SetResetError("Invalid session. Please request a new reset link.");
                return;
            }

            string newPw = txtNewPassword.Text ?? "";
            string confPw = txtConfirmPassword.Text ?? "";

            // -- Server-side guards (mirror the client-side validators) -
            if (newPw.Length < 8)
            {
                SetResetError("Password must be at least 8 characters.");
                return;
            }
            if (newPw != confPw)
            {
                SetResetError("Passwords do not match.");
                return;
            }
            if (!IsStrongEnough(newPw))
            {
                SetResetError("Password is too weak. Include uppercase, lowercase, a number, and a special character.");
                return;
            }

            try
            {
                // Re-validate the token on every submit
                string userId = ValidateToken(token);
                if (userId == null)
                {
                    ShowPanel("invalid");
                    return;
                }

                // Old password = new password check
                string currentHash = null;
                using (var conn = new SqlConnection(CS))
                using (var cmd = new SqlCommand(@"
                    SELECT passwordHash FROM dbo.userTable
                    WHERE  userID = @uid AND ISNULL(isDeleted,0) = 0", conn))
                {
                    cmd.Parameters.Add("@uid", System.Data.SqlDbType.NVarChar, 10).Value = userId;
                    conn.Open();
                    var obj = cmd.ExecuteScalar();
                    currentHash = (obj == null || obj == DBNull.Value) ? null : obj.ToString();
                }

                if (!string.IsNullOrWhiteSpace(currentHash) &&
                    VerifyPasswordPbkdf2(newPw, currentHash))
                {
                    SetResetError("New password cannot be the same as your current password.");
                    return;
                }

                // Hash the new password and save atomically
                string newHash = HashPassword(newPw);

                using (var conn = new SqlConnection(CS))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            using (var cmd = new SqlCommand(@"
                                UPDATE dbo.userTable
                                SET    passwordHash = @hash
                                WHERE  userID = @uid
                                  AND  ISNULL(isDeleted,0) = 0", conn, tx))
                            {
                                cmd.Parameters.Add("@hash", System.Data.SqlDbType.NVarChar, 255).Value = newHash;
                                cmd.Parameters.Add("@uid", System.Data.SqlDbType.NVarChar, 10).Value = userId;
                                int rows = cmd.ExecuteNonQuery();
                                if (rows == 0)
                                    throw new Exception("User record not found during password update.");
                            }

                            using (var cmd = new SqlCommand(@"
                                UPDATE dbo.PasswordResetTokens
                                SET    IsUsed = 1
                                WHERE  Token  = @token", conn, tx))
                            {
                                cmd.Parameters.Add("@token", System.Data.SqlDbType.VarChar, 100).Value = token;
                                cmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }

                btnReset.Visible = false;
                pnlResetError.Visible = false;
                pnlResetSuccess.Visible = true;
            }
            catch (Exception ex)
            {
                SetResetError("A system error occurred. Please try again.");
                System.Diagnostics.Debug.WriteLine("Reset error: " + ex.Message);
            }
        }

        // Helpers
        private void SetResetError(string msg)
        {
            lblResetError.Text = HttpUtility.HtmlEncode(msg);
            pnlResetError.Visible = true;
        }

        private string ValidateToken(string token)
        {
            using (var conn = new SqlConnection(CS))
            using (var cmd = new SqlCommand(@"
                SELECT UserID FROM dbo.PasswordResetTokens
                WHERE  Token     = @token
                  AND  IsUsed    = 0
                  AND  ExpiresAt > GETUTCDATE()", conn))
            {
                cmd.Parameters.Add("@token", System.Data.SqlDbType.VarChar, 100).Value = token;
                conn.Open();
                var result = cmd.ExecuteScalar();
                return result?.ToString();
            }
        }

        // Strong password: 8+ chars, at least one uppercase, lowercase, digit, symbol
        private static bool IsStrongEnough(string pw)
            => pw.Length >= 8
            && Regex.IsMatch(pw, @"[A-Z]")
            && Regex.IsMatch(pw, @"[a-z]")
            && Regex.IsMatch(pw, @"[0-9]")
            && Regex.IsMatch(pw, @"[^A-Za-z0-9]");

        private static string GenerateToken()
        {
            byte[] bytes = new byte[32];
            using (var rng = new RNGCryptoServiceProvider()) rng.GetBytes(bytes);
            return Convert.ToBase64String(bytes)
                .Replace("+", "-").Replace("/", "_").Replace("=", "");
        }

        // 100,000 iterations — must match HashPasswordPbkdf2() in userManagement.aspx.cs
        private static string HashPassword(string password)
        {
            byte[] salt = new byte[16];
            using (var rng = new RNGCryptoServiceProvider()) rng.GetBytes(salt);
            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256))
            {
                byte[] hash = pbkdf2.GetBytes(32);
                return Convert.ToBase64String(salt) + ":" + Convert.ToBase64String(hash);
            }
        }

        // Constant-time PBKDF2 verification — prevents timing attacks
        private static bool VerifyPasswordPbkdf2(string password, string storedHash)
        {
            try
            {
                string[] parts = storedHash.Split(':');
                if (parts.Length != 2) return false;
                byte[] salt = Convert.FromBase64String(parts[0]);
                byte[] expected = Convert.FromBase64String(parts[1]);
                using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256))
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
    }
}
