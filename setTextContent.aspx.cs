using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace MathSphere
{
    public partial class setTextContent : System.Web.UI.Page
    {
        private string cs = System.Configuration.ConfigurationManager
                              .ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string blockId = Request.QueryString["blockId"];
                string moduleId = Request.QueryString["moduleId"];
                if (!string.IsNullOrEmpty(blockId)) hdnBlockId.Value = blockId;
                if (!string.IsNullOrEmpty(moduleId)) hdnModuleId.Value = moduleId;
                LoadTextContent(blockId);
            }
        }

        private void LoadTextContent(string blockId)
        {
            if (string.IsNullOrEmpty(blockId)) return;
            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    SELECT ISNULL(mb.title,'') AS ContentTitle,
                           ISNULL(bc.textContent,'') AS BodyHtml,
                           ISNULL(bc.fileUrl,'') AS PdfPath
                    FROM   dbo.moduleBlockTable mb
                    LEFT JOIN dbo.blockContentTable bc ON bc.blockID = mb.blockID
                    WHERE  mb.blockID = @blockId", conn))
                {
                    cmd.Parameters.AddWithValue("@blockId", blockId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            txtTitle.Text = r["ContentTitle"].ToString();
                            hdnBodyHtml.Value = r["BodyHtml"].ToString();
                            string pdfPath = r["PdfPath"].ToString();
                            if (!string.IsNullOrEmpty(pdfPath))
                            {
                                hdnPdfPath.Value = pdfPath;
                                hdnPdfFileName.Value = System.IO.Path.GetFileName(pdfPath);
                            }
                        }
                    }
                }
            }
            catch (Exception ex) { ShowAlert("Error loading: " + ex.Message); }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                string blockId = hdnBlockId.Value;
                if (string.IsNullOrEmpty(blockId)) { ShowAlert("Block ID missing."); return; }
                string title = txtTitle.Text.Trim();

                // Decode base64 HTML from JS
                string bodyHtml = "";
                string encoded = hdnBodyHtml.Value;
                if (!string.IsNullOrEmpty(encoded))
                {
                    try { bodyHtml = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encoded)); }
                    catch { bodyHtml = encoded; }
                }

                // PDF: keep existing unless new file uploaded or user cleared
                string pdfPath = hdnPdfPath.Value;
                if (fileUploadPdf.HasFile)
                {
                    string ext = System.IO.Path.GetExtension(fileUploadPdf.FileName).ToLower();
                    if (ext != ".pdf") { ShowAlert("Only PDF files allowed."); return; }
                    if (fileUploadPdf.PostedFile.ContentLength > 10 * 1024 * 1024) { ShowAlert("PDF exceeds 10MB."); return; }
                    string safeFile = System.IO.Path.GetFileName(fileUploadPdf.FileName);
                    string uploadDir = Server.MapPath("~/Uploads/PDF/");
                    if (!System.IO.Directory.Exists(uploadDir)) System.IO.Directory.CreateDirectory(uploadDir);
                    fileUploadPdf.SaveAs(System.IO.Path.Combine(uploadDir, safeFile));
                    pdfPath = "~/Uploads/PDF/" + safeFile;
                }
                else if (string.IsNullOrEmpty(hdnPdfPath.Value))
                {
                    pdfPath = null; // user cleared PDF
                }

                SaveContent(blockId, title, bodyHtml, pdfPath);
            }
            catch (Exception ex) { ShowAlert("Error: " + ex.Message); }
        }

        private void SaveContent(string blockId, string title, string bodyHtml, string pdfPath)
        {
            try
            {
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Update block card title
                            using (var cmd = new SqlCommand(
                                "UPDATE dbo.moduleBlockTable SET title=@t WHERE blockID=@b;", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@t", title);
                                cmd.Parameters.AddWithValue("@b", blockId);
                                cmd.ExecuteNonQuery();
                            }

                            // 2. MERGE blockContentTable
                            // UPDATE only changes textContent + fileUrl (leaves video/quiz/FC intact)
                            // INSERT includes all columns: videoCaption, videoAutoplay, videoNotes
                            bool newFile = fileUploadPdf.HasFile;
                            bool cleared = pdfPath == null;

                            using (var cmd = new SqlCommand(@"
                                MERGE dbo.blockContentTable AS t
                                USING (SELECT @blockId AS blockID) AS s ON t.blockID=s.blockID
                                WHEN MATCHED THEN UPDATE SET
                                    textContent = @textContent,
                                    fileUrl = CASE
                                        WHEN @clearPdf=1 THEN NULL
                                        WHEN @hasPdf=1   THEN @fileUrl
                                        ELSE t.fileUrl
                                    END
                                WHEN NOT MATCHED THEN INSERT
                                    (blockID,videoUrl,fileUrl,textContent,
                                     quizID,flashcardSetID,videoCaption,videoAutoplay,videoNotes)
                                VALUES
                                    (@blockId,NULL,@fileUrl,@textContent,
                                     NULL,NULL,NULL,0,NULL);", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@blockId", blockId);
                                cmd.Parameters.AddWithValue("@textContent", bodyHtml);
                                cmd.Parameters.AddWithValue("@fileUrl", pdfPath != null ? (object)pdfPath : DBNull.Value);
                                cmd.Parameters.AddWithValue("@hasPdf", newFile ? 1 : 0);
                                cmd.Parameters.AddWithValue("@clearPdf", cleared ? 1 : 0);
                                cmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            CloseOverlay();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
            }
            catch (Exception ex) { ShowAlert("Error saving: " + ex.Message); }
        }

        private void CloseOverlay()
        {
            string moduleId = (Request.QueryString["moduleId"] ?? "").Trim();
            string fallbackUrl = "moduleBuilder.aspx?id=" + Uri.EscapeDataString(moduleId) + "&saved=1";
            string script = @"
        (function(){
            if(window.parent&&window.parent!==window)
                window.parent.postMessage({ action: 'closeOverlay', type: 'text' }, window.location.origin);
            else window.location.href='" + fallbackUrl + @"';
        })();";
            ScriptManager.RegisterStartupScript(this, GetType(), "close", script, true);
        }

        private void ShowAlert(string msg)
        {
            string safe = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "Alert", $"alert('{safe}');", true);
        }
    }
}




