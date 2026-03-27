using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Web;

namespace MathSphere
{
    public partial class Register : System.Web.UI.Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["UserID"] != null)
                Response.Redirect("~/studentDashboard.aspx");
            lnkGoogle.NavigateUrl = GoogleAuthUrl("student");
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;

            string name = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string pass = txtPassword.Text.Trim();
            string confirm = txtConfirmPassword.Text.Trim();

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email) ||
                string.IsNullOrEmpty(pass) || string.IsNullOrEmpty(confirm))
            { ShowMessage("Please fill in all required fields."); return; }

            if (pass != confirm)
            { ShowMessage("Passwords do not match."); return; }

            if (pass.Length < 6)
            { ShowMessage("Password must be at least 6 characters."); return; }

            if (!email.Contains("@") || !email.Contains("."))
            { ShowMessage("Please enter a valid email address."); return; }

            if (!RecaptchaHelper.Verify(Request))
            { ShowMessage("Please complete the CAPTCHA verification."); return; }

            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    using (var chk = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.userTable WHERE LOWER(email)=@email AND isDeleted=0", conn))
                    {
                        chk.Parameters.AddWithValue("@email", email);
                        if ((int)chk.ExecuteScalar() > 0)
                        { ShowMessage("An account with this email already exists."); return; }
                    }

                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            string userId = GenerateUserId(conn, tx);
                            string passwordHash = HashPassword(pass);   // 100,000 iterations
                            string studentRoleId = GetStudentRoleId(conn, tx);

                            if (studentRoleId == null)
                            { ShowMessage("Registration unavailable. Please contact support."); tx.Rollback(); return; }

                            using (var cmd = new SqlCommand(@"
                                INSERT INTO dbo.userTable
                                    (userID,fullName,email,passwordHash,accountStatus,CreatedAt,isDeleted)
                                VALUES(@uid,@name,@email,@hash,1,SYSUTCDATETIME(),0)", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@name", name);
                                cmd.Parameters.AddWithValue("@email", email);
                                cmd.Parameters.AddWithValue("@hash", passwordHash);
                                cmd.ExecuteNonQuery();
                            }

                            using (var cmd = new SqlCommand(
                                "INSERT INTO dbo.userRoleTable(userID,roleID) VALUES(@uid,@rid)", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@rid", studentRoleId);
                                cmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            Session.Remove("IsGuest");
                            Session.Remove("GuestID");

                            Session["UserID"] = userId;
                            Session["FullName"] = name;
                            Session["RoleName"] = "Student";

                            Response.Redirect("~/studentDashboard.aspx", false);
                            Context.ApplicationInstance.CompleteRequest();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("A system error occurred. Please try again.");
                System.Diagnostics.Debug.WriteLine("Register error: " + ex.Message);
            }
        }

        private string GenerateUserId(SqlConnection conn, SqlTransaction tx)
        {
            using (var cmd = new SqlCommand(@"
                SELECT ISNULL(MAX(CAST(SUBSTRING(RTRIM(userID),2,LEN(RTRIM(userID))-1) AS INT)),0)+1
                FROM dbo.userTable
                WHERE RTRIM(userID) LIKE 'U[0-9]%'
                  AND ISNUMERIC(SUBSTRING(RTRIM(userID),2,LEN(RTRIM(userID))-1))=1", conn, tx))
            {
                return "U" + ((int)cmd.ExecuteScalar()).ToString("D3");
            }
        }

        private string GetStudentRoleId(SqlConnection conn, SqlTransaction tx)
        {
            using (var cmd = new SqlCommand(
                "SELECT TOP 1 roleID FROM dbo.Role WHERE LOWER(RTRIM(roleName))='student'", conn, tx))
            {
                var val = cmd.ExecuteScalar();
                return (val == null || val == DBNull.Value) ? null : val.ToString();
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

        private void ShowMessage(string msg)
        {
            lblMessage.Text = msg;
            pnlMessage.Visible = true;
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