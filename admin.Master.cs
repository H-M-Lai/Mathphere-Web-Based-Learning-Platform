using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace MathSphere
{
    public partial class Admin : System.Web.UI.MasterPage
    {
        private string CS => ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect non-admin users back to login.
            string userId = Convert.ToString(Session["UserID"])?.Trim();

            if (string.IsNullOrWhiteSpace(userId))
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (Session["IsAdmin"] == null || !(bool)Session["IsAdmin"])
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                BindSidebar();
                SetActiveNavLink();
            }
        }

        // Sidebar data
        private void BindSidebar()
        {
            // Display the email prefix as the admin username
            if (Session["AdminEmail"] != null)
            {
                string email = Session["AdminEmail"].ToString();
                litAdminUsername.Text = email.Split('@')[0];
            }
            else if (Session["FullName"] != null)
            {
                litAdminUsername.Text = Session["FullName"].ToString();
            }

            // Load avatar if the admin has one stored
            try
            {
                string userId = Session["UserID"].ToString().Trim();

                using (var conn = new SqlConnection(CS))
                using (var cmd = new SqlCommand(
                    "SELECT ISNULL(AvatarUrl,'') FROM dbo.userTable WHERE userID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    conn.Open();
                    string avatarUrl = cmd.ExecuteScalar()?.ToString() ?? "";

                    if (!string.IsNullOrWhiteSpace(avatarUrl))
                    {
                        imgAdminAvatar.ImageUrl = avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase)
                            ? avatarUrl
                            : "~/" + avatarUrl.TrimStart('~', '/');
                    }
                }
            }
            catch { /* keep default avatar */ }
        }

        // Highlight the current sidebar page.
private const string ActiveCss = "flex items-center gap-3 px-4 py-3.5 bg-math-blue text-white rounded-2xl shadow-lg shadow-math-blue/15 transition-all text-sm font-black uppercase tracking-wide";
private const string InactiveCss = "flex items-center gap-3 px-4 py-3.5 text-gray-500 hover:bg-gray-50 hover:text-math-blue rounded-2xl transition-all group text-sm font-black uppercase tracking-wide";

        private void SetActiveNavLink()
        {
            string page = System.IO.Path.GetFileNameWithoutExtension(
                              Request.AppRelativeCurrentExecutionFilePath ?? "")
                          .ToLower();

            // Reset all links before applying the active state.
            navDashboard.Attributes["class"] = InactiveCss;
            navUserMgmt.Attributes["class"] = InactiveCss;
            navSysSettings.Attributes["class"] = InactiveCss;
            navForum.Attributes["class"] = InactiveCss;
            navHelp.Attributes["class"] = InactiveCss;

            switch (page)
            {
                case "admindashboard":
                    navDashboard.Attributes["class"] = ActiveCss; break;
                case "usermanagement":
                    navUserMgmt.Attributes["class"] = ActiveCss; break;
                case "systemsetting":
                    navSysSettings.Attributes["class"] = ActiveCss; break;
                case "forummoderation":
                    navForum.Attributes["class"] = ActiveCss; break;
                case "helpcenterhub":
                    navHelp.Attributes["class"] = ActiveCss; break;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx", true);
        }
    }
}





