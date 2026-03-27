using System;
using System.Configuration;
using System.Data.SqlClient;

namespace MathSphere
{
    public partial class Teacher : System.Web.UI.MasterPage
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["RoleName"]?.ToString() != "Teacher")
            {
                Session.Clear();
                Response.Redirect("~/Login.aspx", true);
                return;
            }
            if (!IsPostBack)
                LoadTeacherNav();
        }

        private void LoadTeacherNav()
        {
            string teacherId = Session["UserID"].ToString();
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT fullName, AvatarUrl FROM dbo.userTable WHERE userID = @tid", conn))
            {
                cmd.Parameters.AddWithValue("@tid", teacherId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        litTeacherNameNav.Text = r["fullName"]?.ToString() ?? "Teacher";
                        string pic = r["AvatarUrl"]?.ToString();
                        if (!string.IsNullOrWhiteSpace(pic))
                            imgTeacherAvatar.ImageUrl = pic;
                    }
                }
            }
        }
    }
}