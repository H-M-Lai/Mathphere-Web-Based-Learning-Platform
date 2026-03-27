using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class moduleBuilder : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private string moduleId;

        // -
        //  Page Load
        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                moduleId = (Request.QueryString["id"] ?? Request.QueryString["moduleId"] ?? "").Trim();

                if (!string.IsNullOrWhiteSpace(moduleId))
                {
                    hdnModuleId.Value = moduleId;
                    LoadModuleData(moduleId);
                    LoadModuleBlocks(moduleId);
                }
                else
                {
                    litModuleTitle.Text = "New Module";
                    txtModuleTitle.Text = "New Module";
                    txtDescription.Text = "";

                    rptModuleBlocks.DataSource = new DataTable();
                    rptModuleBlocks.DataBind();
                }

                LoadContentLibrary();
            }
        }

        // -
        //  Load module title + settings
        // -
        private void LoadModuleData(string id)
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT moduleTitle, moduleDescription FROM dbo.moduleTable WHERE moduleID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { Response.Redirect("courselistDashboard.aspx"); return; }

                    litModuleTitle.Text = r["moduleTitle"].ToString();
                    txtModuleTitle.Text = r["moduleTitle"].ToString();
                    txtDescription.Text = r["moduleDescription"] != DBNull.Value
                        ? r["moduleDescription"].ToString()
                        : "";
                }
            }
        }

        // -
        //  Load blocks from DB ? populate repeater
        //  Also serialises block list to hdnBlocksJson so the hidden
        //  field is ALWAYS in sync with DB after any postback.
        // -
        private void LoadModuleBlocks(string id)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("BlockID", typeof(string));
            dt.Columns.Add("ContentType", typeof(string));
            dt.Columns.Add("Title", typeof(string));
            dt.Columns.Add("Metadata", typeof(string));
            dt.Columns.Add("Icon", typeof(string));
            dt.Columns.Add("ColorClass", typeof(string));
            dt.Columns.Add("OrderIndex", typeof(int));

            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT
                    b.blockID,
                    b.blockType,
                    ISNULL(NULLIF(LTRIM(RTRIM(b.title)),''), b.blockType) AS title,
                    b.orderIndex,
                    c.videoUrl,
                    c.fileUrl,
                    c.textContent,
                    c.quizID,
                    c.flashcardSetID
                FROM  dbo.moduleBlockTable   b
                LEFT  JOIN dbo.blockContentTable c ON c.blockID = b.blockID
                WHERE b.moduleID = @id
                ORDER BY b.orderIndex ASC", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        string blockType = r["blockType"].ToString();
                        MapBlockType(blockType, out string displayType, out string icon, out string colorClass);
                        string metadata = BuildMetadata(blockType,
                            r["videoUrl"], r["fileUrl"], r["textContent"],
                            r["quizID"], r["flashcardSetID"]);

                        dt.Rows.Add(
                            r["blockID"].ToString(), displayType,
                            r["title"].ToString(), metadata,
                            icon, colorClass,
                            Convert.ToInt32(r["orderIndex"]));
                    }
                }
            }

            rptModuleBlocks.DataSource = dt;
            rptModuleBlocks.DataBind();

            // This means even after a postback the hidden field reflects
            // what is actually in DB, so Save Changes never gets an empty list.
            SyncHiddenFieldFromDataTable(dt);
        }

        // -
        //  Serialise the DataTable rows into hdnBlocksJson
        //  so the JS hidden field always matches the DB state.
        // -
        private void SyncHiddenFieldFromDataTable(DataTable dt)
        {
            var list = new List<Dictionary<string, object>>();
            int order = 1;
            foreach (DataRow row in dt.Rows)
            {
                list.Add(new Dictionary<string, object>
                {
                    ["id"] = row["BlockID"].ToString(),
                    ["contentType"] = row["ContentType"].ToString(),
                    ["icon"] = row["Icon"].ToString(),
                    ["colorClass"] = row["ColorClass"].ToString(),
                    ["title"] = row["Title"].ToString(),
                    ["order"] = order++
                });
            }
            var ser = new JavaScriptSerializer();
            hdnBlocksJson.Value = ser.Serialize(list);
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            string id = hdnModuleId.Value;
            string json = (hdnBlocksJson.Value ?? "").Trim();

            if (string.IsNullOrWhiteSpace(id))
            {
                ShowAlert("No module selected.");
                return;
            }

            try
            {
                List<BlockState> uiBlocks = ParseBlocksJson(json);

                if (uiBlocks.Count == 0)
                {
                    LoadModuleBlocks(id);
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast_safe",
                        "showToast('No changes detected. Blocks reloaded from database.');", true);
                    return;
                }

                var idMappings = new Dictionary<string, string>();

                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // Current DB block ids for this module
                            var dbIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                            using (var cmd = new SqlCommand(
                                "SELECT blockID FROM dbo.moduleBlockTable WHERE moduleID = @mid",
                                conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@mid", id);
                                using (var r = cmd.ExecuteReader())
                                {
                                    while (r.Read())
                                        dbIds.Add(r["blockID"].ToString());
                                }
                            }

                            var keptIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                            var existingBlocksToReorder = new List<BlockState>();

                            // 1) Insert new blocks first using safe temporary order values
                            int tempInsertOrder = 10000;

                            for (int i = 0; i < uiBlocks.Count; i++)
                            {
                                BlockState blk = uiBlocks[i];
                                string rawType = MapDisplayToRawType(blk.ContentType);

                                if (blk.Id.StartsWith("new-", StringComparison.OrdinalIgnoreCase))
                                {
                                    string newId = GenerateBlockId(conn, tx);

                                    using (var cmd = new SqlCommand(@"
                                INSERT INTO dbo.moduleBlockTable
                                    (blockID, moduleID, blockType, title, orderIndex, isRequired)
                                VALUES
                                    (@blockID, @moduleID, @blockType, @title, @orderIndex, 1)",
                                        conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@blockID", newId);
                                        cmd.Parameters.AddWithValue("@moduleID", id);
                                        cmd.Parameters.AddWithValue("@blockType", rawType);
                                        cmd.Parameters.AddWithValue("@title",
                                            string.IsNullOrWhiteSpace(blk.Title) ? rawType : blk.Title);
                                        cmd.Parameters.AddWithValue("@orderIndex", tempInsertOrder++);
                                        cmd.ExecuteNonQuery();
                                    }

                                    using (var cmd = new SqlCommand(@"
                                INSERT INTO dbo.blockContentTable
                                    (blockID, videoUrl, fileUrl, textContent, quizID, flashcardSetID)
                                VALUES
                                    (@blockID, NULL, NULL, NULL, NULL, NULL)",
                                        conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@blockID", newId);
                                        cmd.ExecuteNonQuery();
                                    }

                                    idMappings[blk.Id] = newId;
                                    keptIds.Add(newId);

                                    existingBlocksToReorder.Add(new BlockState
                                    {
                                        Id = newId,
                                        ContentType = blk.ContentType,
                                        Title = blk.Title,
                                        Order = blk.Order
                                    });
                                }
                                else
                                {
                                    keptIds.Add(blk.Id);
                                    existingBlocksToReorder.Add(blk);
                                }
                            }

                            // 2) Delete removed blocks first
                            foreach (string dbId in dbIds)
                            {
                                if (keptIds.Contains(dbId)) continue;

                                using (var cmd = new SqlCommand(@"
                            DELETE FROM dbo.moduleBlockTable
                            WHERE blockID = @blockID
                              AND moduleID = @moduleID",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@blockID", dbId);
                                    cmd.Parameters.AddWithValue("@moduleID", id);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            // 3) Move all kept blocks to temporary unique order values first
                            for (int i = 0; i < existingBlocksToReorder.Count; i++)
                            {
                                var blk = existingBlocksToReorder[i];
                                int safeOrder = 1000 + i + 1;

                                using (var cmd = new SqlCommand(@"
                            UPDATE dbo.moduleBlockTable
                            SET orderIndex = @order
                            WHERE blockID = @blockID
                              AND moduleID = @moduleID",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@order", safeOrder);
                                    cmd.Parameters.AddWithValue("@blockID", blk.Id);
                                    cmd.Parameters.AddWithValue("@moduleID", id);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            // 4) Assign final order 1..N
                            for (int i = 0; i < existingBlocksToReorder.Count; i++)
                            {
                                var blk = existingBlocksToReorder[i];
                                int finalOrder = i + 1;

                                using (var cmd = new SqlCommand(@"
                            UPDATE dbo.moduleBlockTable
                            SET orderIndex = @order
                            WHERE blockID = @blockID
                              AND moduleID = @moduleID",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@order", finalOrder);
                                    cmd.Parameters.AddWithValue("@blockID", blk.Id);
                                    cmd.Parameters.AddWithValue("@moduleID", id);
                                    cmd.ExecuteNonQuery();
                                }
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

                LoadModuleBlocks(id);

                if (idMappings.Count > 0)
                {
                    var ser = new JavaScriptSerializer();
                    string mapJson = ser.Serialize(idMappings);
                    ScriptManager.RegisterStartupScript(this, GetType(), "id_mappings",
                        $"if(window.applyBlockIdMappings) applyBlockIdMappings({mapJson});", true);
                }

                // Save Changes — success toast (already exists, just update text)
                ScriptManager.RegisterStartupScript(this, GetType(), "toast_save",
                    "showToast('Block order saved successfully!');", true);

                // Save Changes — no changes detected
                ScriptManager.RegisterStartupScript(this, GetType(), "toast_safe",
                    "showToast('No changes detected. Blocks reloaded from database.');", true);

                // Save Configuration — success toast (already exists, just update text)
                ScriptManager.RegisterStartupScript(this, GetType(), "toast_cfg",
                    "showToast('Module configuration saved successfully!');", true);

            }
            catch (Exception ex)
            {
                ShowAlert("Error saving: " + ex.Message);
            }
        }

        protected void btnSaveConfiguration_Click(object sender, EventArgs e)
        {
            string id = hdnModuleId.Value;
            string title = (txtModuleTitle.Text ?? "").Trim();
            string description = (txtDescription.Text ?? "").Trim();

            if (string.IsNullOrWhiteSpace(id)) { ShowAlert("No module selected."); return; }
            if (string.IsNullOrWhiteSpace(title)) { ShowAlert("Please enter a module title."); return; }

            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
            UPDATE dbo.moduleTable
            SET moduleTitle = @title,
                moduleDescription = @description
            WHERE moduleID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@description",
                        string.IsNullOrWhiteSpace(description) ? (object)DBNull.Value : description);
                    cmd.Parameters.AddWithValue("@id", id);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                litModuleTitle.Text = HttpUtility.HtmlEncode(title);
                LoadModuleBlocks(id);

                ScriptManager.RegisterStartupScript(this, GetType(), "toast_cfg",
                    "showToast('Configuration saved successfully!');", true);
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message);
            }
        }

        //  Helpers
        private class BlockState
        {
            public string Id { get; set; }
            public string ContentType { get; set; }
            public string Title { get; set; }
            public int Order { get; set; }
        }

        private List<BlockState> ParseBlocksJson(string json)
        {
            var list = new List<BlockState>();
            if (string.IsNullOrWhiteSpace(json)) return list;

            try
            {
                var ser = new JavaScriptSerializer();
                var raw = ser.Deserialize<List<Dictionary<string, object>>>(json);
                if (raw == null) return list;

                foreach (var item in raw)
                {
                    list.Add(new BlockState
                    {
                        Id = item.ContainsKey("id") ? item["id"]?.ToString() ?? "" : "",
                        ContentType = item.ContainsKey("contentType") ? item["contentType"]?.ToString() ?? "" : "",
                        Title = item.ContainsKey("title") ? item["title"]?.ToString() ?? "" : "",
                        Order = item.ContainsKey("order") ? Convert.ToInt32(item["order"]) : 0
                    });
                }
            }
            catch { /* malformed JSON — return empty, guard above prevents deletion */ }

            return list;
        }

        private static string MapDisplayToRawType(string displayType)
        {
            switch ((displayType ?? "").Trim().ToLower())
            {
                case "video lesson": return "Video";
                case "text content": return "Text";
                case "interactive quiz":
                case "quiz": return "Quiz";
                case "flashcard set": return "Flashcard";
                case "file resource": return "File";
                default: return displayType ?? "Text";
            }
        }

        private string GenerateBlockId(SqlConnection conn, SqlTransaction tx)
        {
            using (var cmd = new SqlCommand(@"
                SELECT ISNULL(MAX(CAST(SUBSTRING(blockID,2,LEN(blockID)-1) AS INT)),0)+1
                FROM   dbo.moduleBlockTable
                WHERE  ISNUMERIC(SUBSTRING(blockID,2,LEN(blockID)-1))=1
                  AND  LEN(blockID)>1", conn, tx))
            {
                int next = (int)cmd.ExecuteScalar();
                return "B" + next.ToString("D6");
            }
        }

        private void ShowAlert(string msg, bool isError = true)
        {
            string escaped = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = isError
                ? $"alert('? {escaped}');"
                : $"alert('? {escaped}');";
            ScriptManager.RegisterStartupScript(this, GetType(),
                "alert_" + Guid.NewGuid().ToString("N"), script, true);
        }

        // -
        //  Content Library (static block type palette)
        // -
        private void LoadContentLibrary()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ContentType"); dt.Columns.Add("DisplayName");
            dt.Columns.Add("Subtitle"); dt.Columns.Add("Icon");
            dt.Columns.Add("ColorClass");

            dt.Rows.Add("Video", "Video Lesson", "YouTube Link", "play_circle", "math-blue");
            dt.Rows.Add("Flashcard", "Flashcard Set", "Interactive Drill", "style", "primary");
            dt.Rows.Add("Quiz", "Interactive Quiz", "Auto-graded", "quiz", "math-green");
            dt.Rows.Add("Text", "Text Content", "Rich Text / PDF", "article", "gray-500");

            rptContentLibrary.DataSource = dt;
            rptContentLibrary.DataBind();
        }

        // -
        //  Repeater ItemDataBound handlers
        // -
        protected void rptContentLibrary_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            ((Literal)e.Item.FindControl("litContentBlock")).Text =
                GenerateContentLibraryBlock(
                    row["ContentType"].ToString(), row["DisplayName"].ToString(),
                    row["Subtitle"].ToString(), row["Icon"].ToString(),
                    row["ColorClass"].ToString());
        }

        protected void rptModuleBlocks_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            ((Literal)e.Item.FindControl("litModuleBlock")).Text =
                GenerateModuleBlock(
                    row["BlockID"].ToString(), row["ContentType"].ToString(),
                    row["Title"].ToString(), row["Metadata"].ToString(),
                    row["Icon"].ToString(), row["ColorClass"].ToString());
        }

        // -
        //  Block type mapping helpers
        // -
        private static void MapBlockType(string blockType,
            out string displayType, out string icon, out string colorClass)
        {
            switch ((blockType ?? "").Trim().ToLower())
            {
                case "video":
                    displayType = "Video Lesson"; icon = "play_circle"; colorClass = "math-blue"; break;
                case "text":
                    displayType = "Text Content"; icon = "article"; colorClass = "gray-500"; break;
                case "quiz":
                    displayType = "Interactive Quiz"; icon = "quiz"; colorClass = "math-green"; break;
                case "flashcard":
                    displayType = "Flashcard Set"; icon = "style"; colorClass = "primary"; break;
                case "file":
                    displayType = "File Resource"; icon = "attach_file"; colorClass = "primary"; break;
                default:
                    displayType = blockType; icon = "widgets"; colorClass = "gray-500"; break;
            }
        }

        private static string BuildMetadata(string blockType,
            object videoUrl, object fileUrl, object textContent,
            object quizId, object flashcardSetId)
        {
            string t = (blockType ?? "").Trim().ToLower();

            if (t == "video")
            {
                if (videoUrl != DBNull.Value && !string.IsNullOrWhiteSpace(videoUrl.ToString()))
                    return "YouTube linked ✅";
                return "No video yet — click ⚙️ to add";
            }
            if (t == "text")
            {
                if (textContent != DBNull.Value && !string.IsNullOrWhiteSpace(textContent.ToString()))
                    return "Text added ✅";
                if (fileUrl != DBNull.Value && !string.IsNullOrWhiteSpace(fileUrl.ToString()))
                    return "PDF/file attached ✅";
                return "No content yet — click ⚙️ to add";
            }
            if (t == "quiz")
                return quizId != DBNull.Value && !string.IsNullOrWhiteSpace(quizId.ToString())
                    ? "Quiz linked ✅" : "No quiz yet — click ⚙️ to add";
            if (t == "flashcard")
                return flashcardSetId != DBNull.Value && !string.IsNullOrWhiteSpace(flashcardSetId.ToString())
                    ? "Flashcards linked ✅" : "No set yet — click ⚙️ to add";
            if (t == "file")
                return fileUrl != DBNull.Value && !string.IsNullOrWhiteSpace(fileUrl.ToString())
                    ? "File attached ✅" : "No file yet";

            return "";
        }

        // -
        //  HTML generators
        // -
        private string GenerateContentLibraryBlock(string contentType, string displayName,
            string subtitle, string icon, string colorClass)
        {
            return $@"
<div class=""library-item group cursor-grab active:cursor-grabbing bg-white border-2 border-gray-100
            p-4 rounded-2xl shadow-sm hover:border-math-green hover:shadow-md transition-all
            flex items-center gap-4 select-none""
     data-content-type=""{contentType}""
     data-display-name=""{displayName}""
     data-subtitle=""{subtitle}""
     data-icon=""{icon}""
     data-color-class=""{colorClass}"">
    <div class=""size-12 rounded-xl"" style=""background:rgba(0,0,0,0.04)"">
        <span class=""material-symbols-outlined fill-icon"">{icon}</span>
    </div>
    <div class=""flex-1"">
        <div class=""font-bold text-math-dark-blue"">{displayName}</div>
        <div class=""text-[10px] text-gray-400 font-bold uppercase"">{subtitle}</div>
    </div>
    <span class=""material-symbols-outlined text-gray-300 text-lg group-hover:text-math-green transition-colors"">drag_indicator</span>
</div>";
        }

        private string GenerateModuleBlock(string blockId, string contentType, string title,
            string metadata, string icon, string colorClass)
        {
            string bgColor, textColor, badgeColor;
            switch (colorClass)
            {
                case "math-blue": bgColor = "#eff6ff"; textColor = "#2563eb"; badgeColor = "#dbeafe"; break;
                case "primary": bgColor = "#fffbeb"; textColor = "#b45309"; badgeColor = "#fef3c7"; break;
                case "math-green": bgColor = "#f0fdf4"; textColor = "#65a30d"; badgeColor = "#dcfce7"; break;
                default: bgColor = "#f9fafb"; textColor = "#6b7280"; badgeColor = "#f3f4f6"; break;
            }

            // Show a "configured" green dot or "needs setup" amber dot on the badge
            bool configured = metadata.Contains("?");
            string dotColor = configured ? "#22c55e" : "#f59e0b";
            string dotTitle = configured ? "Content configured" : "Needs configuration — click ?";

            return $@"
<div class=""module-block-item bg-white rounded-3xl border-2 border-math-green/30
            p-1 shadow-sm hover:shadow-md transition-all relative""
     data-block-id=""{blockId}""
     data-content-type=""{contentType}""
     data-icon=""{icon}""
     data-color-class=""{colorClass}"">
    <div class=""bg-white border-l-8 border-math-green rounded-[1.25rem] p-6 flex items-center gap-6"">
        <div class=""drag-handle text-gray-300 hover:text-math-dark-blue transition-colors
                     cursor-grab active:cursor-grabbing select-none"" title=""Drag to reorder"">
            <span class=""material-symbols-outlined text-3xl"">drag_indicator</span>
        </div>
        <div class=""size-14 rounded-2xl flex items-center justify-center"" style=""background:{bgColor}"">
            <span class=""material-symbols-outlined text-3xl fill-icon"" style=""color:{textColor}"">{icon}</span>
        </div>
        <div class=""flex-1 min-w-0"">
            <div class=""flex items-center gap-2 mb-1"">
                <span class=""text-[10px] font-black px-2 py-0.5 rounded-full uppercase""
                      style=""background:{badgeColor};color:{textColor}"">{contentType}</span>
                <span class=""inline-block w-2 h-2 rounded-full flex-shrink-0""
                      style=""background:{dotColor}"" title=""{dotTitle}""></span>
                <span class=""text-[10px] font-bold text-gray-400 truncate"">{metadata}</span>
            </div>
            <h4 class=""font-black text-xl text-math-dark-blue truncate"">{title}</h4>
        </div>
        <div class=""flex gap-2 flex-shrink-0"">
            <button type=""button""
                class=""settings-btn size-10 rounded-xl hover:bg-blue-50 flex items-center
                        justify-center text-gray-400 hover:text-math-blue transition-colors""
                data-block-id=""{blockId}""
                data-content-type=""{contentType}""
                title=""Configure block content"">
                <span class=""material-symbols-outlined"">settings</span>
            </button>
            <button type=""button""
                class=""delete-btn size-10 rounded-xl hover:bg-red-50 flex items-center
                        justify-center text-gray-400 hover:text-red-500 transition-colors""
                title=""Remove block"">
                <span class=""material-symbols-outlined"">delete</span>
            </button>
        </div>
    </div>
</div>";
        }
    }
}


