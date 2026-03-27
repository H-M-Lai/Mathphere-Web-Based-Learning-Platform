using System;
using System.Web.UI;

namespace Guest
{
    public partial class LandingPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Already authenticated — skip landing page
            string uid = (Session["UserID"] ?? Session["userID"])?.ToString()?.Trim();
            if (!string.IsNullOrEmpty(uid))
            {
                string role = (Session["UserRole"] ?? Session["userRole"])?.ToString() ?? "";
                Response.Redirect(
                    role.Equals("Teacher", StringComparison.OrdinalIgnoreCase)
                        ? "~/TeacherDashboard.aspx"
                        : "~/StudentDashboard.aspx",
                    true);
            }
        }

        // Nav: Login
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // Hero: Register
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Register.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // Hero: Try as Guest
        // Sets a lightweight session flag so BrowseModule knows this is
        // a guest visit.  No UserID is ever written.
        protected void btnTryGuest_Click(object sender, EventArgs e)
        {
            // Clear any stale user identity
            Session.Remove("UserID");
            Session.Remove("userID");
            Session.Remove("UserRole");
            Session.Remove("userRole");

            // Mark as guest
            Session["IsGuest"] = true;

            Response.Redirect("~/BrowseModule.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // Quest card: Continue Quest ? Login
        protected void btnContinueQuest_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
