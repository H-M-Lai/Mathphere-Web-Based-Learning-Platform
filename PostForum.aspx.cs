using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Assignment
{
    public partial class PostForum : Page
    {
        private string CS => ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;
        private string UserId => (Session["UserID"] as string)?.Trim()
                               ?? (Session["userID"] as string)?.Trim();
        private string _lastError = "";

        // Page Load
        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(UserId))
                Response.Redirect("~/Login.aspx");

            if(!IsPostBack)
        {
                System.Diagnostics.Debug.WriteLine("[PostForum] UserId = '" + UserId + "'");
                System.Diagnostics.Debug.WriteLine("[PostForum] Session keys: " +
                    string.Join(", ", Session.Keys.Cast<string>()));

                BindModuleDropdown();
            }
        }

        private void BindModuleDropdown()
        {
            const string sqlEnrolled = @"
        SELECT DISTINCT m.moduleID, m.moduleTitle
        FROM   dbo.moduleTable m
        JOIN   dbo.courseTable c ON c.courseID = m.courseID
        JOIN   dbo.studentEnrolmentTable se ON se.courseID = c.courseID
        WHERE  se.userID      = @uid
          AND  se.enrolStatus = 1
          AND  m.Status       = 'Active'
        ORDER  BY m.moduleTitle ASC";

            var modules = new List<ListItem>();
            modules.Add(new ListItem("-- Select a Module --", ""));

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sqlEnrolled, con))
                {
                    cmd.Parameters.AddWithValue("@uid", UserId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            modules.Add(new ListItem(
                                dr["moduleTitle"].ToString(),
                                dr["moduleID"].ToString()));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[PostForum] BindModuleDropdown error: " + ex.Message);
            }

            if (modules.Count == 1)
            {
                modules.Add(new ListItem("(You are not enrolled in any course yet)", ""));
                btnPost.Enabled = false;
                lblError.Text = "You need to be enrolled in a course before you can post to the forum. Please contact your teacher to get enrolled.";
                lblError.Visible = true;
            }

            ddlModule.DataSource = modules;
            ddlModule.DataTextField = "Text";
            ddlModule.DataValueField = "Value";
            ddlModule.DataBind();
        }

        // Post button
        protected void btnPost_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = txtTitle.Text.Trim();
            string content = txtContent.Text.Trim();
            string moduleId = ddlModule.SelectedValue;

            // Guard: should not reach here if not enrolled, but double-check
            if (string.IsNullOrEmpty(moduleId))
            {
                lblError.Text = "Please select a module.";
                lblError.Visible = true;
                return;
            }

            // Handle optional photo upload
            string savedImagePath = null;
            if (fuPhoto.HasFile)
            {
                string ext = Path.GetExtension(fuPhoto.FileName).ToLowerInvariant();
                string[] allowed = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
                if (Array.IndexOf(allowed, ext) < 0)
                {
                    lblPhotoError.Text = "Only JPG, PNG, GIF or WebP images are allowed.";
                    lblPhotoError.Visible = true;
                    return;
                }
                if (fuPhoto.PostedFile.ContentLength > 5 * 1024 * 1024)
                {
                    lblPhotoError.Text = "Image must be 5 MB or smaller.";
                    lblPhotoError.Visible = true;
                    return;
                }

                string uploadFolder = Server.MapPath("~/Uploads/Forum/");
                if (!Directory.Exists(uploadFolder))
                    Directory.CreateDirectory(uploadFolder);

                string fileName = Guid.NewGuid().ToString("N") + ext;
                string fullPath = Path.Combine(uploadFolder, fileName);
                fuPhoto.SaveAs(fullPath);
                savedImagePath = "Uploads/Forum/" + fileName;
            }

            // Use module title as the category label
            string categoryLabel = ddlModule.SelectedItem?.Text ?? moduleId;

            if (InsertPost(title, content, categoryLabel, savedImagePath))
            {
                Response.Redirect("~/Forum.aspx");
            }
            else
            {
                lblError.Text = "Something went wrong saving your post. Please try again.";
                lblError.Visible = true;
            }
        }

        // Cancel
        protected void btnCancel_Click(object sender, EventArgs e)
            => Response.Redirect("~/Forum.aspx");

        // DB: insert post
        private bool InsertPost(string title, string content, string category, string imageUrl)
        {
            string fullContent = string.IsNullOrEmpty(imageUrl)
                ? content
                : content + "##IMG##" + imageUrl;

            const string sql = @"
                DECLARE @nextID int;

                SELECT @nextID = ISNULL(MAX(
                    CASE WHEN ISNUMERIC(SUBSTRING(LTRIM(RTRIM(postID)), 2, 20)) = 1
                         THEN CAST(SUBSTRING(LTRIM(RTRIM(postID)), 2, 20) AS int)
                         ELSE 0
                    END), 0) + 1
                FROM dbo.forumPostingTable;

                INSERT INTO dbo.forumPostingTable
                    (postID, authorUserID, title, content, category,
                     status, isDeleted, isTopSolution, isFlagged, createdAt)
                VALUES (
                    'P' + RIGHT('000000000' + CAST(@nextID AS nvarchar(9)), 9),
                    @uid, @title, @content, @category,
                    'Published', 0, 0, 0, SYSUTCDATETIME()
                );";

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@uid", UserId);
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@content", fullContent);
                    cmd.Parameters.AddWithValue("@category", category ?? "");
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                return true;
            }
            catch (Exception ex)
            {
                _lastError = ex.Message;
                System.Diagnostics.Debug.WriteLine("[PostForum] InsertPost error: " + ex.Message);
                return false;
            }
        }
    }
}
