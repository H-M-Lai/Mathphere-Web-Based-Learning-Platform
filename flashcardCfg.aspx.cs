using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class flashCardCfg : System.Web.UI.Page
    {
        private string connectionString =
            System.Configuration.ConfigurationManager
                  .ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string blockId = Request.QueryString["blockId"];
                string moduleId = Request.QueryString["moduleId"];

                if (string.IsNullOrEmpty(blockId))
                {
                    ShowAlert("blockId is required."); return;
                }

                hdnBlockId.Value = blockId;
                hdnModuleId.Value = moduleId ?? "";
                LoadFlashcardSet(blockId, moduleId);
            }
        }

        private void LoadFlashcardSet(string blockId, string moduleId)
        {
            string setId = GetFlashcardSetIdForBlock(blockId);
            if (string.IsNullOrEmpty(setId) && !string.IsNullOrEmpty(moduleId))
                setId = GetFlashcardSetIdForModule(moduleId);

            if (!string.IsNullOrEmpty(setId))
            {
                hdnFlashcardSetId.Value = setId;
                LoadSetMetadata(setId);
                LoadCards(setId);
            }
            else
            {
                txtSetTitle.Text = "";
                chkShuffle.Checked = true;
                rptCards.DataSource = new DataTable();
                rptCards.DataBind();
            }
        }

        private string GetFlashcardSetIdForBlock(string blockId)
        {
            const string sql = @"
                SELECT flashcardSetID FROM dbo.blockContentTable
                WHERE  blockID = @blockId AND flashcardSetID IS NOT NULL";
            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@blockId", blockId);
                conn.Open();
                object val = cmd.ExecuteScalar();
                return (val != null && val != DBNull.Value) ? val.ToString() : null;
            }
        }

        private string GetFlashcardSetIdForModule(string moduleId)
        {
            const string sql = @"
                SELECT TOP 1 flashcardSetID FROM dbo.flashcardSetTable
                WHERE  moduleID = @moduleId ORDER BY createdAt DESC";
            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@moduleId", moduleId);
                conn.Open();
                object val = cmd.ExecuteScalar();
                return (val != null && val != DBNull.Value) ? val.ToString() : null;
            }
        }

        private void LoadSetMetadata(string setId)
        {
            const string sql = @"
                SELECT setTitle, shuffleEnabled FROM dbo.flashcardSetTable
                WHERE  flashcardSetID = @setId";
            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@setId", setId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                    if (r.Read())
                    {
                        txtSetTitle.Text = r["setTitle"].ToString();
                        chkShuffle.Checked = Convert.ToBoolean(r["shuffleEnabled"]);
                    }
            }
        }

        private void LoadCards(string setId)
        {
            const string sql = @"
                SELECT flashcardID,
                       ISNULL(questionText,'') AS questionText,
                       ISNULL(answerText,  '') AS answerText,
                       ISNULL(orderIndex,999999) AS orderIndex
                FROM   dbo.flashcardTable
                WHERE  flashcardSetID = @setId
                ORDER  BY ISNULL(orderIndex,999999), flashcardID";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@setId", setId);
                new SqlDataAdapter(cmd).Fill(dt);
            }
            rptCards.DataSource = dt;
            rptCards.DataBind();
        }

        protected void rptCards_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;
            DataRowView row = (DataRowView)e.Item.DataItem;
            Literal litCard = (Literal)e.Item.FindControl("litCard");
            string cardId = row["flashcardID"].ToString();
            string front = System.Web.HttpUtility.HtmlEncode(row["questionText"].ToString());
            string back = System.Web.HttpUtility.HtmlEncode(row["answerText"].ToString());
            litCard.Text = GenerateCardHtml(cardId, front, back);
        }

        private string GenerateCardHtml(string cardId, string front, string back)
        {
            return $@"
<div class=""flashcard-item group relative bg-white border-2 border-slate-100 rounded-3xl p-6 flex gap-5 items-start shadow-sm hover:shadow-md transition-shadow""
     data-card-id=""{cardId}"">
    <div class=""drag-handle cursor-grab active:cursor-grabbing text-slate-300 hover:text-math-blue transition-colors mt-2 shrink-0 select-none"">
        <span class=""material-symbols-outlined text-3xl"">drag_indicator</span>
    </div>
    <div class=""flex-1 grid grid-cols-1 md:grid-cols-2 gap-5"">
        <div class=""space-y-2"">
            <label class=""block text-[10px] font-black text-slate-800 uppercase tracking-widest"">Front (Question)</label>
            <textarea class=""card-front card-textarea w-full rounded-2xl p-4 min-h-[110px] resize-none border-2 border-slate-100 bg-[#f9fafb] font-medium text-sm text-slate-700 placeholder:text-slate-300 focus:border-math-blue focus:bg-white focus:ring-0 outline-none transition-all""
                placeholder=""Enter the math problem or question..."">{front}</textarea>
        </div>
        <div class=""space-y-2"">
            <label class=""block text-[10px] font-black text-slate-800 uppercase tracking-widest"">Back (Answer)</label>
            <textarea class=""card-back card-textarea w-full rounded-2xl p-4 min-h-[110px] resize-none border-2 border-slate-100 bg-[#f9fafb] font-medium text-sm text-slate-700 placeholder:text-slate-300 focus:border-math-blue focus:bg-white focus:ring-0 outline-none transition-all""
                placeholder=""Enter the solution or final answer..."">{back}</textarea>
        </div>
    </div>
    <button type=""button"" onclick=""deleteCard(this)""
        class=""delete-card-btn shrink-0 bg-red-50 text-red-400 hover:bg-red-500 hover:text-white p-3 rounded-2xl transition-all mt-2 border border-red-100"">
        <span class=""material-symbols-outlined text-xl"">delete</span>
    </button>
</div>";
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                string title = txtSetTitle.Text.Trim();
                bool shuffle = chkShuffle.Checked;
                string blockId = hdnBlockId.Value;
                string moduleId = hdnModuleId.Value;
                string setId = hdnFlashcardSetId.Value;
                string cardsJson = hdnCardsJson.Value;

                if (string.IsNullOrEmpty(title))
                {
                    ShowAlert("Please enter a set title."); return;
                }

                List<CardData> cards = ParseCardsJson(cardsJson);

                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. UPSERT flashcardSetTable
                            if (string.IsNullOrEmpty(setId))
                            {
                                setId = GenerateSetId(conn, tx);
                                using (var cmd = new SqlCommand(@"
                                    INSERT INTO dbo.flashcardSetTable
                                        (flashcardSetID, moduleID, setTitle, shuffleEnabled)
                                    VALUES (@setId, @moduleId, @title, @shuffle)",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@setId", setId);
                                    cmd.Parameters.AddWithValue("@moduleId", moduleId);
                                    cmd.Parameters.AddWithValue("@title", title);
                                    cmd.Parameters.AddWithValue("@shuffle", shuffle);
                                    cmd.ExecuteNonQuery();
                                }
                                hdnFlashcardSetId.Value = setId;

                                // Link to blockContentTable
                                LinkSetToBlock(blockId, setId, conn, tx);
                            }
                            else
                            {
                                using (var cmd = new SqlCommand(@"
                                    UPDATE dbo.flashcardSetTable
                                    SET    setTitle       = @title,
                                           shuffleEnabled = @shuffle,
                                           updatedAt      = GETDATE()
                                    WHERE  flashcardSetID = @setId",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@title", title);
                                    cmd.Parameters.AddWithValue("@shuffle", shuffle);
                                    cmd.Parameters.AddWithValue("@setId", setId);
                                    cmd.ExecuteNonQuery();
                                }
                                LinkSetToBlock(blockId, setId, conn, tx);
                            }

                            // 2. UPDATE moduleBlockTable.title
                            //    Syncs the block's display title with the set title
                            //    so moduleBuilder & fullModuleView show the right name
                            if (!string.IsNullOrEmpty(blockId))
                            {
                                using (var cmd = new SqlCommand(@"
                                    UPDATE dbo.moduleBlockTable
                                    SET    title = @title
                                    WHERE  blockID = @blockId",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@title", title);
                                    cmd.Parameters.AddWithValue("@blockId", blockId);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            // 3. Sync flashcardTable cards
                            // Get current DB card IDs for this set
                            var dbCardIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                            using (var cmd = new SqlCommand(
                                "SELECT flashcardID FROM dbo.flashcardTable WHERE flashcardSetID = @setId",
                                conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@setId", setId);
                                using (var r = cmd.ExecuteReader())
                                    while (r.Read()) dbCardIds.Add(r["flashcardID"].ToString());
                            }

                            var keptIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                            for (int i = 0; i < cards.Count; i++)
                            {
                                CardData card = cards[i];
                                int order = i + 1;

                                if (card.Id.StartsWith("new-", StringComparison.OrdinalIgnoreCase))
                                {
                                    string newCardId = GenerateCardId(conn, tx);
                                    using (var cmd = new SqlCommand(@"
                                        INSERT INTO dbo.flashcardTable
                                            (flashcardID, moduleID, flashcardSetID,
                                             questionText, answerText, orderIndex)
                                        VALUES
                                            (@id, @moduleId, @setId,
                                             @question, @answer, @order)",
                                        conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@id", newCardId);
                                        cmd.Parameters.AddWithValue("@moduleId", moduleId);
                                        cmd.Parameters.AddWithValue("@setId", setId);
                                        cmd.Parameters.AddWithValue("@question", card.Front);
                                        cmd.Parameters.AddWithValue("@answer", card.Back);
                                        cmd.Parameters.AddWithValue("@order", order);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                else
                                {
                                    keptIds.Add(card.Id);
                                    using (var cmd = new SqlCommand(@"
                                        UPDATE dbo.flashcardTable
                                        SET    questionText = @question,
                                               answerText   = @answer,
                                               orderIndex   = @order
                                        WHERE  flashcardID    = @id
                                          AND  flashcardSetID = @setId",
                                        conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@question", card.Front);
                                        cmd.Parameters.AddWithValue("@answer", card.Back);
                                        cmd.Parameters.AddWithValue("@order", order);
                                        cmd.Parameters.AddWithValue("@id", card.Id);
                                        cmd.Parameters.AddWithValue("@setId", setId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                            }

                            // Delete cards removed from the UI
                            foreach (string dbId in dbCardIds)
                            {
                                if (keptIds.Contains(dbId)) continue;
                                using (var cmd = new SqlCommand(
                                    "DELETE FROM dbo.flashcardTable WHERE flashcardID = @id",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@id", dbId);
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

                RedirectToModuleBuilder(blockId);
            }
            catch (Exception ex)
            {
                ShowAlert("Error saving: " + ex.Message);
            }
        }

        // -
        //  Link flashcardSetID into blockContentTable
        // -
        private void LinkSetToBlock(string blockId, string setId,
            SqlConnection conn, SqlTransaction tx)
        {
            int exists;
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.blockContentTable WHERE blockID = @blockId",
                conn, tx))
            {
                cmd.Parameters.AddWithValue("@blockId", blockId);
                exists = (int)cmd.ExecuteScalar();
            }

            if (exists > 0)
            {
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.blockContentTable
                    SET    flashcardSetID = @setId WHERE blockID = @blockId",
                    conn, tx))
                {
                    cmd.Parameters.AddWithValue("@setId", setId);
                    cmd.Parameters.AddWithValue("@blockId", blockId);
                    cmd.ExecuteNonQuery();
                }
            }
            else
            {
                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.blockContentTable (blockID, flashcardSetID)
                    VALUES (@blockId, @setId)",
                    conn, tx))
                {
                    cmd.Parameters.AddWithValue("@blockId", blockId);
                    cmd.Parameters.AddWithValue("@setId", setId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // -
        //  ID generators
        // -
        private string GenerateSetId(SqlConnection conn, SqlTransaction tx)
        {
            const string sql = @"
                SELECT ISNULL(MAX(CAST(SUBSTRING(flashcardSetID,3,LEN(flashcardSetID)-2) AS INT)),0)+1
                FROM   dbo.flashcardSetTable
                WHERE  LEN(flashcardSetID) > 2
                  AND  ISNUMERIC(SUBSTRING(flashcardSetID,3,LEN(flashcardSetID)-2)) = 1";
            using (var cmd = new SqlCommand(sql, conn, tx))
                return "FS" + ((int)cmd.ExecuteScalar()).ToString("D3");
        }

        private string GenerateCardId(SqlConnection conn, SqlTransaction tx)
        {
            const string sql = @"
                SELECT ISNULL(MAX(CAST(SUBSTRING(flashcardID,2,LEN(flashcardID)-1) AS INT)),0)+1
                FROM   dbo.flashcardTable
                WHERE  LEN(flashcardID) > 1
                  AND  ISNUMERIC(SUBSTRING(flashcardID,2,LEN(flashcardID)-1)) = 1";
            using (var cmd = new SqlCommand(sql, conn, tx))
                return "F" + ((int)cmd.ExecuteScalar()).ToString("D3");
        }

        // -
        //  JSON parser  —  expects [{id, front, back}, ...]
        // -
        private class CardData
        {
            public string Id { get; set; }
            public string Front { get; set; }
            public string Back { get; set; }
        }

        private List<CardData> ParseCardsJson(string json)
        {
            var list = new List<CardData>();
            if (string.IsNullOrWhiteSpace(json)) return list;
            try
            {
                var ser = new JavaScriptSerializer();
                var raw = ser.Deserialize<List<Dictionary<string, object>>>(json);
                if (raw == null) return list;
                foreach (var item in raw)
                    list.Add(new CardData
                    {
                        Id = item.ContainsKey("id") ? item["id"]?.ToString() ?? "" : "",
                        Front = item.ContainsKey("front") ? item["front"]?.ToString() ?? "" : "",
                        Back = item.ContainsKey("back") ? item["back"]?.ToString() ?? "" : ""
                    });
            }
            catch { }
            return list;
        }

        // -
        //  UI helpers
        // -
        private void RedirectToModuleBuilder(string blockId)
        {
            string moduleId = (Request.QueryString["moduleId"] ?? "").Trim();
            string fallbackUrl = "moduleBuilder.aspx?id=" + Uri.EscapeDataString(moduleId) + "&saved=1";
            string script = @"
        (function(){
            if(window.parent && window.parent !== window)
                window.parent.postMessage({ action: 'closeOverlay', type: 'flashcard' }, window.location.origin);
            else
                window.location.href = '" + fallbackUrl + @"';
        })();";
            ScriptManager.RegisterStartupScript(this, GetType(), "CloseOverlay", script, true);
        }

        private void ShowAlert(string message)
        {
            string safe = message.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "Alert",
                $"alert('{safe}');", true);
        }
    }
}





