using System;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class helpCenterHub : System.Web.UI.Page
    {
        private string connectionString =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindLists();
                BindStats();
            }
        }

        private void BindLists()
        {
            DataTable articles = GetArticles();
            litArticleCount.Text = articles.Rows.Count.ToString(CultureInfo.InvariantCulture);
            rptArticles.DataSource = articles;
            rptArticles.DataBind();
        }

        protected void rptFaq_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;
            RenderCard(e, "faq");
        }

        protected void rptArticles_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;
            RenderCard(e, "article");
        }

        private void RenderCard(RepeaterItemEventArgs e, string type)
        {
            var row = (DataRowView)e.Item.DataItem;
            var lit = (Literal)e.Item.FindControl("litCard");
            if (lit == null) return;

            string id = Convert.ToString(row["Id"]);
            string category = Convert.ToString(row["Category"]);
            string title = Convert.ToString(row["Title"]);
            string excerpt = Convert.ToString(row["Excerpt"]);
            string catKey = (category ?? "").Trim().ToLowerInvariant();

            string badgeClass = "bg-blue-50 text-math-blue";
            if (catKey == "technical") badgeClass = "bg-purple-50 text-purple-600";
            if (catKey == "courses") badgeClass = "bg-green-50 text-math-green";
            if (catKey == "payments") badgeClass = "bg-yellow-50 text-yellow-600";
            if (catKey == "answered") badgeClass = "bg-green-50 text-math-green";
            if (catKey == "pending") badgeClass = "bg-yellow-50 text-yellow-600";
            if (catKey == "closed") badgeClass = "bg-gray-100 text-gray-500";
            if (catKey == "draft") badgeClass = "bg-yellow-50 text-yellow-700 border border-yellow-300";
            if (catKey == "published") badgeClass = "bg-green-50 text-math-green";

            string idJs = HttpUtility.JavaScriptStringEncode(id);
            string titleEnc = HttpUtility.HtmlEncode(title);
            string excerptEnc = HttpUtility.HtmlEncode(excerpt);
            string catEnc = HttpUtility.HtmlEncode(category);
            string titleJs = HttpUtility.JavaScriptStringEncode(title);
            string searchAttr = HttpUtility.HtmlAttributeEncode($"{category} {title} {excerpt}");

            lit.Text = $@"
<div data-hc-card=""1""
     data-type=""{type}""
     data-cat=""{HttpUtility.HtmlAttributeEncode(catKey)}""
     data-search=""{searchAttr}""
     class=""rounded-[2rem] border border-white/70 bg-white/95 p-6 shadow-[0_16px_32px_rgba(30,58,138,0.06)] relative group transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(30,58,138,0.10)]"">

  <div class=""absolute top-6 right-6 flex gap-2"">
    <button type=""button""
            class=""p-2 text-gray-300 hover:text-math-blue transition-colors rounded-xl""
            onclick=""hcEdit('{idJs}')"">
      <span class=""material-symbols-outlined"">edit_square</span>
    </button>
    <button type=""button""
            class=""p-2 text-gray-300 hover:text-red-500 transition-colors rounded-xl""
            onclick=""hcDelete('{idJs}', '{titleJs}')"">
      <span class=""material-symbols-outlined"">delete</span>
    </button>
  </div>

  <div class=""inline-block px-3 py-1 {badgeClass} rounded-full text-[10px] font-black uppercase tracking-widest mb-4"">{catEnc}</div>
  <h4 class=""text-lg font-black text-math-dark-blue mb-2 pr-20"">{titleEnc}</h4>
  <p class=""text-sm text-gray-500 font-medium leading-relaxed"">{excerptEnc}</p>
