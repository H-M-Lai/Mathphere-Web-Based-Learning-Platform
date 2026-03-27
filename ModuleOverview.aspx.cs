using DocumentFormat.OpenXml.Office.Word;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI.WebControls;

namespace Assignment
{
    public partial class ModuleOverview : System.Web.UI.Page
    {
        private string CS => ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected string ModuleId => (Request.QueryString["moduleId"] ?? "").Trim();

        protected bool IsGuest =>
        (Request.QueryString["guest"] == "1") ||
        (Session["IsGuest"] is bool b && b &&
         string.IsNullOrWhiteSpace((Session["UserID"] as string)));

        protected int ProgressPercent { get; set; } = 0;

        protected string ProgressOffset
        {
            get
            {
                const double circumference = 213.63;
                double offset = circumference * (1 - (ProgressPercent / 100.0));
                return offset.ToString("0.##", CultureInfo.InvariantCulture);
            }
        }

        // Safe dual-key session helper
        // Session may be keyed "UserID" or "userID" depending on login path.
        // All code in this file must use CurrentUserId — never Session["userID"] directly.
        private string CurrentUserId =>
            ((Session["UserID"] ?? Session["userID"]) as string)?.Trim() ?? "";

        private class TopicRow
        {
            public string BlockId { get; set; }
            public string Title { get; set; }
            public string BlockType { get; set; }
            public int OrderIndex { get; set; }
            public bool IsRequired { get; set; }
            public bool IsCompleted { get; set; }
        }

        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ModuleId))
            {
                Response.Redirect("~/BrowseModule.aspx");
                return;
            }

            if (!IsGuest)
            {
                if (string.IsNullOrWhiteSpace(CurrentUserId))
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }
            }

            if (!IsPostBack)
            {
                LoadModuleHeader(ModuleId);

                string userId = IsGuest ? null : CurrentUserId;
                var topics = GetTopicsForModule(userId, ModuleId);
                bool sequentialProgress = IsSequentialProgressEnabled(ModuleId);
                var lockedMap = BuildSequentialLockMap(topics, sequentialProgress);

                BindSidebarModules(topics, lockedMap);
                BindMainTopics(topics, lockedMap);
                BindAssessment();

                ProgressPercent = IsGuest ? 0 : GetModuleProgressPercent(CurrentUserId, ModuleId);
                litModuleProgress.Text = ProgressPercent.ToString();

                string firstBlockId = topics.Count > 0 ? topics[0].BlockId : "";
                if (IsGuest)
                {
                    lnkStartModule.NavigateUrl = "~/Login.aspx";
                }
                else
                {
                    lnkStartModule.NavigateUrl = string.IsNullOrEmpty(firstBlockId)
                        ? $"~/moduleContent.aspx?moduleId={Server.UrlEncode(ModuleId)}"
                        : $"~/moduleContent.aspx?moduleId={Server.UrlEncode(ModuleId)}&blockId={Server.UrlEncode(firstBlockId)}#block-{Server.UrlEncode(firstBlockId)}";
                }

                Page.DataBind();
                ApplyProgressRingOffset();
            }
        }

        // Module header
        private void LoadModuleHeader(string moduleId)
        {
            const string sql = @"
                SELECT
                    m.moduleTitle,
                    m.moduleID,
                    ISNULL(m.moduleDescription, '') AS moduleDescription,
                    c.courseName,
                    (SELECT COUNT(*)
                     FROM   dbo.moduleTable
                     WHERE  courseID = m.courseID
                       AND  moduleID <= m.moduleID) AS ModuleNumber
                FROM   dbo.moduleTable  m
                INNER JOIN dbo.courseTable c ON c.courseID = m.courseID
                WHERE  m.moduleID = @mid;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@mid", moduleId);
                con.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) { Response.Redirect("~/BrowseModule.aspx"); return; }

                    litCurrentMission.Text = dr["moduleTitle"].ToString();
                    litHeroTitle.Text = dr["moduleTitle"].ToString();
                    litCategory.Text = dr["courseName"].ToString();
                    litModuleNumber.Text = dr["ModuleNumber"].ToString();

                    string desc = dr["moduleDescription"].ToString();
                    litOverviewDesc.Text = string.IsNullOrWhiteSpace(desc)
                        ? "Complete all topics to master the basics and unlock the final assessment."
                        : desc;
                }
            }
        }

        // Load blocks
        private List<TopicRow> GetTopicsForModule(string userId, string moduleId)
        {
            const string sqlWithUser = @"
                SELECT
                    b.blockID    AS BlockId,
                    ISNULL(b.title, '') AS Title,
                    b.blockType  AS BlockType,
                    b.orderIndex AS OrderIndex,
                    b.isRequired AS IsRequired,
                    CASE WHEN ISNULL(p.isCompleted, 0) = 1 THEN 1 ELSE 0 END AS IsCompleted
                FROM   dbo.moduleBlockTable b
                LEFT   JOIN dbo.studentBlockProgressTable p
                       ON  p.blockID = b.blockID AND p.userID = @uid
                WHERE  b.moduleID = @mid
                  AND  (b.blockType IN ('Video','Text','Quiz') OR b.blockType LIKE 'Flashcard%')
                ORDER  BY b.orderIndex;";

            const string sqlGuest = @"
                SELECT
                    b.blockID    AS BlockId,
                    ISNULL(b.title, '') AS Title,
                    b.blockType  AS BlockType,
                    b.orderIndex AS OrderIndex,
                    b.isRequired AS IsRequired,
                    0            AS IsCompleted
                FROM   dbo.moduleBlockTable b
                WHERE  b.moduleID = @mid
                  AND  (b.blockType IN ('Video','Text','Quiz') OR b.blockType LIKE 'Flashcard%')
                ORDER  BY b.orderIndex;";

            var list = new List<TopicRow>();
            string sql = string.IsNullOrEmpty(userId) ? sqlGuest : sqlWithUser;

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                if (!string.IsNullOrEmpty(userId))
                    cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@mid", moduleId);
                con.Open();
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                        list.Add(new TopicRow
                        {
                            BlockId = dr["BlockId"].ToString(),
                            Title = dr["Title"].ToString(),
                            BlockType = dr["BlockType"].ToString(),
                            OrderIndex = Convert.ToInt32(dr["OrderIndex"]),
                            IsRequired = Convert.ToBoolean(dr["IsRequired"]),
                            IsCompleted = Convert.ToInt32(dr["IsCompleted"]) == 1
                        });
            }

            return list;
        }

        // Sequential lock map
        private bool IsSequentialProgressEnabled(string moduleId)
        {
            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(@"
                SELECT TOP 1 ISNULL(mar.sequentialProgress, 1)
                FROM dbo.moduleTable m
                LEFT JOIN dbo.moduleAccessRuleTable mar ON mar.moduleID = m.moduleID
                WHERE m.moduleID = @mid", con))
            {
                cmd.Parameters.AddWithValue("@mid", moduleId);
                con.Open();
                var result = cmd.ExecuteScalar();
                return result == null || result == DBNull.Value || Convert.ToBoolean(result);
            }
        }

        private Dictionary<string, bool> BuildSequentialLockMap(List<TopicRow> topics, bool sequentialProgress)
        {
            var locked = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
            if (!sequentialProgress)
            {
                foreach (var t in topics)
                    locked[t.BlockId] = false;
                return locked;
            }

            bool previousCompleted = true;

            foreach (var t in topics)
            {
                locked[t.BlockId] = !previousCompleted;
                previousCompleted = t.IsCompleted;
            }

            return locked;
        }

        // Sidebar
        private void BindSidebarModules(List<TopicRow> topics, Dictionary<string, bool> lockedMap)
        {
            var sidebar = new List<dynamic>();

            sidebar.Add(new
            {
                BlockId = "",
                Title = "Module Overview",
                Icon = "check_circle",
                IconFill = "fill-icon text-math-green",
                CssClass = "flex items-center gap-3 p-4 bg-math-green/5 rounded-2xl border border-math-green/20",
                IsCompleted = true,
                IsLocked = false
            });

            foreach (var t in topics)
            {
                bool isLocked = lockedMap.ContainsKey(t.BlockId) && lockedMap[t.BlockId];
                string icon, css, iconFill;

                if (t.IsCompleted)
                {
                    icon = "check_circle";
                    iconFill = "fill-icon text-math-green";
                    css = "flex items-center gap-3 p-4 bg-math-green/5 rounded-2xl border border-math-green/15 text-math-dark-blue";
                }
                else if (isLocked)
                {
                    icon = "lock";
                    iconFill = "text-gray-300";
                    css = "flex items-center gap-3 p-4 bg-white/60 rounded-2xl border border-transparent cursor-not-allowed text-gray-400 opacity-80";
                }
                else
                {
                    icon = "circle";
                    iconFill = "";
                    css = "flex items-center gap-3 p-4 bg-white/70 hover:bg-white rounded-2xl border border-gray-100 transition-all cursor-pointer";
                }

                sidebar.Add(new
                {
                    BlockId = t.BlockId,
                    Title = t.Title,
                    Icon = icon,
                    IconFill = iconFill,
                    CssClass = css,
                    IsCompleted = t.IsCompleted,
                    IsLocked = isLocked
                });
            }

            rptSidebarModules.DataSource = sidebar;
            rptSidebarModules.DataBind();
        }

        // Main block cards
        private void BindMainTopics(List<TopicRow> topics, Dictionary<string, bool> lockedMap)
        {
            const string BtnPrimary =
                "w-full inline-flex items-center justify-center gap-2 " +
                "h-14 px-7 rounded-full " +
                "bg-math-blue text-white " +
                "font-black uppercase tracking-widest text-[12px] " +
                "shadow-lg shadow-math-blue/20 " +
                "hover:bg-math-dark-blue transition-all active:scale-[0.99]";

            const string BtnDone =
                "w-full inline-flex items-center justify-center gap-2 " +
                "h-14 px-7 rounded-full " +
                "bg-math-green text-white " +
                "font-black uppercase tracking-widest text-[12px] " +
                "shadow-lg shadow-math-green/20 " +
                "hover:brightness-95 transition-all active:scale-[0.99]";

            const string BtnLocked =
                "w-full inline-flex items-center justify-center gap-2 " +
                "h-14 px-7 rounded-full " +
                "bg-gray-100 border border-gray-200 text-gray-400 " +
                "font-black uppercase tracking-widest text-[12px]";

            string[] icons = { "architecture", "change_history", "square_foot", "functions", "calculate", "category" };
            string[] iconBgs = { "bg-blue-100", "bg-green-100", "bg-yellow-100", "bg-purple-100", "bg-orange-100", "bg-teal-100" };
            string[] iconColors = { "text-math-blue", "text-math-green", "text-primary", "text-purple-600", "text-orange-600", "text-teal-600" };

            var cardList = new List<dynamic>();

            for (int i = 0; i < topics.Count; i++)
            {
                var t = topics[i];
                bool isLocked = lockedMap.ContainsKey(t.BlockId) && lockedMap[t.BlockId];
                string buttonText, buttonIcon, buttonClass;
                bool lockedForUi;
                bool isGuestCta = false;

                if (IsGuest)
                {
                    buttonText = isLocked ? "LOCKED" : "LOGIN TO START";
                    buttonIcon = isLocked ? "lock" : "login";
                    buttonClass = isLocked ? BtnLocked : BtnPrimary;
                    lockedForUi = isLocked;
                    isGuestCta = false;
                }
                else if (t.IsCompleted)
                {
                    buttonText = "COMPLETED";
                    buttonIcon = "check";
                    buttonClass = BtnDone;
                    lockedForUi = false;
                }
                else if (isLocked)
                {
                    buttonText = "LOCKED";
                    buttonIcon = "lock";
                    buttonClass = BtnLocked;
                    lockedForUi = true;
                }
                else
                {
                    buttonText = "START LEARNING";
                    buttonIcon = "chevron_right";
                    buttonClass = BtnPrimary;
                    lockedForUi = false;
                }

                int idx = i % icons.Length;
                string guestHref = IsGuest && !isLocked ? "Login.aspx" : "#";

                cardList.Add(new
                {
                    BlockId = t.BlockId,
                    Title = t.Title,
                    BlockType = t.BlockType,
                    OrderIndex = t.OrderIndex,
                    IsCompleted = t.IsCompleted,
                    IsLocked = lockedForUi,
                    IsGuestCta = isGuestCta,
                    IsGuestNav = IsGuest && !isLocked,
                    GuestHref = guestHref,
                    Description = DescribeBlock(t.BlockType),
                    Icon = icons[idx],
                    IconBg = iconBgs[idx],
                    IconColor = iconColors[idx],
                    HoverScale = "group-hover:scale-110 transition-transform",
                    Opacity = isLocked ? "opacity-90" : "",
                    ButtonText = buttonText,
                    ButtonIcon = buttonIcon,
                    ButtonClass = buttonClass
                });
            }

            rptMainTopics.DataSource = cardList;
            rptMainTopics.DataBind();
        }

        // Assessment panel
        private void BindAssessment()
        {
            string userId = CurrentUserId;

            if (IsGuest || string.IsNullOrWhiteSpace(userId))
            {
                pnlAssessment.Visible = false;
                return;
            }

            const string sql = @"
            SELECT TOP 1
                a.assessmentID,
                a.title,
                ISNULL(a.totalMarks, 0)       AS totalMarks,
                ISNULL(a.timeLimitMinutes, 0) AS timeLimitMinutes,
                ISNULL(a.passingScore, 0)     AS passingScore,
                (SELECT COUNT(*) FROM dbo.questionTable q 
                 WHERE q.assessmentID = a.assessmentID) AS questionCount
            FROM dbo.assessmentTable a
            WHERE a.moduleID    = @mid
              AND a.isPublished = 1
            ORDER BY a.createdAt DESC;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                con.Open();

                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read())
                    {
                        pnlAssessment.Visible = false;
                        return;
                    }

                    string assessmentId = r["assessmentID"].ToString();
                    int totalMarks = Convert.ToInt32(r["totalMarks"]);
                    int timeLimit = Convert.ToInt32(r["timeLimitMinutes"]);
                    int questionCount = Convert.ToInt32(r["questionCount"]);

                    pnlAssessment.Visible = true;
                    litAssessmentTitle.Text = r["title"].ToString();
                    litAssessmentQuestions.Text = questionCount.ToString();
                    litAssessmentMarks.Text = totalMarks.ToString();
                    litAssessmentTime.Text = timeLimit > 0 ? $"{timeLimit} min" : "No time limit";

                    r.Close();

                    bool allDone = AllBlocksComplete(userId);
                    pnlAssessmentLocked.Visible = !allDone;
                    pnlAssessmentUnlocked.Visible = allDone;

                    if (allDone)
                    {
                        int attempts = GetAttemptCount(assessmentId, userId);

                        if (attempts > 0)
                        {
                            pnlAlreadyAttempted.Visible = true;
                            pnlNotAttempted.Visible = false;
                            litBestScore.Text = GetBestScore(assessmentId, userId);
                            lnkRetryAssessment.NavigateUrl =
                                ResolveUrl($"~/studentAssessment.aspx?assessmentId={assessmentId}&moduleId={ModuleId}");

                            int passingScore = GetPassingScore(assessmentId);
                            int bestRaw = GetBestRawScore(assessmentId, userId);
                            int bestPercent = totalMarks > 0 ? (int)Math.Round(bestRaw * 100.0 / totalMarks) : 0;

                            pnlPassBadge.Visible = bestPercent >= passingScore;
                            pnlFailBadge.Visible = bestPercent < passingScore;
                        }
                        else
                        {
                            pnlAlreadyAttempted.Visible = false;
                            pnlNotAttempted.Visible = true;
                            lnkStartAssessment.NavigateUrl =
                                ResolveUrl($"~/studentAssessment.aspx?assessmentId={assessmentId}&moduleId={ModuleId}");
                        }
                    }
                }
            }
        }

        private bool AllBlocksComplete(string userId)
        {
            const string sql = @"
        SELECT COUNT(*) 
        FROM dbo.moduleBlockTable mb
        WHERE mb.moduleID = @mid
          AND (mb.blockType IN ('Video','Text','Quiz') OR mb.blockType LIKE 'Flashcard%')
          AND NOT EXISTS (
              SELECT 1 FROM dbo.studentBlockProgressTable sp
              WHERE sp.blockID    = mb.blockID
                AND sp.userID     = @uid
                AND sp.isCompleted = 1
          );";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                cmd.Parameters.AddWithValue("@uid", userId);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) == 0;
            }
        }

        private int GetAttemptCount(string assessmentId, string userId)
        {
            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.assessmentAttemptTable WHERE assessmentID=@aid AND userID=@uid", con))
            {
                cmd.Parameters.AddWithValue("@aid", assessmentId);
                cmd.Parameters.AddWithValue("@uid", userId);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private string GetBestScore(string assessmentId, string userId)
        {
            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(@"
        SELECT TOP 1 score, totalMarks 
        FROM dbo.assessmentAttemptTable 
        WHERE assessmentID=@aid AND userID=@uid 
        ORDER BY score DESC", con))
            {
                cmd.Parameters.AddWithValue("@aid", assessmentId);
                cmd.Parameters.AddWithValue("@uid", userId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                    return r.Read() ? $"{r["score"]}/{r["totalMarks"]}" : "N/A";
            }
        }

        private int GetModuleProgressPercent(string userId, string moduleId)
        {
            const string sql = @"
                SELECT
                    COUNT(*) AS Total,
                    SUM(CASE WHEN p.isCompleted = 1 THEN 1 ELSE 0 END) AS Done
                FROM   dbo.moduleBlockTable b
                LEFT   JOIN dbo.studentBlockProgressTable p
                       ON  p.blockID = b.blockID AND p.userID = @uid
                WHERE  b.moduleID = @mid
                  AND  (b.blockType IN ('Video','Text','Quiz') OR b.blockType LIKE 'Flashcard%');";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@mid", moduleId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return 0;
                    int total = r["Total"] == DBNull.Value ? 0 : Convert.ToInt32(r["Total"]);
                    int done = r["Done"] == DBNull.Value ? 0 : Convert.ToInt32(r["Done"]);
                    if (total <= 0) return 0;
                    return (int)Math.Round(done * 100.0 / total);
                }
            }
        }

        private void ApplyProgressRingOffset()
        {
            circleProgress.Attributes["style"] =
                "transform: rotate(-90deg); transform-origin: 50% 50%; stroke-dashoffset: " + ProgressOffset + ";";
        }

        protected void rptMainTopics_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "OpenTopic") return;
            if (IsGuest) return;

            string userId = CurrentUserId;
            if (string.IsNullOrWhiteSpace(userId)) { Response.Redirect("~/Login.aspx"); return; }

            string blockId = (e.CommandArgument?.ToString() ?? "").Trim();
            if (string.IsNullOrWhiteSpace(blockId)) return;

            var topics = GetTopicsForModule(userId, ModuleId);
            bool sequentialProgress = IsSequentialProgressEnabled(ModuleId);
            var lockedMap = BuildSequentialLockMap(topics, sequentialProgress);

            if (lockedMap.ContainsKey(blockId) && lockedMap[blockId]) return;

            string encodedModuleId = Server.UrlEncode(ModuleId);
            string encodedBlockId = Server.UrlEncode(blockId);
            Response.Redirect($"~/moduleContent.aspx?moduleId={encodedModuleId}&blockId={encodedBlockId}#block-{encodedBlockId}");
        }

        private int GetPassingScore(string assessmentId)
        {
            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(
                "SELECT ISNULL(passingScore, 0) FROM dbo.assessmentTable WHERE assessmentID=@aid", con))
            {
                cmd.Parameters.AddWithValue("@aid", assessmentId);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private int GetBestRawScore(string assessmentId, string userId)
        {
            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(@"
        SELECT TOP 1 score FROM dbo.assessmentAttemptTable 
        WHERE assessmentID=@aid AND userID=@uid 
        ORDER BY score DESC", con))
            {
                cmd.Parameters.AddWithValue("@aid", assessmentId);
                cmd.Parameters.AddWithValue("@uid", userId);
                con.Open();
                var result = cmd.ExecuteScalar();
                return result == null ? 0 : Convert.ToInt32(result);
            }
        }

        private string DescribeBlock(string blockType)
        {
            switch ((blockType ?? "").Trim().ToLowerInvariant())
            {
                case "content": return "Read the notes and learn the concept.";
                case "video": return "Watch the lesson video and take notes.";
                case "quiz": return "Test your understanding with a short quiz.";
                case "flashcard": return "Review key formulas and definitions.";
                case "assessment": return "Final challenge: complete the assessment.";
                case "text": return "Read through the material and take notes.";
                default: return "Open this topic to continue your learning.";
            }
        }
    }
}





