using System;
using System.Web.UI;

namespace MathLab
{
    public partial class teacherForgetPassword : Page
    {
        // Getter ready for DB connection/Logic
        public string RecoveryEmail => txtRecoveryEmail.Text.Trim();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblStatus.Text = "";
            }
        }

        protected void btnRecover_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(RecoveryEmail))
            {
                ShowMessage("Please enter your email address.", "text-red-500");
                return;
            }

            // Database Connection Logic Placeholder
            if (UserExistsInDatabase(RecoveryEmail))
            {
                // Here you would trigger your email service (SMTP/SendGrid)
                bool emailSent = SendRecoveryEmail(RecoveryEmail);

                if (emailSent)
                {
                    ShowMessage("Magic link sent! Check your inbox 📬", "text-lime-green");
                    txtRecoveryEmail.Text = ""; // Clear input
                }
                else
                {
                    ShowMessage("Error sending email. Please try again later.", "text-red-500");
                }
            }
            else
            {
                // Standard security practice: don't reveal if email exists or not
                ShowMessage("If that email is in our system, a link is on its way!", "text-electric-blue");
            }
        }

        private bool UserExistsInDatabase(string email)
        {
            // TODO: Replace with ADO.NET query (e.g., SELECT TOP 1 1 FROM Teachers WHERE Email = @email)
            return true;
        }

        private bool SendRecoveryEmail(string email)
        {
            // TODO: Implement System.Net.Mail logic here
            return true;
        }

        private void ShowMessage(string msg, string colorClass)
        {
            lblStatus.Text = msg;
            lblStatus.CssClass = $"block text-center font-bold text-sm mt-4 {colorClass}";
        }
    }
}