using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class assessmentTemplateStep2 : System.Web.UI.Page
    {
        private readonly string connectionString =
            System.Configuration.ConfigurationManager
                  .ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string assessmentId = Request.QueryString["assessmentId"];
                string courseId = Request.QueryString["courseId"];

                if (string.IsNullOrEmpty(assessmentId))
                { Response.Redirect("assessmentTemplates.aspx"); return; }

                hdnAssessmentId.Value = assessmentId;
                hdnCourseId.Value = courseId ?? "";

                int easy = int.TryParse(Request.QueryString["easy"], out int ev) ? ev : -1;
                int medium = int.TryParse(Request.QueryString["medium"], out int mv) ? mv : -1;
                int hard = int.TryParse(Request.QueryString["hard"], out int hv) ? hv : -1;

                if (easy >= 0) hdnQuotaEasy.Value = easy.ToString();
                if (medium >= 0) hdnQuotaMedium.Value = medium.ToString();
                if (hard >= 0) hdnQuotaHard.Value = hard.ToString();

                LoadTemplateTitle(assessmentId);
                LoadQuestionPool(assessmentId);

                bool hasExisting = LoadSelectedQuestions(assessmentId);
                if (!hasExisting && easy >= 0)
                    AutoSelectByComposition(assessmentId, easy, medium, hard);
            }
        }


        private void LoadTemplateTitle(string assessmentId)
        {
            const string sql = @"SELECT ISNULL(title, '') FROM dbo.assessmentTable WHERE assessmentID = @aid";
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    conn.Open();
                    hdnTemplateTitle.Value = cmd.ExecuteScalar()?.ToString() ?? "";
                }
            }
            catch
            {
                hdnTemplateTitle.Value = "";
            }
        }
        // Helper: get the moduleID for an assessment
        private string GetModuleIdForAssessment(string assessmentId)
        {
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(
                    "SELECT ISNULL(moduleID,'') FROM dbo.assessmentTable WHERE assessmentID = @aid", conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    conn.Open();
                    return cmd.ExecuteScalar()?.ToString() ?? "";
                }
            }
            catch { return ""; }
        }

        protected string ResolveModuleBuilderUrl()
        {
            string courseId = (hdnCourseId.Value ?? Request.QueryString["courseId"] ?? "").Trim();
            string assessmentId = (hdnAssessmentId.Value ?? Request.QueryString["assessmentId"] ?? "").Trim();
            string moduleId = GetModuleIdForAssessment(assessmentId);

            if (!string.IsNullOrWhiteSpace(moduleId))
                return "moduleBuilder.aspx?id=" + System.Web.HttpUtility.UrlEncode(moduleId) + "&courseId=" + System.Web.HttpUtility.UrlEncode(courseId);

            return "fullModuleView.aspx?courseId=" + System.Web.HttpUtility.UrlEncode(courseId);
        }
