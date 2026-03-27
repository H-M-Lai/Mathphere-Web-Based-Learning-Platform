using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Web;

namespace MathSphere
{
    public partial class teacherRegistration : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["UserID"] != null)
                Response.Redirect("~/teacherDashboard.aspx");
            lnkGoogle.NavigateUrl = GoogleAuthUrl("teacher");
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;
            string confirm = txtConfirmPassword.Text;

            if (password != confirm)
            { ShowError("Passwords do not match."); return; }

            if (!RecaptchaHelper.Verify(Request))
            { ShowError("Please complete the CAPTCHA verification."); return; }

            if (!email.Contains("@") || !email.Contains("."))
            { ShowError("Please enter a valid email address."); return; }

            try
            {
                if (EmailExists(email))
                { ShowError("An account with this email already exists."); return; }

                string userId = GenerateUserId();
                string hash = HashPassword(password);   // 100,000 iterations
                string roleId = GetRoleId("Teacher");

                if (string.IsNullOrEmpty(roleId))
                { ShowError("System error: Teacher role not configured."); return; }

                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            using (var cmd = new SqlCommand(@"
                                INSERT INTO dbo.userTable
                                    (userID,fullName,email,passwordHash,accountStatus,createdAt,isDeleted)
                                VALUES(@uid,@name,@email,@hash,1,SYSUTCDATETIME(),0)", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@name", fullName);
                                cmd.Parameters.AddWithValue("@email", email);
                                cmd.Parameters.AddWithValue("@hash", hash);
                                cmd.ExecuteNonQuery();
                            }

                            using (var cmd = new SqlCommand(
                                "INSERT INTO dbo.userRoleTable(userID,roleID) VALUES(@uid,@rid)", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@rid", roleId);
                                cmd.ExecuteNonQuery();
                            }

                            using (var cmd = new SqlCommand(@"
                                INSERT INTO dbo.SysActivityLogTable
                                    (EventType,Description,CreatedAt,Status,Priority)
                                VALUES(@type,@desc,SYSUTCDATETIME(),@status,@priority)", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@type", "Register");
                                cmd.Parameters.AddWithValue("@desc", $"New teacher: {fullName} ({email})");
                                cmd.Parameters.AddWithValue("@status", "OK");
                                cmd.Parameters.AddWithValue("@priority", "Low");
                                cmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }

                Session["UserID"] = userId;
                Session["FullName"] = fullName;
                Session["RoleName"] = "Teacher";
                Session["IsAdmin"] = false;
                Response.Redirect("~/teacherDashboard.aspx", true);
            }
            catch (Exception ex)
            {
                ShowError("A system error occurred. Please try again.");
                System.Diagnostics.Debug.WriteLine("Teacher reg error: " + ex.Message);
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e) => Response.Redirect("~/Login.aspx");
        protected void btnStudentJoin_Click(object sender, EventArgs e) => Response.Redirect("~/Register.aspx");

        private bool EmailExists(string email)
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.userTable WHERE LOWER(email)=@email AND ISNULL(isDeleted,0)=0", conn))
            {
                cmd.Parameters.AddWithValue("@email", email);
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private string GenerateUserId()
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT ISNULL(MAX(CAST(SUBSTRING(RTRIM(userID),2,LEN(RTRIM(userID))-1) AS INT)),0)+1
                FROM dbo.userTable
                WHERE RTRIM(userID) LIKE 'U[0-9]%'
                  AND ISNUMERIC(SUBSTRING(RTRIM(userID),2,LEN(RTRIM(userID))-1))=1", conn))
            {
                conn.Open();
                return "U" + ((int)cmd.ExecuteScalar()).ToString("D3");
            }
        }

        private string GetRoleId(string roleName)
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT TOP 1 roleID FROM dbo.Role WHERE RTRIM(roleName)=@name", conn))
            {
                cmd.Parameters.AddWithValue("@name", roleName);
                conn.Open();
                return cmd.ExecuteScalar()?.ToString()?.Trim();
            }
        }

        // 100,000 iterations — consistent with ResetPassword.aspx.cs
        // Login.aspx.cs handles both 100,000 (new) and 10,000 (old accounts)
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

        private void ShowError(string msg)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "rounded-2xl border border-red-200 bg-red-50 px-4 py-3";
            lblMessage.Text = msg;
            lblMessage.CssClass = "text-red-700 font-semibold text-sm";
        }

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