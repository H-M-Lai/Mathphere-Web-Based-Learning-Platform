using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace MathSphere
{
    public partial class teacherUploadVid : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string blockId = Request.QueryString["blockId"];
                if (string.IsNullOrWhiteSpace(blockId))
                {
                    ShowClientAlert("Missing blockId.");
                    return;
                }

                hdnBlockId.Value = blockId;
                hdnActiveTab.Value = "link"; // always link tab now

                // Load existing config from DB
                var cfg = LoadExistingVideoConfig(blockId);
                txtVideoUrl.Text = cfg.VideoUrl ?? "";
                txtCaption.Text = cfg.Caption ?? "";

                // Populate controls
                txtVideoUrl.Text = cfg.VideoUrl ?? "";
                txtCaption.Text = cfg.Caption ?? "";

                // Restore preview after page renders
                string safeUrl = (cfg.VideoUrl ?? "").Replace("\\", "\\\\").Replace("'", "\\'");
                if (!string.IsNullOrWhiteSpace(safeUrl))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "initPreview", $@"
                        document.addEventListener('DOMContentLoaded', function() {{
                            handleUrlInput('{safeUrl}');
                        }});
                    ", true);
                }
            }
        }

        // Load existing values from DB
        private (string VideoUrl, string Caption) LoadExistingVideoConfig(string blockId)
        {
            string videoUrl = null;
            string caption = null;

            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
        SELECT videoUrl, videoCaption
        FROM   dbo.blockContentTable
        WHERE  blockID = @blockID;", conn))
            {
                cmd.Parameters.AddWithValue("@blockID", blockId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        if (r["videoUrl"] != DBNull.Value) videoUrl = r["videoUrl"].ToString();
                        if (r["videoCaption"] != DBNull.Value) caption = r["videoCaption"].ToString();
                    }
                }
            }
            return (videoUrl, caption);
        }

        // Submit: save YouTube URL + caption + autoplay + notes
        protected void btnAttach_Click(object sender, EventArgs e)
        {
            string blockId = hdnBlockId.Value;
            if (string.IsNullOrWhiteSpace(blockId))
            {
                ShowClientAlert("Missing block ID.");
                return;
            }

            string videoUrl = (txtVideoUrl.Text ?? "").Trim();
            string caption = (txtCaption.Text ?? "").Trim();

            if (string.IsNullOrWhiteSpace(videoUrl))
            {
                ShowClientAlert("Please enter a YouTube URL.");
                return;
            }

            try
            {
                SaveVideoConfig(blockId, videoUrl, caption);
                ScriptManager.RegisterStartupScript(this, GetType(), "closeOverlay",
                    "window.parent.postMessage({ action: 'closeOverlay', type: 'video' }, window.location.origin);",
                    true);
            }
            catch (Exception ex)
            {
                ShowClientAlert("Error: " + ex.Message);
            }
        }

        // Upsert all video fields
        private void SaveVideoConfig(string blockId, string videoUrl, string caption)
        {
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        using (var cmd = new SqlCommand(@"
                    UPDATE dbo.moduleBlockTable
                    SET title = CASE
                                    WHEN title IS NULL
                                      OR LTRIM(RTRIM(title)) = ''
                                      OR title = 'Video'
                                    THEN CASE
                                             WHEN @caption <> '' THEN @caption
                                             ELSE 'Video Lesson'
                                         END
                                    ELSE title
                                END
                    WHERE blockID = @blockId", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@blockId", blockId);
                            cmd.Parameters.AddWithValue("@caption",
                                string.IsNullOrWhiteSpace(caption) ? "" : caption);
                            cmd.ExecuteNonQuery();
                        }

                        using (var cmd = new SqlCommand(@"
                    MERGE dbo.blockContentTable AS t
                    USING (SELECT @blockID AS blockID) AS s
                    ON    t.blockID = s.blockID
                    WHEN MATCHED THEN
                        UPDATE SET
                            videoUrl     = @videoUrl,
                            fileUrl      = NULL,
                            videoCaption = @caption
                    WHEN NOT MATCHED THEN
                        INSERT (blockID, videoUrl, fileUrl, textContent,
                                quizID, flashcardSetID, videoCaption)
                        VALUES (@blockID, @videoUrl, NULL, NULL,
                                NULL, NULL, @caption);",
                            conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@blockID", blockId);
                            cmd.Parameters.AddWithValue("@videoUrl", videoUrl);
                            cmd.Parameters.AddWithValue("@caption",
                                string.IsNullOrWhiteSpace(caption) ? (object)DBNull.Value : caption);
                            cmd.ExecuteNonQuery();
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
        }

        // Close the iframe overlay on the parent page
        private void RedirectToModuleBuilder()
        {
            string moduleId = (Request.QueryString["moduleId"] ?? "").Trim();
            string fallbackUrl = "moduleBuilder.aspx?id=" + Uri.EscapeDataString(moduleId) + "&saved=1";
            string script = @"
                (function() {
                    if (window.parent && window.parent !== window) {
                        window.parent.postMessage('closeOverlay', window.location.origin);
                    } else {
                        window.location.href = '" + fallbackUrl + @"';
                    }
                })();";
            ScriptManager.RegisterStartupScript(this, GetType(), "CloseOverlay", script, true);
        }

        private void ShowClientAlert(string message)
        {
            string safe = (message ?? "").Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "Alert",
                $"alert('{safe}');", true);
        }
    }
}





