using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class teacherForum : System.Web.UI.Page
    {
        private string connectionString =
            System.Configuration.ConfigurationManager
                  .ConnectionStrings["MathSphereDB"].ConnectionString;

        private string TeacherID =>
            (Session["UserID"] as string)?.Trim()
            ?? (Session["userID"] as string)?.Trim()
            ?? "";

        // -
        //  Page Load
        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCategoryOptions();
                BindForumPosts();
                BindSidebar();
            }
        }

        // -
        //  Render post content — parses ##IMG##path markers into <img>
        // -
        protected string RenderPostContent(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return "";

            const string marker = "##IMG##";
            var sb = new System.Text.StringBuilder();
            int pos = 0;

            while (pos < raw.Length)
            {
                int imgStart = raw.IndexOf(marker, pos, StringComparison.OrdinalIgnoreCase);
                if (imgStart < 0)
                {
                    sb.Append("<span>");
                    sb.Append(HttpUtility.HtmlEncode(raw.Substring(pos)));
                    sb.Append("</span>");
                    break;
                }

                if (imgStart > pos)
                {
                    sb.Append("<span>");
                    sb.Append(HttpUtility.HtmlEncode(raw.Substring(pos, imgStart - pos)));
                    sb.Append("</span>");
                }

                int pathStart = imgStart + marker.Length;
                int pathEnd = raw.IndexOf(marker, pathStart, StringComparison.OrdinalIgnoreCase);
                string imgPath = pathEnd < 0
                    ? raw.Substring(pathStart).Trim()
                    : raw.Substring(pathStart, pathEnd - pathStart).Trim();

                string src = imgPath.StartsWith("Uploads/", StringComparison.OrdinalIgnoreCase)
                    ? ResolveUrl("~/" + imgPath)
                    : HttpUtility.HtmlEncode(imgPath);

                sb.AppendFormat(
                    "<img src=\"{0}\" alt=\"Post image\" " +
                    "class=\"max-w-full rounded-2xl border border-gray-100 shadow-sm mt-2 max-h-80 object-contain\" " +
                    "onerror=\"this.style.display='none'\" />",
                    src);

                pos = pathEnd < 0 ? raw.Length : pathEnd;
            }

            return sb.ToString();
        }

        // -
        //  Bind sidebar: Top Solutions + Category nav + Stats
        // -
        
        protected string GetTotalForumPostCount()
        {
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.forumPostingTable WHERE isDeleted = 0", conn))
                {
                    conn.Open();
                    return Convert.ToString(cmd.ExecuteScalar() ?? 0);
                }
            }
            catch
            {
                return "0";
            }
        }

        private void BindSidebar()
        {
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Top Solutions
                    var sbTS = new System.Text.StringBuilder();
                    using (var cmd = new SqlCommand(@"
                        SELECT TOP 5
                            p.postID, p.title, u.fullName AS author,
                            ISNULL(u.AvatarUrl,
                                'https://ui-avatars.com/api/?name='
                                + REPLACE(u.fullName,' ','+')
                                + '&background=2563eb&color=fff') AS avatar
                        FROM  dbo.forumPostingTable p
                        JOIN  dbo.userTable u ON u.userID = p.authorUserID
                        WHERE p.isTopSolution = 1 AND p.isDeleted = 0
                        ORDER BY p.updatedAt DESC", conn))
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.HasRows)
                            sbTS.Append("<p class=\"text-xs text-gray-400 italic\">No top solutions yet.</p>");
                        else
                        {
                            while (r.Read())
                            {
                                string postId = r["postID"].ToString();
                                string title = HttpUtility.HtmlEncode(r["title"].ToString());
                                string author = HttpUtility.HtmlEncode(r["author"].ToString());
                                string avatar = HttpUtility.HtmlEncode(r["avatar"].ToString());
                                if (title.Length > 38) title = title.Substring(0, 35) + "…";

                                sbTS.AppendFormat(@"
                                    <div class=""ts-item"" onclick=""scrollToPost('{0}')"">
                                        <img src=""{1}"" alt=""{2}"" class=""size-7 rounded-xl object-cover flex-shrink-0 border border-yellow-200"" />
                                        <div class=""flex-1 min-w-0"">
                                            <p class=""text-xs font-black text-math-dark-blue leading-tight truncate"">{3}</p>
                                            <p class=""text-[10px] text-gray-400 font-bold mt-0.5"">by {2}</p>
                                        </div>
                                    </div>",
                                    postId, avatar, author, title);
                            }
                        }
                    }
                    litTopSolutions.Text = sbTS.ToString();

                    // Category nav
                    var sbCat = new System.Text.StringBuilder();
                    using (var cmd2 = new SqlCommand(@"
                        SELECT DISTINCT ISNULL(category, 'Forum Discussion') AS cat,
                               COUNT(*) AS cnt
                        FROM   dbo.forumPostingTable
                        WHERE  isDeleted = 0
                        GROUP  BY ISNULL(category, 'Forum Discussion')
                        ORDER  BY cat", conn))
                    using (var r2 = cmd2.ExecuteReader())
                    {
                        while (r2.Read())
                        {
                            string cat = HttpUtility.HtmlEncode(r2["cat"].ToString());
                            int cnt = Convert.ToInt32(r2["cnt"]);
                            string catVal = cat.ToLower();

                            sbCat.AppendFormat(@"
                                <button type=""button"" data-cat=""{0}"" onclick=""sidebarSetCat(this,'{0}')""
                                        class=""sidebar-cat-btn w-full flex items-center justify-between px-4 py-3 rounded-2xl text-sm font-black text-math-dark-blue hover:bg-math-blue/5 transition-colors group"">
                                    <span>{1}</span>
                                    <div class=""flex items-center gap-1"">
                                        <span class=""text-[10px] font-black text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full"">{2}</span>
                                        <span class=""material-symbols-outlined text-base text-gray-300 group-hover:text-math-blue"">chevron_right</span>
                                    </div>
                                </button>",
                                catVal, cat, cnt);
                        }
                    }
                    litCategoryNav.Text = sbCat.ToString();

                    // Stats
                    int total = 0, flagged = 0, resolved = 0;
                    using (var cmd3 = new SqlCommand(@"
                        SELECT
                            COUNT(*) AS total,
                            SUM(CASE WHEN isFlagged  = 1 THEN 1 ELSE 0 END) AS flagged,
                            SUM(CASE WHEN isResolved = 1 THEN 1 ELSE 0 END) AS resolved
                        FROM dbo.forumPostingTable WHERE isDeleted = 0", conn))
                    using (var r3 = cmd3.ExecuteReader())
                    {
                        if (r3.Read())
                        {
                            total = Convert.ToInt32(r3["total"]);
                            flagged = Convert.ToInt32(r3["flagged"]);
                            resolved = Convert.ToInt32(r3["resolved"]);
                        }
                    }

                    litStatTotal.Text = $"<span class=\"text-xs font-black text-math-dark-blue\">{total}</span>";
                    litStatFlagged.Text = flagged > 0
                        ? $"<span class=\"text-xs font-black text-red-500\">{flagged}</span>"
                        : $"<span class=\"text-xs font-black text-gray-400\">{flagged}</span>";
                    litStatResolved.Text = $"<span class=\"text-xs font-black text-math-green\">{resolved}</span>";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[teacherForum] BindSidebar error: " + ex.Message);
            }
        }

        // -
        //  Populate category <option> list
        // -
        private void BindCategoryOptions()
        {
            var cats = new List<string>();
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT DISTINCT ISNULL(category, 'Forum Discussion') AS cat
                    FROM   dbo.forumPostingTable
                    WHERE  isDeleted = 0 AND category IS NOT NULL
                    ORDER  BY cat;", conn))
                {
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                        while (r.Read()) cats.Add(r["cat"].ToString());
                }
            }
            catch { /* skip if table missing */ }

            var sb = new System.Text.StringBuilder();
            foreach (var c in cats)
            {
                string enc = HttpUtility.HtmlEncode(c);
                sb.AppendFormat("<option value=\"{0}\">{1}</option>", enc.ToLower(), enc);
            }
            litCategoryOptions.Text = sb.ToString();
        }

        private void BindForumPosts()
        {
            string teacherId = TeacherID;

            const string sql = @"
                SELECT
                    p.postID                                                        AS PostID,
                    p.title                                                         AS PostTitle,
                    p.content                                                       AS PostContent,
                    p.status                                                        AS Status,

                    u.fullName                                                      AS StudentName,
                    ISNULL(u.AvatarUrl,
                        'https://ui-avatars.com/api/?name='
                        + REPLACE(u.fullName,' ','+')
                        + '&background=2563eb&color=fff')                           AS StudentAvatar,

                    CAST(
                        (SELECT COUNT(*) FROM dbo.forumCommentTable cc
                         WHERE  cc.authorUserID = p.authorUserID AND cc.isDeleted = 0)
                    AS NVARCHAR(10))                                                AS StudentLevel,

                    ISNULL(p.category, N'Forum Discussion')                        AS Category,

                    -- use GETUTCDATE() to match SYSUTCDATETIME() storage
                    CASE
                        WHEN DATEDIFF(MINUTE, p.createdAt, GETUTCDATE()) < 1
                            THEN 'Just now'
                        WHEN DATEDIFF(MINUTE, p.createdAt, GETUTCDATE()) < 60
                            THEN CAST(DATEDIFF(MINUTE, p.createdAt, GETUTCDATE()) AS NVARCHAR) + 'm ago'
                        WHEN DATEDIFF(HOUR,   p.createdAt, GETUTCDATE()) < 24
                            THEN CAST(DATEDIFF(HOUR,   p.createdAt, GETUTCDATE()) AS NVARCHAR) + 'h ago'
                        ELSE CAST(DATEDIFF(DAY, p.createdAt, GETUTCDATE()) AS NVARCHAR) + 'd ago'
                    END                                                             AS TimeAgo,

                    CAST(p.isTopSolution AS BIT)                                   AS IsTopSolution,
                    CAST(p.isFlagged     AS BIT)                                   AS IsFlagged,
                    CAST(p.isResolved    AS BIT)                                   AS IsResolved,

                    ISNULL(ru.fullName, '')                                        AS ResolvedByName,

                    -- use GETUTCDATE() for resolvedAt comparison too
                    CASE
                        WHEN p.resolvedAt IS NULL THEN ''
                        WHEN DATEDIFF(MINUTE, p.resolvedAt, GETUTCDATE()) < 1
                            THEN 'Just now'
                        WHEN DATEDIFF(MINUTE, p.resolvedAt, GETUTCDATE()) < 60
                            THEN CAST(DATEDIFF(MINUTE, p.resolvedAt, GETUTCDATE()) AS NVARCHAR) + 'm ago'
                        WHEN DATEDIFF(HOUR,   p.resolvedAt, GETUTCDATE()) < 24
                            THEN CAST(DATEDIFF(HOUR,   p.resolvedAt, GETUTCDATE()) AS NVARCHAR) + 'h ago'
                        ELSE CAST(DATEDIFF(DAY, p.resolvedAt, GETUTCDATE()) AS NVARCHAR) + 'd ago'
                    END                                                             AS ResolvedTimeAgo,

                    (SELECT COUNT(*) FROM dbo.forumLikeTable fl
                     WHERE  fl.postID = p.postID)                                  AS LikeCount,

                    CAST(
                        (SELECT COUNT(*) FROM dbo.forumLikeTable fl2
                         WHERE  fl2.postID = p.postID AND fl2.userID = @teacherId)
                    AS BIT)                                                         AS IsLikedByTeacher,

                    (SELECT COUNT(*) FROM dbo.forumCommentTable fc
                     WHERE  fc.postID = p.postID AND fc.isDeleted = 0)             AS CommentCount

                FROM  dbo.forumPostingTable p
                JOIN  dbo.userTable         u  ON u.userID  = p.authorUserID
                LEFT JOIN dbo.userTable     ru ON ru.userID = p.resolvedByUserID
                WHERE p.isDeleted = 0
                ORDER BY
                    CASE WHEN p.isFlagged  = 1 THEN 0 ELSE 1 END,
                    CASE WHEN p.isResolved = 1 THEN 1 ELSE 0 END,
                    p.createdAt DESC";

            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@teacherId",
                        string.IsNullOrEmpty(teacherId) ? (object)DBNull.Value : teacherId);

                    conn.Open();
                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    ConvertToBoolColumn(dt, "IsTopSolution");
                    ConvertToBoolColumn(dt, "IsFlagged");
                    ConvertToBoolColumn(dt, "IsResolved");
                    ConvertToBoolColumn(dt, "IsLikedByTeacher");

                    rptForumPosts.DataSource = dt;
                    rptForumPosts.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowToast("DB Error: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("[teacherForum] BindForumPosts error: " + ex);
            }
        }

        // -
        //  ItemDataBound
        // -
        protected void rptForumPosts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            string postId = row["PostID"].ToString();
            string status = row["Status"].ToString();
            int commentCount = Convert.ToInt32(row["CommentCount"]);
            bool isResolved = (bool)row["IsResolved"];
            string resolvedByName = row["ResolvedByName"].ToString();
            string resolvedTimeAgo = row["ResolvedTimeAgo"].ToString();

            // Status badge
            var litStatus = (Literal)e.Item.FindControl("litStatusBadge");
            litStatus.Text = BuildStatusBadge(status, isResolved);

            // Comment count
            var litCC = (Literal)e.Item.FindControl("litCommentCount");
            litCC.Text = commentCount + " ";

            // Resolved banner
            var litResolved = (Literal)e.Item.FindControl("litResolvedBanner");
            if (litResolved != null)
                litResolved.Text = isResolved ? BuildResolvedBanner(resolvedByName, resolvedTimeAgo) : "";

            // Comments
            var litComments = (Literal)e.Item.FindControl("litComments");
            litComments.Text = BuildCommentsHtml(postId);

            // Teacher feedback
            var litFeedback = (Literal)e.Item.FindControl("litFeedback");
            litFeedback.Text = BuildFeedbackHtml(postId);
        }

        // -
        //  Resolved banner HTML
        // -
        private string BuildResolvedBanner(string resolvedByName, string resolvedTimeAgo)
        {
            string by = string.IsNullOrWhiteSpace(resolvedByName) ? "Teacher" : HttpUtility.HtmlEncode(resolvedByName);
            string when = string.IsNullOrWhiteSpace(resolvedTimeAgo) ? "" : $" · {resolvedTimeAgo}";
            return $@"
                <div class=""resolved-banner flex items-center gap-2 px-5 py-2 mt-4 rounded-2xl
                             bg-green-50 border border-green-200 text-math-green text-[11px] font-black uppercase tracking-widest"">
                    <span class=""material-symbols-outlined text-base fill-icon"">verified</span>
                    Resolved by {by}{when}
                </div>";
        }

        // -
        //  Build comments HTML
        //  Already uses GETUTCDATE() — no change needed here
        // -
        private string BuildCommentsHtml(string postId)
        {
            var sb = new System.Text.StringBuilder();
            try
            {
                const string sql = @"
                    SELECT
                        c.content                                                   AS Content,
                        u.fullName                                                  AS AuthorName,
                        ISNULL(u.AvatarUrl,
                            'https://ui-avatars.com/api/?name='
                            + REPLACE(u.fullName,' ','+')
                            + '&background=e5e7eb&color=1e3a8a')                   AS Avatar,
                        CASE
                            WHEN DATEDIFF(MINUTE, c.createdAt, GETUTCDATE()) < 1   THEN 'Just now'
                            WHEN DATEDIFF(MINUTE, c.createdAt, GETUTCDATE()) < 60  THEN CAST(DATEDIFF(MINUTE, c.createdAt, GETUTCDATE()) AS NVARCHAR) + 'm ago'
                            WHEN DATEDIFF(HOUR,   c.createdAt, GETUTCDATE()) < 24  THEN CAST(DATEDIFF(HOUR,   c.createdAt, GETUTCDATE()) AS NVARCHAR) + 'h ago'
                            ELSE CAST(DATEDIFF(DAY, c.createdAt, GETUTCDATE()) AS NVARCHAR) + 'd ago'
                        END                                                         AS TimeAgo,
                        ISNULL(r.roleName, 'Student')                              AS Role
                    FROM  dbo.forumCommentTable c
                    JOIN  dbo.userTable         u  ON u.userID = c.authorUserID
                    LEFT JOIN dbo.userRoleTable ur ON ur.userID = c.authorUserID
                    LEFT JOIN dbo.Role          r  ON r.roleID  = ur.roleID
                    WHERE c.postID = @postID AND c.isDeleted = 0
                    ORDER BY c.createdAt ASC";

                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@postID", postId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.HasRows)
                            sb.Append("<p class=\"text-xs text-gray-400 italic font-bold py-2\">No comments yet.</p>");
                        else
                        {
                            while (r.Read())
                            {
                                string name = HttpUtility.HtmlEncode(r["AuthorName"].ToString());
                                string content = HttpUtility.HtmlEncode(r["Content"].ToString());
                                string avatar = HttpUtility.HtmlEncode(r["Avatar"].ToString());
                                string time = r["TimeAgo"].ToString();
                                string role = r["Role"].ToString();
                                bool isTeacher = role.Equals("Teacher", StringComparison.OrdinalIgnoreCase)
                                               || role.Equals("Admin", StringComparison.OrdinalIgnoreCase);

                                sb.AppendFormat(@"
                                    <div class=""flex items-start gap-3 py-2.5"">
                                        <img src=""{0}"" alt=""{1}"" class=""size-8 rounded-xl object-cover border border-gray-200 flex-shrink-0"" />
                                        <div class=""flex-1"">
                                            <div class=""flex items-center gap-2 mb-0.5"">
                                                <span class=""text-xs font-black text-math-dark-blue"">{1}</span>
                                                {2}
                                                <span class=""text-[9px] text-gray-400 ml-auto"">{3}</span>
                                            </div>
                                            <p class=""text-sm text-gray-700 font-medium leading-relaxed bg-gray-50 px-3 py-2 rounded-2xl rounded-tl-none"">{4}</p>
                                        </div>
                                    </div>",
                                    avatar, name,
                                    isTeacher ? "<span class=\"text-[9px] font-black text-math-blue uppercase bg-blue-50 px-2 py-0.5 rounded-full\">Teacher</span>" : "",
                                    time, content);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                sb.Append($"<p class=\"text-xs text-red-400 italic\">{HttpUtility.HtmlEncode(ex.Message)}</p>");
            }
            return sb.ToString();
        }

        // -
        //  Build teacher feedback HTML
        //  Already uses GETUTCDATE() — no change needed here
        // -
        private string BuildFeedbackHtml(string postId)
        {
            var sb = new System.Text.StringBuilder();
            try
            {
                const string sql = @"
                    SELECT
                        c.content                                                   AS FeedbackText,
                        u.fullName                                                  AS TeacherName,
                        CASE
                            WHEN DATEDIFF(MINUTE, c.createdAt, GETUTCDATE()) < 1   THEN 'Just now'
                            WHEN DATEDIFF(MINUTE, c.createdAt, GETUTCDATE()) < 60  THEN CAST(DATEDIFF(MINUTE, c.createdAt, GETUTCDATE()) AS NVARCHAR) + 'm ago'
                            WHEN DATEDIFF(HOUR,   c.createdAt, GETUTCDATE()) < 24  THEN CAST(DATEDIFF(HOUR,   c.createdAt, GETUTCDATE()) AS NVARCHAR) + 'h ago'
                            ELSE CAST(DATEDIFF(DAY, c.createdAt, GETUTCDATE()) AS NVARCHAR) + 'd ago'
                        END                                                         AS TimeAgo
                    FROM  dbo.forumCommentTable c
                    JOIN  dbo.userTable         u  ON u.userID  = c.authorUserID
                    JOIN  dbo.userRoleTable     ur ON ur.userID = c.authorUserID
                    JOIN  dbo.Role              r  ON r.roleID  = ur.roleID
                    WHERE c.postID    = @postID
                      AND c.isDeleted = 0
                      AND r.roleName IN ('Teacher', 'Admin')
                    ORDER BY c.createdAt ASC";

                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@postID", postId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.HasRows)
                            sb.Append("<p class=\"text-xs text-gray-400 italic font-bold py-2\">No feedback posted yet.</p>");
                        else
                        {
                            while (r.Read())
                            {
                                string teacher = HttpUtility.HtmlEncode(r["TeacherName"].ToString());
                                string feedback = HttpUtility.HtmlEncode(r["FeedbackText"].ToString());
                                string time = r["TimeAgo"].ToString();

                                sb.AppendFormat(@"
                                    <div class=""flex items-start gap-3 py-2.5"">
                                        <div class=""size-8 rounded-xl bg-gradient-to-br from-math-blue to-math-dark-blue flex items-center justify-center text-white flex-shrink-0"">
                                            <span class=""material-symbols-outlined text-sm fill-icon"">person</span>
                                        </div>
                                        <div class=""flex-1"">
                                            <div class=""flex items-center gap-2 mb-0.5"">
                                                <span class=""text-xs font-black text-math-blue"">{0}</span>
                                                <span class=""text-[9px] font-black text-math-blue uppercase bg-blue-50 px-2 py-0.5 rounded-full"">Teacher</span>
                                                <span class=""text-[9px] text-gray-400 ml-auto"">{1}</span>
                                            </div>
                                            <p class=""text-sm text-gray-700 font-medium leading-relaxed bg-blue-50 px-3 py-2.5 rounded-2xl rounded-tl-none"">{2}</p>
                                        </div>
                                    </div>",
                                    teacher, time, feedback);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                sb.Append($"<p class=\"text-xs text-gray-400 italic py-2\">{HttpUtility.HtmlEncode(ex.Message)}</p>");
            }
            return sb.ToString();
        }

        // -
        //  Status badge HTML
        // -
        private string BuildStatusBadge(string status, bool isResolved)
        {
            if (isResolved)
                return "<span class=\"bg-green-50 text-math-green border border-green-200 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0\">Resolved</span>";

            switch (status)
            {
                case "Flagged":
                    return "<span class=\"bg-red-50 text-red-500 border border-red-200 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0\">Flagged</span>";
                default:
                    return "<span class=\"bg-yellow-50 text-yellow-600 border border-yellow-200 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest flex-shrink-0\">Active</span>";
            }
        }

        // -
        //  Repeater ItemCommand  –  Solve | Flag | Resolve | Unresolve
        // -
        protected void rptForumPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string postID = e.CommandArgument.ToString();
            switch (e.CommandName)
            {
                case "Solve": TogglePin(postID); break;
                case "Flag": ToggleFlag(postID); break;
                case "Resolve": MarkResolved(postID, true); break;
                case "Unresolve": MarkResolved(postID, false); break;
            }
            BindForumPosts();
            BindSidebar();
        }

        // -
        //  Mark / Unmark Resolved
        // -
        private void MarkResolved(string postID, bool resolve)
        {
            string teacherId = TeacherID;
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            if (resolve)
                            {
                                using (var cmd = new SqlCommand(@"
                                    UPDATE dbo.forumPostingTable
                                    SET    isResolved       = 1,
                                           resolvedByUserID = @uid,
                                           resolvedAt       = SYSUTCDATETIME(),
                                           status           = 'Hidden',
                                           updatedAt        = SYSUTCDATETIME()
                                    WHERE  postID = @pid", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@pid", postID);
                                    cmd.Parameters.AddWithValue("@uid",
                                        string.IsNullOrEmpty(teacherId) ? (object)DBNull.Value : teacherId);
                                    cmd.ExecuteNonQuery();
                                }
                                LogModerationAction(postID, "Resolve", "Post marked as resolved.", conn, tx);
                                ShowToast("Post marked as resolved.");
                            }
                            else
                            {
                                using (var cmd = new SqlCommand(@"
                                    UPDATE dbo.forumPostingTable
                                    SET    isResolved       = 0,
                                           resolvedByUserID = NULL,
                                           resolvedAt       = NULL,
                                           status           = 'Published',
                                           updatedAt        = SYSUTCDATETIME()
                                    WHERE  postID = @pid", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@pid", postID);
                                    cmd.ExecuteNonQuery();
                                }
                                LogModerationAction(postID, "Unresolve", "Resolution removed.", conn, tx);
                                ShowToast("Post reopened.");
                            }
                            tx.Commit();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
            }
            catch (Exception ex) { ShowToast("Error: " + ex.Message); }
        }

        // -
        //  Toggle Pin (Top Solution)
        // -
        private void TogglePin(string postID)
        {
            try
            {
                bool isPinned;
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT CAST(isTopSolution AS BIT) FROM dbo.forumPostingTable WHERE postID=@pid", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", postID);
                        var val = cmd.ExecuteScalar();
                        isPinned = val != null && val != DBNull.Value && Convert.ToInt32(val) != 0;
                    }

                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            if (isPinned)
                            {
                                using (var cmd = new SqlCommand(@"
                                    UPDATE dbo.forumPostingTable
                                    SET    isTopSolution = 0,
                                           status        = 'Published',
                                           updatedAt     = SYSUTCDATETIME()
                                    WHERE  postID = @pid", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@pid", postID);
                                    cmd.ExecuteNonQuery();
                                }
                                LogModerationAction(postID, "Unpin", "Top Solution pin removed.", conn, tx);
                                ShowToast("Post unpinned.");
                            }
                            else
                            {
                                using (var cmd = new SqlCommand(@"
                                    UPDATE dbo.forumPostingTable
                                    SET    isTopSolution = 1,
                                           status        = 'Hidden',
                                           updatedAt     = SYSUTCDATETIME()
                                    WHERE  postID = @pid", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@pid", postID);
                                    cmd.ExecuteNonQuery();
                                }
                                LogModerationAction(postID, "Pin", "Marked as Top Solution.", conn, tx);
                                ShowToast("Post pinned as top solution.");
                            }
                            tx.Commit();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
            }
            catch (Exception ex) { ShowToast("Error: " + ex.Message); }
        }

        // -
        //  Toggle Flag
        // -
        private void ToggleFlag(string postID)
        {
            string teacherId = TeacherID;
            if (string.IsNullOrEmpty(teacherId)) { ShowToast("Session expired."); return; }

            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        try
                        {
                            int openFlags;
                            using (var cmd = new SqlCommand(
                                "SELECT COUNT(*) FROM dbo.ForumFlag WHERE postID=@pid AND status='Open'", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@pid", postID);
                                openFlags = (int)cmd.ExecuteScalar();
                            }

                            if (openFlags > 0)
                            {
                                using (var cmd = new SqlCommand(
                                    "UPDATE dbo.ForumFlag SET status='Dismissed' WHERE postID=@pid AND status='Open'", conn, tx))
                                { cmd.Parameters.AddWithValue("@pid", postID); cmd.ExecuteNonQuery(); }

                                using (var cmd = new SqlCommand(
                                    "UPDATE dbo.forumPostingTable SET status='Published', isFlagged=0, updatedAt=SYSUTCDATETIME() WHERE postID=@pid", conn, tx))
                                { cmd.Parameters.AddWithValue("@pid", postID); cmd.ExecuteNonQuery(); }

                                LogModerationAction(postID, "Dismiss", "Flag dismissed.", conn, tx);
                                ShowToast("Flag removed.");
                            }
                            else
                            {
                                string flagId = GenerateId("FL", "ForumFlag", "flagID", conn, tx);
                                using (var cmd = new SqlCommand(@"
                                    INSERT INTO dbo.ForumFlag (flagID,postID,userID,reason,status)
                                    VALUES (@fid,@pid,@uid,'Flagged by teacher','Open')", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@fid", flagId);
                                    cmd.Parameters.AddWithValue("@pid", postID);
                                    cmd.Parameters.AddWithValue("@uid", teacherId);
                                    cmd.ExecuteNonQuery();
                                }
                                using (var cmd = new SqlCommand(
                                    "UPDATE dbo.forumPostingTable SET status='Flagged', isFlagged=1, updatedAt=SYSUTCDATETIME() WHERE postID=@pid", conn, tx))
                                { cmd.Parameters.AddWithValue("@pid", postID); cmd.ExecuteNonQuery(); }

                                LogModerationAction(postID, "Flag", "Flagged for admin review.", conn, tx);
                                ShowToast("Post flagged.");
                            }

                            tx.Commit();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
            }
            catch (Exception ex) { ShowToast("Error: " + ex.Message); }
        }

        // -
        //  WebMethod — Toggle Like
        // -
        [WebMethod(EnableSession = true)]
        [System.Web.Script.Services.ScriptMethod(ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
        public static object ToggleLike(string postId)
        {
            string cs = System.Configuration.ConfigurationManager
                              .ConnectionStrings["MathSphereDB"].ConnectionString;

            string userId =
                (HttpContext.Current.Session["UserID"] as string)?.Trim()
                ?? (HttpContext.Current.Session["userID"] as string)?.Trim();

            if (string.IsNullOrEmpty(userId))
                return new { success = false, error = "Session expired. Please refresh the page.", newCount = 0, liked = false };
            if (string.IsNullOrEmpty(postId))
                return new { success = false, error = "Invalid post.", newCount = 0, liked = false };

            try
            {
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();

                    int exists;
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.forumLikeTable WHERE postID = @pid AND userID = @uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", postId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        exists = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    if (exists > 0)
                    {
                        using (var cmd = new SqlCommand(
                            "DELETE FROM dbo.forumLikeTable WHERE postID = @pid AND userID = @uid", conn))
                        {
                            cmd.Parameters.AddWithValue("@pid", postId);
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        string likeId;
                        using (var cmd = new SqlCommand(@"
                            SELECT ISNULL(
                                MAX(TRY_CAST(SUBSTRING(likeID, 3, LEN(likeID)) AS INT)),
                            0) + 1
                            FROM dbo.forumLikeTable
                            WHERE likeID LIKE 'LK[0-9]%'", conn))
                        {
                            int nextNum = Convert.ToInt32(cmd.ExecuteScalar());
                            likeId = "LK" + nextNum.ToString("D8");
                        }

                        using (var cmd = new SqlCommand(@"
                            INSERT INTO dbo.forumLikeTable (likeID, postID, userID, createdAt)
                            VALUES (@lid, @pid, @uid, SYSUTCDATETIME())", conn))
                        {
                            cmd.Parameters.Add("@lid", SqlDbType.NVarChar, 10).Value = likeId;
                            cmd.Parameters.AddWithValue("@pid", postId);
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    int newCount;
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.forumLikeTable WHERE postID = @pid", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", postId);
                        newCount = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    return new { success = true, liked = (exists == 0), newCount };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[ToggleLike] ERROR: " + ex.ToString());
                return new { success = false, error = ex.Message, newCount = 0, liked = false };
            }
        }

        // -
        //  WebMethod — Post Feedback (also marks post resolved)
        // -
        [WebMethod(EnableSession = true)]
        [System.Web.Script.Services.ScriptMethod(ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
        public static object PostFeedback(string postId, string feedbackText)
        {
            string cs = System.Configuration.ConfigurationManager
                              .ConnectionStrings["MathSphereDB"].ConnectionString;
            string teacherId = (HttpContext.Current.Session["UserID"] as string)?.Trim()
                             ?? (HttpContext.Current.Session["userID"] as string)?.Trim();

            if (string.IsNullOrEmpty(teacherId))
                return new { success = false, error = "Session expired." };
            if (string.IsNullOrWhiteSpace(feedbackText))
                return new { success = false, error = "Feedback text is required." };
            if (feedbackText.Length > 1000)
                return new { success = false, error = "Feedback too long (max 1000 chars)." };

            try
            {
                string teacherName = "Teacher";

                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT ISNULL(fullName,'Teacher') FROM dbo.userTable WHERE userID=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", teacherId);
                        var n = cmd.ExecuteScalar();
                        if (n != null) teacherName = n.ToString();
                    }

                    string commentId;
                    using (var cmd = new SqlCommand(@"
                        SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(LTRIM(RTRIM(commentID)),3,LEN(commentID)) AS INT)),0)+1
                        FROM   dbo.forumCommentTable
                        WHERE  commentID LIKE 'CM[0-9]%'", conn))
                        commentId = "CM" + ((int)cmd.ExecuteScalar()).ToString("D8");

                    using (var cmd = new SqlCommand(@"
                        INSERT INTO dbo.forumCommentTable
                            (commentID, postID, authorUserID, content, isDeleted, createdAt)
                        VALUES
                            (@cid, @pid, @uid, @content, 0, SYSUTCDATETIME())", conn))
                    {
                        cmd.Parameters.AddWithValue("@cid", commentId);
                        cmd.Parameters.AddWithValue("@pid", postId);
                        cmd.Parameters.AddWithValue("@uid", teacherId);
                        cmd.Parameters.AddWithValue("@content", feedbackText.Trim());
                        cmd.ExecuteNonQuery();
                    }

                    using (var cmd = new SqlCommand(@"
                        UPDATE dbo.forumPostingTable
                        SET    isResolved       = 1,
                               resolvedByUserID = @uid,
                               resolvedAt       = SYSUTCDATETIME(),
                               status           = 'Hidden',
                               updatedAt        = SYSUTCDATETIME()
                        WHERE  postID = @pid", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", postId);
                        cmd.Parameters.AddWithValue("@uid", teacherId);
                        cmd.ExecuteNonQuery();
                    }
                }

                return new { success = true, teacherName, timeAgo = "Just now" };
            }
            catch (Exception ex)
            {
                return new { success = false, error = ex.Message };
            }
        }

        // -
        //  PostBack feedback submit (hidden button fallback)
        // -
        protected void btnFeedbackSubmit_Click(object sender, EventArgs e)
        {
            string postId = hfFeedbackPostId.Value?.Trim();
            string text = hfFeedbackText.Value?.Trim();

            if (string.IsNullOrEmpty(postId) || string.IsNullOrEmpty(text)) return;
            if (string.IsNullOrEmpty(TeacherID)) { ShowToast("Session expired."); return; }

            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string commentId;
                    using (var cmd = new SqlCommand(@"
                        SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(LTRIM(RTRIM(commentID)),3,LEN(commentID)) AS INT)),0)+1
                        FROM   dbo.forumCommentTable
                        WHERE  commentID LIKE 'CM[0-9]%'", conn))
                        commentId = "CM" + ((int)cmd.ExecuteScalar()).ToString("D8");

                    using (var cmd = new SqlCommand(@"
                        INSERT INTO dbo.forumCommentTable
                            (commentID, postID, authorUserID, content, isDeleted, createdAt)
                        VALUES
                            (@cid, @pid, @uid, @content, 0, SYSUTCDATETIME())", conn))
                    {
                        cmd.Parameters.AddWithValue("@cid", commentId);
                        cmd.Parameters.AddWithValue("@pid", postId);
                        cmd.Parameters.AddWithValue("@uid", TeacherID);
                        cmd.Parameters.AddWithValue("@content", text);
                        cmd.ExecuteNonQuery();
                    }

                    using (var cmd = new SqlCommand(@"
                        UPDATE dbo.forumPostingTable
                        SET    isResolved       = 1,
                               resolvedByUserID = @uid,
                               resolvedAt       = SYSUTCDATETIME(),
                               status           = 'Hidden',
                               updatedAt        = SYSUTCDATETIME()
                        WHERE  postID = @pid", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", postId);
                        cmd.Parameters.AddWithValue("@uid", TeacherID);
                        cmd.ExecuteNonQuery();
                    }
                }

                ShowToast("Feedback posted — post marked as resolved!");
            }
            catch (Exception ex)
            {
                ShowToast("Error: " + ex.Message);
            }
            finally
            {
                hfFeedbackPostId.Value = "";
                hfFeedbackText.Value = "";
            }

            BindForumPosts();
            BindSidebar();
        }

        // -
        //  Helpers
        // -
        private void LogModerationAction(string postID, string actionType,
                                         string notes, SqlConnection conn,
                                         SqlTransaction tx)
        {
            string teacherId = TeacherID;
            string actionId = GenerateId("MA", "ForumModerationAction", "actionID", conn, tx);

            using (var cmd = new SqlCommand(@"
                INSERT INTO dbo.ForumModerationAction
                    (actionID, postID, moderatorID, actionType, notes)
                VALUES
                    (@aid, @pid, @mid, @type, @notes)", conn, tx))
            {
                cmd.Parameters.AddWithValue("@aid", actionId);
                cmd.Parameters.AddWithValue("@pid", postID);
                cmd.Parameters.AddWithValue("@mid", string.IsNullOrEmpty(teacherId) ? (object)DBNull.Value : teacherId);
                cmd.Parameters.AddWithValue("@type", actionType);
                cmd.Parameters.AddWithValue("@notes", string.IsNullOrWhiteSpace(notes) ? (object)DBNull.Value : notes);
                cmd.ExecuteNonQuery();
            }
        }

        private string GenerateId(string prefix, string tableName,
                                   string idColumn, SqlConnection conn,
                                   SqlTransaction tx)
        {
            string sql = $@"
                SELECT ISNULL(MAX(CAST(SUBSTRING({idColumn},{prefix.Length + 1},
                       LEN({idColumn})) AS INT)),0)+1
                FROM   dbo.[{tableName}]
                WHERE  {idColumn} LIKE '{prefix}[0-9]%'";

            using (var cmd = new SqlCommand(sql, conn, tx))
                return prefix + ((int)cmd.ExecuteScalar()).ToString("D3");
        }

        private static void ConvertToBoolColumn(DataTable dt, string columnName)
        {
            if (!dt.Columns.Contains(columnName)) return;
            string temp = columnName + "_bool";
            dt.Columns.Add(temp, typeof(bool));
            foreach (DataRow row in dt.Rows)
            {
                object val = row[columnName];
                row[temp] = (val == DBNull.Value || val == null) ? false
                            : val is bool b ? b
                            : Convert.ToInt32(val) != 0;
            }
            dt.Columns.Remove(columnName);
            dt.Columns[temp].ColumnName = columnName;
        }

        private void ShowToast(string msg)
        {
            string safe = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "Toast",
                $"document.addEventListener('DOMContentLoaded',function(){{showToast('{safe}');}});", true);
        }
    }
}