</div>";
        }

        protected void btnConfirmHcDelete_Click(object sender, EventArgs e)
        {
            string id = (hfDeleteId.Value ?? "").Trim();
            if (string.IsNullOrWhiteSpace(id)) return;
            DeleteHelpArticle(id);
            BindLists();
            BindStats();
        }

        private void DeleteHelpArticle(string articleId)
        {
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(
                "DELETE FROM dbo.HelpArticle WHERE articleID = @id;", con))
            {
                cmd.Parameters.AddWithValue("@id", articleId);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void DeleteAdminHelp(string helpId)
        {
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(
                "DELETE FROM dbo.adminHelpTable WHERE helpID = @id;", con))
            {
                cmd.Parameters.AddWithValue("@id", helpId);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // -
        //  Stats cards — all sourced from HelpArticle table.
        //  Help content stats are sourced from HelpArticle only.
        //
        //  litGrowth     ? articles published in the last 7 days
        //                  ("new content this week")
        //
        //  litActiveRate ? % of all articles that are Published (vs Draft)
        //                  ("how much content is live")
        //
        //  litStaffCount ? distinct authorUserID in HelpArticle
        //                  ("how many authors have contributed")
        // -
        private void BindStats()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT
                        -- New articles published this week
                        (SELECT COUNT(*)
                         FROM   dbo.HelpArticle
                         WHERE  createdAt >= DATEADD(DAY, -7, SYSUTCDATETIME())
                           AND  ISNULL(status, 'Published') = 'Published') AS Growth,

                        -- Total articles (all statuses)
                        (SELECT COUNT(*) FROM dbo.HelpArticle) AS Total,

                        -- Published articles
                        (SELECT COUNT(*)
                         FROM   dbo.HelpArticle
                         WHERE  ISNULL(status, 'Published') = 'Published') AS Published,

                        -- Distinct article authors
                        (SELECT COUNT(DISTINCT authorUserID)
                         FROM   dbo.HelpArticle) AS Staff;", con))
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) return;

                        int growth = Convert.ToInt32(r["Growth"], CultureInfo.InvariantCulture);
                        int total = Convert.ToInt32(r["Total"], CultureInfo.InvariantCulture);
                        int published = Convert.ToInt32(r["Published"], CultureInfo.InvariantCulture);
                        int staff = Convert.ToInt32(r["Staff"], CultureInfo.InvariantCulture);

                        // % of articles that are live (Published vs Draft)
                        double rate = total > 0 ? (published * 100.0 / total) : 0.0;

                        litGrowth.Text = "+" + growth.ToString(CultureInfo.InvariantCulture);
                        litActiveRate.Text = rate.ToString("0.0", CultureInfo.InvariantCulture) + "%";
                        litStaffCount.Text = staff.ToString(CultureInfo.InvariantCulture);
                    }
                }
            }
            catch
            {
                litGrowth.Text = "+0";
                litActiveRate.Text = "0%";
                litStaffCount.Text = "0";
            }
        }

        // -
        //  GetFaq — adminHelpTable
        //    Id       ? helpID
        //    Category ? status  (Answered=green  Pending=yellow  Closed=grey)
        //    Title    ? question
        //    Excerpt  ? answer (first 160 chars)
        // -
        private DataTable GetFaq()
        {
            var dt = new DataTable();
            dt.Columns.Add("Id", typeof(string));
            dt.Columns.Add("Category", typeof(string));
            dt.Columns.Add("Title", typeof(string));
            dt.Columns.Add("Excerpt", typeof(string));

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 50
                        helpID,
                        status,
                        question,
                        ISNULL(answer, 'Awaiting answer…') AS answer
                    FROM   dbo.adminHelpTable
                    ORDER  BY createdAt DESC;", con))
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            string id = r["helpID"]?.ToString() ?? "";
                            string category = r["status"]?.ToString() ?? "Pending";
                            string question = r["question"]?.ToString() ?? "";
                            string answer = r["answer"]?.ToString() ?? "";
                            string excerpt = answer.Length > 160
                                ? answer.Substring(0, 160) + "…" : answer;
                            dt.Rows.Add(id, category, question, excerpt);
                        }
                }
            }
            catch { }

            return dt;
        }

        // -
        //  GetArticles — HelpArticle
        //    Id       ? articleID
        //    Category ? status  (Draft=yellow  Published=green)
        //    Title    ? title
        //    Excerpt  ? content (first 160 chars)
        // -
        private DataTable GetArticles()
        {
            var dt = new DataTable();
            dt.Columns.Add("Id", typeof(string));
            dt.Columns.Add("Category", typeof(string));
            dt.Columns.Add("Title", typeof(string));
            dt.Columns.Add("Excerpt", typeof(string));

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 50
                        articleID,
                        title,
                        content,
                        ISNULL(status, 'Published') AS status
                    FROM   dbo.HelpArticle
                    ORDER  BY createdAt DESC;", con))
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            string id = r["articleID"]?.ToString() ?? "";
                            string title = r["title"]?.ToString() ?? "";
                            string content = r["content"]?.ToString() ?? "";
                            string status = r["status"]?.ToString() ?? "Published";
                            string excerpt = content.Length > 160
                                ? content.Substring(0, 160) + "…" : content;
                            dt.Rows.Add(id, status, title, excerpt);
                        }
                }
            }
            catch { }

            return dt;
        }
    }
}


