using System;
using System.Security.Cryptography;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class resetUserPassword : System.Web.UI.Page
    {
        private string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        // -
        //  Page Load
        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            
            if (Session["IsAdmin"] == null || !(bool)Session["IsAdmin"])
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                LoadUserFromQueryString();
            }
        }

        // -
        //  Load target user from query string (?uid=...)
        //  Called from userManagement via:
        //    window.location.href = 'resetUserPassword.aspx?uid=' + uid;
        // -
        private void LoadUserFromQueryString()
        {
            string uid = Request.QueryString["uid"];

            if (string.IsNullOrEmpty(uid))
            {
                Response.Redirect("userManagement.aspx");
                return;
            }

            hdnTargetUserId.Value = uid;

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT FullName, Email
                FROM dbo.userTable
                WHERE userID = @UID AND IsDeleted = 0;", conn))
            {
                cmd.Parameters.Add("@UID", SqlDbType.NVarChar, 10).Value = uid;

                conn.Open();
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string fullName = rdr["FullName"].ToString();
                        string email = rdr["Email"].ToString();

                        hdnTargetUserName.Value = fullName;
                        hdnTargetEmail.Value = email;

                        lblUserName.Text = HttpUtility.HtmlEncode(fullName);
                    }
                    else
                    {
                        Response.Redirect("userManagement.aspx");
                        return;
                    }
                }
            }
        }


        // -
        //  Confirm Reset button click
        // -
        protected void btnConfirmReset_Click(object sender, EventArgs e)
        {
            string uid = hdnTargetUserId.Value;
            string name = hdnTargetUserName.Value;
            string email = hdnTargetEmail.Value;
            bool notify = chkNotify.Checked;

            if (string.IsNullOrEmpty(uid)) return;

            // Generate a secure token
            string token = GenerateSecureToken();
            DateTime expiry = DateTime.UtcNow.AddHours(24);

            string actorUserId = Session["userID"]?.ToString();

            // Persist token and immediately invalidate old password hash
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();

                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        using (var cmd = new SqlCommand(@"
                            UPDATE dbo.userTable 
                            SET ResetToken = @Token, 
                                ResetExpiry = @Expiry, 
                                UpdateDate = GETDATE()
                            WHERE uuserID = @UID;", conn, tx))
                        {
                            cmd.Parameters.Add("@Token", SqlDbType.NVarChar, 128).Value = token;
                            cmd.Parameters.Add("@Expiry", SqlDbType.DateTime2).Value = expiry;
                            cmd.Parameters.Add("@UID", SqlDbType.NVarChar, 10).Value = uid;

                            cmd.ExecuteNonQuery();

                        }

                        using (var logCmd = new SqlCommand(@"
                            INSERT INTO dbo.SysActivityLogTable(actorUserID, actionType, targetUserID, details, createdAt)
                            VALUES (actorUserID, 'PASSWORD_RESET_REQUEST', @targetUserID, @details, GETDATE());", conn, tx)) 
                        {
                            logCmd.Parameters.Add("@actorUserID", SqlDbType.NVarChar, 10).Value =
                        Session["userID"] ?? (object)DBNull.Value;

                            logCmd.Parameters.Add("@targetUserID", SqlDbType.NVarChar, 10).Value = uid;

                            logCmd.Parameters.Add("@details", SqlDbType.NVarChar, 200).Value =
                                $"Admin generated reset link for {name}";

                            logCmd.ExecuteNonQuery();
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

            // Optionally email the magic link
            if (notify && !string.IsNullOrEmpty(email))
            {
                string resetUrl = $"https://yourdomain.com/resetPassword.aspx?token={token}";
                SendResetEmail(email, name, resetUrl);
            }

            // Show success panel, populate success label
            lblSuccessName.Text = HttpUtility.HtmlEncode(name);
            pnlSuccess.Visible = true;
        }

        
        //  Email helper stub

        private string GenerateSecureToken()
        {
            byte[] bytes = new byte[64];

            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(bytes);
            }

            return Convert.ToBase64String(bytes);
        }
        private void SendResetEmail(string toEmail, string toName, string resetUrl)
        {
            using (var mail = new System.Net.Mail.MailMessage())
            {
                mail.To.Add(toEmail);
                mail.From = new System.Net.Mail.MailAddress("noreply@mathsphere.edu", "MathSphere Admin");
                mail.Subject = "Your MathSphere Password Reset Link";
                mail.IsBodyHtml = true;

                string safeName = HttpUtility.HtmlEncode(toName);

                mail.Body = $"<p>Hi {toName},</p><p>Click <a href='{resetUrl}'>here</a> to reset your password. This link expires in 24 hours.</p>";
                var smtp = new System.Net.Mail.SmtpClient("smtp.yourdomain.com");
                smtp.Send(mail);
            }
        }
    }
}
