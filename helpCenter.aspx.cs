using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;

namespace MathSphere
{
    public partial class helpCenter : System.Web.UI.Page
    {
        private string connectionString =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                rbDraft.Checked = true;
                pnlMsg.Visible = false;

                // Edit mode: ?edit=HA001
                string id = (Request.QueryString["edit"] ?? "").Trim();
                if (!string.IsNullOrWhiteSpace(id))
                {
                    hfArticleId.Value = id;
                    LoadArticle(id);
                }
            }
        }


        // -
        //  Publish to Help Center
        // -
        protected void btnPublish_Click(object sender, EventArgs e)
        {
            string title = (txtTitle.Text ?? "").Trim();
            string body = (txtBody.Text ?? "").Trim();

            // Determine status from the radio buttons
            string status = rbPublished.Checked ? "Published" : "Draft";

            if (string.IsNullOrWhiteSpace(title))
            {
                ShowMsg("Please enter an <b>Entry Title</b> before saving.");
                return;
            }
            if (status == "Published" && string.IsNullOrWhiteSpace(body))
            {
                ShowMsg("Please fill in the <b>Article Body</b> before publishing.");
                return;
            }

            try
            {
                SaveArticle(
                    (hfArticleId.Value ?? "").Trim(),
                    title, body, status);

                Response.Redirect("helpCenterHub.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                ShowMsg("Error: " + HttpUtility.HtmlEncode(ex.Message));
            }
        }

        // -
        //  SaveArticle — INSERT (new) or UPDATE (existing)
        //
        //  HelpArticle columns (DB schema):
        //    articleID    nvarchar(10)  PK
        //    authorUserID nvarchar(10)
        //    title        nvarchar(200)
        //    content      nvarchar(MAX)
        //    status       nvarchar(20)   ? 'Draft' | 'Published'
        //    createdAt    datetime2
        //    updatedAt    datetime2
        //
        //  Returns the articleID that was written.
        // -
        private string SaveArticle(string articleId, string title,
                                    string body, string status)
        {
            bool isNew = string.IsNullOrWhiteSpace(articleId);
            if (isNew) articleId = GenerateNextId();

            if (isNew)
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.HelpArticle
                        (articleID, authorUserID, title, content, status,
                         createdAt, updatedAt)
                    VALUES
                        (@id, @author, @title, @content, @status,
                         SYSUTCDATETIME(), SYSUTCDATETIME());", con))
                {
                    cmd.Parameters.AddWithValue("@id", articleId);
                    cmd.Parameters.AddWithValue("@author", CurrentAdminUserId());
                    cmd.Parameters.AddWithValue("@title", title ?? "");
                    cmd.Parameters.AddWithValue("@content", body ?? "");
                    cmd.Parameters.AddWithValue("@status", status ?? "Draft");
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            else
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.HelpArticle
                    SET    title     = @title,
                           content   = @content,
                           status    = @status,
                           updatedAt = SYSUTCDATETIME()
                    WHERE  articleID = @id;", con))
                {
                    cmd.Parameters.AddWithValue("@id", articleId);
                    cmd.Parameters.AddWithValue("@title", title ?? "");
                    cmd.Parameters.AddWithValue("@content", body ?? "");
                    cmd.Parameters.AddWithValue("@status", status ?? "Draft");
                    con.Open();
                    int rows = cmd.ExecuteNonQuery();
                    if (rows == 0)
                        throw new Exception("Article not found — it may have been deleted.");
                }
            }

            return articleId;
        }

        // -
        //  LoadArticle — populate form fields for Edit mode
        // -
        private void LoadArticle(string articleId)
        {
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT title,
                       content,
                       ISNULL(status, 'Published') AS status
                FROM   dbo.HelpArticle
                WHERE  articleID = @id;", con))
            {
                cmd.Parameters.AddWithValue("@id", articleId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read())
                    {
                        ShowMsg("?? Article not found.");
                        return;
                    }

                    txtTitle.Text = r["title"]?.ToString() ?? "";
                    txtBody.Text = r["content"]?.ToString() ?? "";

                    bool isDraft = string.Equals(
                        r["status"]?.ToString(), "Draft",
                        StringComparison.OrdinalIgnoreCase);
                    rbDraft.Checked = isDraft;
                    rbPublished.Checked = !isDraft;

                    litModeTitle.Text = "Edit Article";
                    litModeDesc.Text = "Editing: <strong>"
                        + HttpUtility.HtmlEncode(txtTitle.Text) + "</strong>";
                }
            }
        }

        // -
        //  Generate next HA-prefixed ID  ?  HA001, HA002, HA003 …
        // -
        private string GenerateNextId()
        {
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT ISNULL(
                    MAX(CAST(SUBSTRING(articleID, 3, LEN(articleID)) AS INT)), 0
                ) + 1
                FROM dbo.HelpArticle
                WHERE articleID LIKE 'HA[0-9]%';", con))
            {
                con.Open();
                int next = Convert.ToInt32(cmd.ExecuteScalar(),
                    CultureInfo.InvariantCulture);
                return "HA" + next.ToString("D3", CultureInfo.InvariantCulture);
            }
        }

        // -
        //  Helpers
        // -
        private string CurrentAdminUserId()
        {
            string id = Convert.ToString(Session["UserID"]);
            if (string.IsNullOrWhiteSpace(id))
                id = Convert.ToString(Session["userID"]);
            if (string.IsNullOrWhiteSpace(id))
                throw new Exception("Session expired. Please log in again.");
            return id.Trim();
        }

        private void ShowMsg(string html)
        {
            pnlMsg.Visible = true;
            litMsg.Text = html;
        }
    }
}