// LEFT PANEL: question bank scoped to the same MODULE
        private void LoadQuestionPool(string assessmentId)
        {
            const string sql = @"
                SELECT  q.questionID   AS QuestionID,
                        q.questionText AS QuestionText,
                        q.questionType,
                        q.points       AS Points,
                        CASE WHEN q.points <= 5  THEN 'Easy'
                             WHEN q.points <= 10 THEN 'Medium'
                             ELSE 'Hard' END      AS Difficulty
                FROM    dbo.questionTable   q
                JOIN    dbo.assessmentTable a ON a.assessmentID = q.assessmentID
                WHERE   a.moduleID = (
                            SELECT moduleID
                            FROM   dbo.assessmentTable
                            WHERE  assessmentID = @aid
                        )
                  AND   q.assessmentID <> @aid
                ORDER BY
                    CASE WHEN q.points <= 5  THEN 0
                         WHEN q.points <= 10 THEN 1
                         ELSE 2 END,
                    q.questionID";

            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                    conn.Open();
                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);
                    rptQuestionPool.DataSource = dt;
                    rptQuestionPool.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Step2] LoadQuestionPool error: " + ex);
                ShowAlert("Error loading question pool: " + ex.Message);
            }
        }

        // RIGHT PANEL: questions already linked to this assessment
        private bool LoadSelectedQuestions(string assessmentId)
        {
            const string sql = @"
                SELECT q.questionID, q.questionText, q.questionType,
                       q.correctAnswer, q.points, q.questionNumber,
                       CASE WHEN q.points <= 5  THEN 'Easy'
                            WHEN q.points <= 10 THEN 'Medium'
                            ELSE 'Hard' END AS Difficulty
                FROM   dbo.questionTable q
                WHERE  q.assessmentID = @aid
                ORDER  BY q.questionNumber";
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    var dt = new DataTable();
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@aid", assessmentId);
                        new SqlDataAdapter(cmd).Fill(dt);
                    }
                    if (dt.Rows.Count == 0) return false;

                    var list = new List<object>();
                    foreach (DataRow row in dt.Rows)
                        list.Add(new
                        {
                            questionId = row["questionID"].ToString(),
                            questionText = row["questionText"].ToString(),
                            questionType = row["questionType"].ToString(),
                            correctAnswer = row["correctAnswer"].ToString(),
                            points = Convert.ToInt32(row["points"]),
                            difficulty = row["Difficulty"].ToString(),
                            options = GetOptions(row["questionID"].ToString(), conn)
                        });

                    hdnSelectedQuestionsJson.Value = new JavaScriptSerializer().Serialize(list);
                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Step2] LoadSelectedQuestions error: " + ex);
                ShowAlert("Error loading existing questions: " + ex.Message);
                return false;
            }
        }

        // AUTO-SELECT: randomly suggest questions by difficulty tier
        private void AutoSelectByComposition(string assessmentId, int easy, int medium, int hard)
        {
            const string sql = @"
                SELECT TOP (@n)
                       q.questionID, q.questionText, q.questionType,
                       q.correctAnswer, q.points,
                       CASE WHEN q.points <= 5  THEN 'Easy'
                            WHEN q.points <= 10 THEN 'Medium'
                            ELSE 'Hard' END AS Difficulty
                FROM   dbo.questionTable   q
                JOIN   dbo.assessmentTable a ON a.assessmentID = q.assessmentID
                WHERE  a.moduleID = (
                           SELECT moduleID
                           FROM   dbo.assessmentTable
                           WHERE  assessmentID = @aid
                       )
                  AND  q.assessmentID <> @aid
                  AND  (   (@diff = 'Easy'   AND q.points <= 5)
                        OR (@diff = 'Medium' AND q.points >  5 AND q.points <= 10)
                        OR (@diff = 'Hard'   AND q.points >  10)
                       )
                ORDER BY NEWID()";

            var selected = new List<object>();
            var tiers = new[]
            {
                new { diff = "Easy",   count = easy   },
                new { diff = "Medium", count = medium },
                new { diff = "Hard",   count = hard   }
            };

            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    foreach (var tier in tiers)
                    {
                        if (tier.count <= 0) continue;
                        using (var cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@n", tier.count);
                            cmd.Parameters.AddWithValue("@aid", assessmentId);
                            cmd.Parameters.AddWithValue("@diff", tier.diff);
                            using (var r = cmd.ExecuteReader())
                                while (r.Read())
                                    selected.Add(new
                                    {
                                        questionId = r["questionID"].ToString(),
                                        questionText = r["questionText"].ToString(),
                                        questionType = r["questionType"].ToString(),
                                        correctAnswer = r["correctAnswer"].ToString(),
                                        points = Convert.ToInt32(r["points"]),
                                        difficulty = r["Difficulty"].ToString(),
                                        options = GetOptions(r["questionID"].ToString(), conn)
                                    });
                        }
                    }
                }
                if (selected.Count > 0)
                    hdnSelectedQuestionsJson.Value = new JavaScriptSerializer().Serialize(selected);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Step2] AutoSelectByComposition error: " + ex);
                ShowAlert("Error auto-selecting questions: " + ex.Message);
            }
        }

        // Options reader
        private List<object> GetOptions(string questionId, SqlConnection conn)
        {
            var opts = new List<object>();
            using (var cmd = new SqlCommand(@"
                SELECT optionID, optionLabel, optionText, isCorrect
                FROM   dbo.questionOptionTable
                WHERE  questionID = @qid
                ORDER  BY optionLabel", conn))
            {
                cmd.Parameters.AddWithValue("@qid", questionId);
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        opts.Add(new
                        {
                            optionId = r["optionID"].ToString(),
                            optionLabel = r["optionLabel"].ToString(),
                            optionText = r["optionText"].ToString(),
                            isCorrect = Convert.ToBoolean(r["isCorrect"])
                        });
            }
            return opts;
        }

        protected void rptQuestionPool_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            string diff = row["Difficulty"].ToString();
            string questionId = row["QuestionID"].ToString();

            var lit = (Literal)e.Item.FindControl("litDiffBadge");
            string cls = diff == "Easy" ? "bg-math-green/10 text-math-green"
                       : diff == "Medium" ? "bg-math-blue/10 text-math-blue"
                                          : "bg-primary/10 text-primary";
            if (lit != null)
                lit.Text = $@"<span class=""{cls} px-2 py-0.5 text-[9px] font-black rounded-lg uppercase"">{diff}</span>";

            var litOpts = (Literal)e.Item.FindControl("litOptionsJson");
            if (litOpts != null)
            {
                try
                {
                    using (var conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        var opts = GetOptions(questionId, conn);
                        var json = new JavaScriptSerializer().Serialize(opts);
                        json = json.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\"", "&quot;");
                        litOpts.Text = json;
                    }
                }
                catch { litOpts.Text = "[]"; }
            }
        }

        // SAVE STEP 2
        protected void btnSaveQuestions_Click(object sender, EventArgs e)
        {
            string assessmentId = (hdnAssessmentId.Value ?? "").Trim();
            string courseId = (hdnCourseId.Value ?? "").Trim();
            string json = hdnQuestionsJson.Value ?? "";

            if (string.IsNullOrWhiteSpace(assessmentId))
            { ShowAlert("Assessment ID is missing."); return; }

            if (string.IsNullOrWhiteSpace(json))
            { ShowAlert("Please add at least one question."); return; }

            List<SelectedQuestionRef> selected;
            try { selected = new JavaScriptSerializer().Deserialize<List<SelectedQuestionRef>>(json); }
            catch { ShowAlert("Error reading selection data — please try again."); return; }

            if (selected == null || selected.Count == 0)
            { ShowAlert("Please add at least one question."); return; }

            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Guard: block editing if students have already answered
                    bool hasStudentAnswers = false;
                    using (var cmd = new SqlCommand(@"
                        SELECT TOP 1 1
                        FROM   dbo.studentAnswerTable sa
                        JOIN   dbo.questionTable q ON q.questionID = sa.questionID
                        WHERE  q.assessmentID = @aid", conn))
                    {
                        cmd.Parameters.AddWithValue("@aid", assessmentId);
                        hasStudentAnswers = cmd.ExecuteScalar() != null;
                    }

                    if (hasStudentAnswers)
                    {
                        ShowAlert("This assessment has already been attempted by students. " +
                                  "Questions cannot be changed to protect student records. " +
                                  "You can still update the title, time limit, and pass score in Step 3.");
                        return;
                    }

                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1) Build in-memory list of QuestionClone
                            var sourceQuestions = new List<QuestionClone>();

                            foreach (var sel in selected)
                            {
                                if (sel.IsAiGenerated)
                                {
                                    // AI-generated: build from payload directly
                                    var q = new QuestionClone
                                    {
                                        SourceQuestionId = null,
                                        QuestionText = sel.QuestionText ?? "",
                                        QuestionType = sel.QuestionType ?? "mcq",
                                        CorrectAnswer = sel.Answer ?? "",
                                        Points = sel.Points > 0 ? sel.Points : 5,
                                        Options = new List<QuestionOptionClone>()
                                    };

                                    if (sel.QuestionType == "true_false")
                                    {
                                        q.Options.Add(new QuestionOptionClone { OptionLabel = "A", OptionText = "True", IsCorrect = sel.Answer == "True" });
                                        q.Options.Add(new QuestionOptionClone { OptionLabel = "B", OptionText = "False", IsCorrect = sel.Answer == "False" });
                                    }
                                    else if (sel.AiOptions != null)
                                    {
                                        foreach (var label in new[] { "A", "B", "C", "D" })
                                        {
                                            if (!sel.AiOptions.ContainsKey(label)) continue;
                                            q.Options.Add(new QuestionOptionClone
                                            {
                                                OptionLabel = label,
                                                OptionText = sel.AiOptions[label] ?? "",
                                                IsCorrect = sel.Answer == label
                                            });
                                        }
                                    }

                                    sourceQuestions.Add(q);
                                }
                                else
                                {
                                    // Pool question: read from DB
                                    string sourceQid = (sel.QuestionId ?? "").Trim();
                                    if (string.IsNullOrEmpty(sourceQid)) continue;

                                    QuestionClone q = null;
                                    using (var cmd = new SqlCommand(@"
                                        SELECT questionID, questionText, questionType,
                                               correctAnswer, points
                                        FROM   dbo.questionTable
                                        WHERE  questionID = @qid", conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@qid", sourceQid);
                                        using (var r = cmd.ExecuteReader())
                                            if (r.Read())
                                                q = new QuestionClone
                                                {
                                                    SourceQuestionId = r["questionID"].ToString(),
                                                    QuestionText = r["questionText"].ToString(),
                                                    QuestionType = r["questionType"].ToString(),
                                                    CorrectAnswer = r["correctAnswer"] == DBNull.Value
                                                                           ? null
                                                                           : r["correctAnswer"].ToString(),
                                                    Points = Convert.ToInt32(r["points"]),
                                                    Options = new List<QuestionOptionClone>()
                                                };
                                    }

                                    if (q == null)
                                        throw new Exception("Source question not found: " + sourceQid);

                                    using (var cmd = new SqlCommand(@"
                                        SELECT optionLabel, optionText, isCorrect
                                        FROM   dbo.questionOptionTable
                                        WHERE  questionID = @qid
                                        ORDER  BY optionLabel", conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@qid", sourceQid);
                                        using (var r = cmd.ExecuteReader())
                                            while (r.Read())
                                                q.Options.Add(new QuestionOptionClone
                                                {
                                                    OptionLabel = r["optionLabel"].ToString(),
                                                    OptionText = r["optionText"].ToString(),
                                                    IsCorrect = Convert.ToBoolean(r["isCorrect"])
                                                });
                                    }

                                    sourceQuestions.Add(q);
                                }
                            }

                            // 2) Delete current assessment's option rows
                            using (var cmd = new SqlCommand(@"
                                DELETE qo
                                FROM   dbo.questionOptionTable qo
                                JOIN   dbo.questionTable q ON q.questionID = qo.questionID
                                WHERE  q.assessmentID = @aid", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@aid", assessmentId);
                                cmd.ExecuteNonQuery();
                            }

                            // 3) Delete current assessment's questions
                            using (var cmd = new SqlCommand(@"
                                DELETE FROM dbo.questionTable
                                WHERE assessmentID = @aid", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@aid", assessmentId);
                                cmd.ExecuteNonQuery();
                            }

                            // 4) Re-insert from in-memory copy
                            int totalMarks = 0;
                            for (int i = 0; i < sourceQuestions.Count; i++)
                            {
                                var src = sourceQuestions[i];
                                string newQid = GenerateNextId("Q", "questionTable", "questionID", conn, tx);

                                using (var cmd = new SqlCommand(@"
                                    INSERT INTO dbo.questionTable
                                        (questionID, assessmentID, questionNumber,
                                         questionText, questionType, correctAnswer, points)
                                    VALUES
                                        (@newQid, @aid, @qnum,
                                         @qtext, @qtype, @correct, @points)", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@newQid", newQid);
                                    cmd.Parameters.AddWithValue("@aid", assessmentId);
                                    cmd.Parameters.AddWithValue("@qnum", i + 1);
                                    cmd.Parameters.AddWithValue("@qtext", src.QuestionText);
                                    cmd.Parameters.AddWithValue("@qtype", src.QuestionType);
                                    cmd.Parameters.AddWithValue("@correct", (object)src.CorrectAnswer ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@points", src.Points);
                                    cmd.ExecuteNonQuery();
                                }

                                totalMarks += src.Points;

                                foreach (var opt in src.Options)
                                {
                                    string newOid = GenerateNextId("OP", "questionOptionTable", "optionID", conn, tx);
                                    using (var cmd = new SqlCommand(@"
                                        INSERT INTO dbo.questionOptionTable
                                            (optionID, questionID, optionLabel, optionText, isCorrect)
                                        VALUES
                                            (@oid, @qid, @label, @text, @correct)", conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@oid", newOid);
                                        cmd.Parameters.AddWithValue("@qid", newQid);
                                        cmd.Parameters.AddWithValue("@label", opt.OptionLabel);
                                        cmd.Parameters.AddWithValue("@text", opt.OptionText);
                                        cmd.Parameters.AddWithValue("@correct", opt.IsCorrect);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                            }

                            // 5) Update totalMarks
                            using (var cmd = new SqlCommand(@"
                                UPDATE dbo.assessmentTable
                                SET    totalMarks = @marks,
                                       updatedAt  = SYSUTCDATETIME()
                                WHERE  assessmentID = @aid", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@aid", assessmentId);
                                cmd.Parameters.AddWithValue("@marks", totalMarks);
                                cmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }

                Response.Redirect(
                    "assessmentTemplatesStep3.aspx" +
                    "?assessmentId=" + System.Web.HttpUtility.UrlEncode(assessmentId) +
                    "&courseId=" + System.Web.HttpUtility.UrlEncode(courseId));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Step2] btnSaveQuestions_Click error: " + ex);
                ShowAlert("Error saving question selection: " + ex.Message);
            }
        }

        // DTOs
        private sealed class QuestionClone
        {
            public string SourceQuestionId { get; set; }
            public string QuestionText { get; set; }
            public string QuestionType { get; set; }
            public string CorrectAnswer { get; set; }
            public int Points { get; set; }
            public List<QuestionOptionClone> Options { get; set; }
        }

        private class SelectedQuestionRef
        {
            public string QuestionId { get; set; }
            public bool IsAiGenerated { get; set; }
            public string QuestionText { get; set; }
            public string Answer { get; set; }
            public string Difficulty { get; set; }
            public int Points { get; set; }
            public string QuestionType { get; set; }
            // MCQ options from AI: { "A": "...", "B": "...", "C": "...", "D": "..." }
            public Dictionary<string, string> AiOptions { get; set; }
        }

        private sealed class QuestionOptionClone
        {
            public string OptionLabel { get; set; }
            public string OptionText { get; set; }
            public bool IsCorrect { get; set; }
        }

        // ID generator
        private string GenerateNextId(string prefix, string tableName, string idColumn,
                                      SqlConnection conn, SqlTransaction tx)
        {
            string sql = $@"
                SELECT ISNULL(MAX(CAST(
                    SUBSTRING({idColumn}, {prefix.Length + 1}, LEN({idColumn})) AS INT
                )), 0) + 1
                FROM dbo.[{tableName}]
                WHERE {idColumn} LIKE @prefixPattern";

            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@prefixPattern", prefix + "%");
                int next = Convert.ToInt32(cmd.ExecuteScalar());
                return prefix + next.ToString("D3");
            }
        }

        private void ShowAlert(string msg)
        {
            string safe = (msg ?? "")
                .Replace("\\", "\\\\")
                .Replace("'", "\\'")
                .Replace("\r", "")
                .Replace("\n", " ");
            ScriptManager.RegisterStartupScript(this, GetType(),
                "Alert_" + Guid.NewGuid().ToString("N"),
                $"alert('{safe}');", true);
        }
    }
}


