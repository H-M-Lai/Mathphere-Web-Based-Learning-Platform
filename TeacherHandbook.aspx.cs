using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class TeacherHandbook : System.Web.UI.Page
    {
        private string CS =>
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindAdminEmail();
        }

        // Pull first active admin email — same pattern as StudentSupport
        private void BindAdminEmail()
        {
            string email = "admin@mathsphere.com"; // fallback

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 1 u.email
                    FROM   dbo.userTable u
                    JOIN   dbo.userRoleTable ur ON ur.userID = u.userID
                    JOIN   dbo.Role r           ON r.roleID  = ur.roleID
                    WHERE  LOWER(r.roleName) = 'admin'
                      AND  u.accountStatus = 1
                      AND  ISNULL(u.isDeleted,0) = 0
                    ORDER  BY u.CreatedAt ASC;", con))
                {
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != System.DBNull.Value)
                        email = Convert.ToString(result);
                }
            }
            catch { /* keep fallback */ }

            litAdminEmail.Text = HttpUtility.HtmlEncode(email);
            lnkEmailAdmin.NavigateUrl = "mailto:" + email;
        }
    }
}
