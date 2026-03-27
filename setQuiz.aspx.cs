using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace MathSphere
{
    public partial class setQuiz : System.Web.UI.Page
    {
        private string cs =
            System.Configuration.ConfigurationManager
                  .ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string blockId = Request.QueryString["blockId"];
                string moduleId = Request.QueryString["moduleId"];
                if (string.IsNullOrEmpty(blockId)) { ShowAlert("blockId is required."); return; }
                hdnBlockId.Value = blockId;
                hdnModuleId.Value = moduleId ?? "";
                LoadQuizData(blockId);
            }
        }

        private void LoadQuizData(string blockId)
        {
            string quizId = null;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT quizID FROM dbo.blockContentTable WHERE blockID=@b AND quizID IS NOT NULL", conn))
            {
                cmd.Parameters.AddWithValue("@b", blockId);
                conn.Open();
                object val = cmd.ExecuteScalar();
                if (val != null && val != DBNull.Value) quizId = val.ToString();
            }

            if (string.IsNullOrEmpty(quizId)) { hdnQuizJson.Value = ""; return; }

            hdnQuizId.Value = quizId;

            // Quiz title
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT quizTitle FROM dbo.quizTable WHERE quizID=@q", conn))
            {
                cmd.Parameters.AddWithValue("@q", quizId);
                conn.Open();
                object val = cmd.ExecuteScalar();
                txtQuizTitle.Text = (val != null && val != DBNull.Value) ? val.ToString() : "";
            }

            // Questions
            DataTable qDt = new DataTable();
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT questionID, questionText, hint, points, orderIndex
                FROM   dbo.quizQuestionTable
                WHERE  quizID=@q ORDER BY orderIndex", conn))
            {
                cmd.Parameters.AddWithValue("@q", quizId);
                new SqlDataAdapter(cmd).Fill(qDt);
            }

            // All options for this quiz
            DataTable oDt = new DataTable();
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT optionID, questionID, optionLabel, optionText, isCorrect
                FROM   dbo.quizOptionTable
                WHERE  quizID=@q ORDER BY questionID, optionLabel", conn))
            {
                cmd.Parameters.AddWithValue("@q", quizId);
                new SqlDataAdapter(cmd).Fill(oDt);
            }

            var questionsList = new List<Dictionary<string, object>>();
            foreach (DataRow qRow in qDt.Rows)
            {
                string qid = qRow["questionID"].ToString();
                var optList = new List<Dictionary<string, object>>();
                foreach (DataRow oRow in oDt.Rows)
                {
                    if (oRow["questionID"].ToString() != qid) continue;
                    optList.Add(new Dictionary<string, object>
                    {
                        ["optionId"] = oRow["optionID"].ToString(),
                        ["label"] = oRow["optionLabel"].ToString(),
                        ["text"] = oRow["optionText"].ToString(),
                        ["isCorrect"] = Convert.ToBoolean(oRow["isCorrect"])
                    });
                }
                questionsList.Add(new Dictionary<string, object>
                {
                    ["questionId"] = qid,
                    ["questionText"] = qRow["questionText"].ToString(),
                    ["hint"] = qRow["hint"] != DBNull.Value ? qRow["hint"].ToString() : "",
                    ["points"] = Convert.ToInt32(qRow["points"]),
                    ["options"] = optList
                });
            }
            hdnQuizJson.Value = new JavaScriptSerializer().Serialize(questionsList);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                string blockId = hdnBlockId.Value;
                string moduleId = hdnModuleId.Value;
                string quizId = hdnQuizId.Value;
                string quizJson = hdnQuizJson.Value;
                string quizTitle = (txtQuizTitle.Text ?? "").Trim();

                if (string.IsNullOrWhiteSpace(quizJson)) { ShowAlert("No quiz data."); return; }

                var incoming = ParseQuizJson(quizJson);
                if (incoming.Count == 0) { ShowAlert("Please add at least one question."); return; }

                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Upsert quizTable
                            if (string.IsNullOrEmpty(quizId))
                            {
                                quizId = GenerateId(conn, tx, "quizTable", "quizID", "QZ", 2, 3);
                                hdnQuizId.Value = quizId;
                                using (var cmd = new SqlCommand(@"
                                    INSERT INTO dbo.quizTable
                                        (quizID,blockID,moduleID,quizTitle,createdAt,updatedAt)
                                    VALUES(@q,@b,@m,@t,GETDATE(),NULL);", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@q", quizId);
                                    cmd.Parameters.AddWithValue("@b", blockId);
                                    cmd.Parameters.AddWithValue("@m", moduleId);
                                    cmd.Parameters.AddWithValue("@t", quizTitle);
                                    cmd.ExecuteNonQuery();
                                }
                                UpsertBlockContent(blockId, quizId, conn, tx);
                            }
                            else
                            {
                                using (var cmd = new SqlCommand(@"
                                    UPDATE dbo.quizTable SET quizTitle=@t,updatedAt=GETDATE()
                                    WHERE quizID=@q;", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@t", quizTitle);
                                    cmd.Parameters.AddWithValue("@q", quizId);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            // 2. Sync block card title
                            string cardTitle = string.IsNullOrEmpty(quizTitle)
                                ? (incoming[0].QuestionText.Length > 60
                                    ? incoming[0].QuestionText.Substring(0, 60) + "…"
                                    : incoming[0].QuestionText)
                                : quizTitle;

                            using (var cmd = new SqlCommand(@"
                                UPDATE dbo.moduleBlockTable SET title=@t WHERE blockID=@b;",
                                conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@t", cardTitle);
                                cmd.Parameters.AddWithValue("@b", blockId);
                                cmd.ExecuteNonQuery();
                            }

                            // 3. Get existing question IDs
                            var dbQIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                            using (var cmd = new SqlCommand(
                                "SELECT questionID FROM dbo.quizQuestionTable WHERE quizID=@q;",
                                conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@q", quizId);
                                using (var r = cmd.ExecuteReader())
                                    while (r.Read()) dbQIds.Add(r["questionID"].ToString());
                            }

                            var keptQIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                            // 4. Upsert each question + options
                            for (int qi = 0; qi < incoming.Count; qi++)
                            {
                                var q = incoming[qi];
                                string qid = q.QuestionId;
                                bool isNew = string.IsNullOrEmpty(qid) || !dbQIds.Contains(qid);

                                if (isNew)
                                {
                                    qid = GenerateId(conn, tx,
                                        "quizQuestionTable", "questionID", "QQ", 2, 6);
                                    using (var cmd = new SqlCommand(@"
                                        INSERT INTO dbo.quizQuestionTable
                                            (questionID,quizID,questionText,hint,points,orderIndex,createdAt)
                                        VALUES(@id,@q,@qt,@h,@p,@o,GETDATE());", conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@id", qid);
                                        cmd.Parameters.AddWithValue("@q", quizId);
                                        cmd.Parameters.AddWithValue("@qt", q.QuestionText);
                                        cmd.Parameters.AddWithValue("@h",
                                            string.IsNullOrEmpty(q.Hint)
                                                ? (object)DBNull.Value : q.Hint);
                                        cmd.Parameters.AddWithValue("@p", q.Points);
                                        cmd.Parameters.AddWithValue("@o", qi + 1);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                else
                                {
                                    keptQIds.Add(qid);
                                    using (var cmd = new SqlCommand(@"
                                        UPDATE dbo.quizQuestionTable
                                        SET questionText=@qt,hint=@h,points=@p,orderIndex=@o
                                        WHERE questionID=@id;", conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@qt", q.QuestionText);
                                        cmd.Parameters.AddWithValue("@h",
                                            string.IsNullOrEmpty(q.Hint)
                                                ? (object)DBNull.Value : q.Hint);
                                        cmd.Parameters.AddWithValue("@p", q.Points);
                                        cmd.Parameters.AddWithValue("@o", qi + 1);
                                        cmd.Parameters.AddWithValue("@id", qid);
                                        cmd.ExecuteNonQuery();
                                    }
                                }

                                SyncOptions(qid, quizId, q.Options, conn, tx);
                            }

                            // 5. Delete removed questions
                            foreach (string dbQId in dbQIds)
                            {
                                if (keptQIds.Contains(dbQId)) continue;
                                using (var cmd = new SqlCommand(@"
                                    DELETE FROM dbo.quizOptionTable   WHERE questionID=@id;
                                    DELETE FROM dbo.quizQuestionTable WHERE questionID=@id;",
                                    conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@id", dbQId);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            tx.Commit();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }

                CloseOverlay();
            }
            catch (Exception ex) { ShowAlert("Error saving: " + ex.Message); }
        }

        private void SyncOptions(string questionId, string quizId,
            List<OptionData> incoming, SqlConnection conn, SqlTransaction tx)
        {
            var dbOIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            using (var cmd = new SqlCommand(
                "SELECT optionID FROM dbo.quizOptionTable WHERE questionID=@q;", conn, tx))
            {
                cmd.Parameters.AddWithValue("@q", questionId);
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) dbOIds.Add(r["optionID"].ToString());
            }

            string[] labels = { "A", "B", "C", "D", "E", "F" };
            var keptOIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            for (int oi = 0; oi < incoming.Count; oi++)
            {
                var opt = incoming[oi];
                string label = oi < labels.Length ? labels[oi] : ((char)(65 + oi)).ToString();
                bool isNew = string.IsNullOrEmpty(opt.OptionId)
                               || !dbOIds.Contains(opt.OptionId);

                if (isNew)
                {
                    string nid = GenerateId(conn, tx,
                        "quizOptionTable", "optionID", "QO", 2, 6);
                    using (var cmd = new SqlCommand(@"
                        INSERT INTO dbo.quizOptionTable
                            (optionID,questionID,quizID,optionLabel,optionText,isCorrect)
                        VALUES(@id,@q,@qz,@l,@t,@c);", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@id", nid);
                        cmd.Parameters.AddWithValue("@q", questionId);
                        cmd.Parameters.AddWithValue("@qz", quizId);
                        cmd.Parameters.AddWithValue("@l", label);
                        cmd.Parameters.AddWithValue("@t", opt.Text);
                        cmd.Parameters.AddWithValue("@c", opt.IsCorrect);
                        cmd.ExecuteNonQuery();
                    }
                    keptOIds.Add(nid);
                }
                else
                {
                    keptOIds.Add(opt.OptionId);
                    using (var cmd = new SqlCommand(@"
                        UPDATE dbo.quizOptionTable
                        SET optionLabel=@l,optionText=@t,isCorrect=@c
                        WHERE optionID=@id;", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@l", label);
                        cmd.Parameters.AddWithValue("@t", opt.Text);
                        cmd.Parameters.AddWithValue("@c", opt.IsCorrect);
                        cmd.Parameters.AddWithValue("@id", opt.OptionId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            foreach (string dbId in dbOIds)
            {
                if (keptOIds.Contains(dbId)) continue;
                using (var cmd = new SqlCommand(
                    "DELETE FROM dbo.quizOptionTable WHERE optionID=@id;", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@id", dbId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void UpsertBlockContent(string blockId, string quizId,
            SqlConnection conn, SqlTransaction tx)
        {
            using (var cmd = new SqlCommand(@"
                MERGE dbo.blockContentTable AS t
                USING (SELECT @b AS blockID) AS s ON t.blockID=s.blockID
                WHEN MATCHED THEN
                    UPDATE SET quizID=@q
                WHEN NOT MATCHED THEN
                    INSERT(blockID,videoUrl,fileUrl,textContent,quizID,flashcardSetID)
                    VALUES(@b,NULL,NULL,NULL,@q,NULL);", conn, tx))
            {
                cmd.Parameters.AddWithValue("@b", blockId);
                cmd.Parameters.AddWithValue("@q", quizId);
                cmd.ExecuteNonQuery();
            }
        }

        private string GenerateId(SqlConnection conn, SqlTransaction tx,
            string table, string column, string prefix, int prefixLen, int padLen)
        {
            string sql = $@"
                SELECT ISNULL(MAX(CAST(SUBSTRING({column},{prefixLen + 1},
                    LEN({column})-{prefixLen}) AS INT)),0)+1
                FROM dbo.{table}
                WHERE {column} LIKE '{prefix}'+REPLICATE('[0-9]',{padLen})
                  AND ISNUMERIC(SUBSTRING({column},{prefixLen + 1},LEN({column})-{prefixLen}))=1";
            using (var cmd = new SqlCommand(sql, conn, tx))
                return prefix + ((int)cmd.ExecuteScalar()).ToString("D" + padLen);
        }

        private class QuizQuestionData
        {
            public string QuestionId { get; set; }
            public string QuestionText { get; set; }
            public string Hint { get; set; }
            public int Points { get; set; }
            public List<OptionData> Options { get; set; }
        }
        private class OptionData
        {
            public string OptionId { get; set; }
            public string Text { get; set; }
            public bool IsCorrect { get; set; }
        }

        private List<QuizQuestionData> ParseQuizJson(string json)
        {
            var list = new List<QuizQuestionData>();
            if (string.IsNullOrWhiteSpace(json)) return list;
            try
            {
                var ser = new JavaScriptSerializer();
                var raw = ser.Deserialize<List<Dictionary<string, object>>>(json);
                if (raw == null) return list;
                foreach (var qItem in raw)
                {
                    var q = new QuizQuestionData
                    {
                        QuestionId = qItem.ContainsKey("questionId") ? qItem["questionId"]?.ToString() ?? "" : "",
                        QuestionText = qItem.ContainsKey("questionText") ? qItem["questionText"]?.ToString() ?? "" : "",
                        Hint = qItem.ContainsKey("hint") ? qItem["hint"]?.ToString() ?? "" : "",
                        Points = qItem.ContainsKey("points") ? Convert.ToInt32(qItem["points"]) : 5,
                        Options = new List<OptionData>()
                    };
                    if (qItem.ContainsKey("options") &&
                        qItem["options"] is System.Collections.ArrayList opts)
                    {
                        foreach (Dictionary<string, object> oItem in opts)
                            q.Options.Add(new OptionData
                            {
                                OptionId = oItem.ContainsKey("optionId") ? oItem["optionId"]?.ToString() ?? "" : "",
                                Text = oItem.ContainsKey("text") ? oItem["text"]?.ToString() ?? "" : "",
                                IsCorrect = oItem.ContainsKey("isCorrect") && Convert.ToBoolean(oItem["isCorrect"])
                            });
                    }
                    list.Add(q);
                }
            }
            catch { }
            return list;
        }

        private void CloseOverlay()
        {
            string moduleId = (Request.QueryString["moduleId"] ?? "").Trim();
            string fallbackUrl = "moduleBuilder.aspx?id=" + Uri.EscapeDataString(moduleId) + "&saved=1";
            string script = @"
        (function(){
            if(window.parent&&window.parent!==window)
                window.parent.postMessage({ action: 'closeOverlay', type: 'quiz' }, window.location.origin);
            else window.location.href='" + fallbackUrl + @"';
        })();";
            ScriptManager.RegisterStartupScript(this, GetType(), "close", script, true);
        }
        private void ShowAlert(string msg)
        {
            string safe = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "Alert",
                $"alert('{safe}');", true);
        }
    }
}




