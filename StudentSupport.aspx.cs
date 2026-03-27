using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class StudentSupport : System.Web.UI.Page
    {
        private string CS =>
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        // -
        //  Page Load
        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindArticles();
                BindAdminEmail();
            }
        }

        // -
        //  Load admin email — pulls the first active admin account email
        // -
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
                    if (result != null && result != DBNull.Value)
                        email = Convert.ToString(result);
                }
            }
            catch { /* keep fallback */ }

            litAdminEmail.Text = HttpUtility.HtmlEncode(email);
            lnkEmailAdmin.NavigateUrl = "mailto:" + email;
        }

        // -
        //  ARTICLES — published only, from dbo.HelpArticle
        // -
        private void BindArticles()
        {
            var dt = new DataTable();
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 60
                        articleID,
                        title,
                        content,
                        ISNULL(status,'Published') AS status,
                        updatedAt
                    FROM   dbo.HelpArticle
                    WHERE  ISNULL(status,'Published') = 'Published'
                    ORDER  BY updatedAt DESC;", con))
                using (var da = new SqlDataAdapter(cmd))
                {
                    con.Open();
                    da.Fill(dt);
                }
            }
            catch { }

            if (dt.Rows.Count == 0)
            {
                pnlNoArticles.Visible = true;
                rptArticles.DataSource = null;
                rptArticles.DataBind();
                return;
            }

            pnlNoArticles.Visible = false;
            rptArticles.DataSource = dt;
            rptArticles.DataBind();
        }

        // Render each article card
        protected void rptArticles_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row = (DataRowView)e.Item.DataItem;
            var lit = (Literal)e.Item.FindControl("litArticle");
            if (lit == null) return;

            string id = Convert.ToString(row["articleID"]);
            string title = Convert.ToString(row["title"]);
            string content = Convert.ToString(row["content"]);
            string excerpt = content.Length > 140 ? content.Substring(0, 140) + "…" : content;

            string updatedAt = row["updatedAt"] == DBNull.Value ? ""
                : Convert.ToDateTime(row["updatedAt"]).ToLocalTime()
                    .ToString("dd MMM yyyy", CultureInfo.InvariantCulture);

            // JS-safe strings for onclick
            string titleJs = HttpUtility.JavaScriptStringEncode(title);
            string contentJs = HttpUtility.JavaScriptStringEncode(content);
            string dateJs = HttpUtility.JavaScriptStringEncode(updatedAt);

            string searchAttr = HttpUtility.HtmlAttributeEncode(title + " " + content);

            lit.Text = $@"
<div data-art-card=""{HttpUtility.HtmlAttributeEncode(id)}""
     data-search=""{searchAttr}""
     class=""art-card bg-white rounded-[2rem] p-6 shadow-sm border-2 border-gray-100 cursor-pointer group""
     onclick=""spOpenArticle('{titleJs}','{contentJs}','Help Article','{dateJs}')"">

  <div class=""inline-block px-3 py-1 bg-green-50 text-math-green rounded-full text-[10px] font-black uppercase tracking-widest mb-4"">
    Help Article
  </div>

  <h4 class=""text-base font-black text-math-dark-blue mb-2 leading-snug group-hover:text-math-blue transition-colors"">
    {HttpUtility.HtmlEncode(title)}
  </h4>

  <p class=""text-sm text-gray-500 font-medium leading-relaxed mb-5"">
    {HttpUtility.HtmlEncode(excerpt)}
  </p>

  <div class=""flex items-center justify-between"">
    <span class=""text-[10px] font-bold text-gray-300 uppercase tracking-widest"">{HttpUtility.HtmlEncode(updatedAt)}</span>
    <span class=""size-8 bg-math-blue/10 group-hover:bg-math-blue rounded-xl flex items-center justify-center transition-colors"">
      <span class=""material-symbols-outlined text-math-blue group-hover:text-white text-base transition-colors"">arrow_forward</span>
    </span>
  </div>
</div>";
        }
    }
}
