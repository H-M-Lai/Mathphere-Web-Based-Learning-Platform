using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Assignment
{
    public partial class Forum : Page
    {
        private string CS => ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

       
        private string UserId => (Session["UserID"] as string)?.Trim()
                              ?? (Session["userID"] as string)?.Trim();

        // Guest flag
        private bool IsGuest =>
            Session["IsGuest"] is bool b && b &&
            string.IsNullOrWhiteSpace(UserId);

        // Models
        public class ForumPost
        {
            public string PostID { get; set; }
            public string AuthorUserID { get; set; }
            public string AuthorName { get; set; }
            public string AuthorAvatar { get; set; }
            public bool AuthorIsTeacher { get; set; }
            public string Title { get; set; }
            public string Content { get; set; }
            public string ImageUrl { get; set; }
            public string Category { get; set; }
            public bool IsTopSolution { get; set; }
            public bool IsFlagged { get; set; }
            public string TimeAgo { get; set; }
            public int LikeCount { get; set; }
            public bool IsLikedByMe { get; set; }
            public int CommentCount { get; set; }
            public bool ShowComments { get; set; }
            public bool IsMyPost { get; set; }
            public List<ForumComment> Comments { get; set; } = new List<ForumComment>();
        }

        public class ForumComment
        {
            public string CommentID { get; set; }
            public string AuthorUserID { get; set; }
            public string AuthorName { get; set; }
            public string AuthorAvatar { get; set; }
            public bool AuthorIsTeacher { get; set; }
            public string Content { get; set; }
            public string TimeAgo { get; set; }
        }

        // ViewState
        private string ActiveCategory
        {
            get => (ViewState["Cat"] as string) ?? "All";
            set => ViewState["Cat"] = value;
        }
        private int CurrentPage
        {
            get => ViewState["Page"] == null ? 1 : (int)ViewState["Page"];
            set => ViewState["Page"] = value;
        }
        private const int PageSize = 5;

        private HashSet<string> ExpandedPosts
        {
            get
            {
                var s = ViewState["Expanded"] as string ?? "";
                return new HashSet<string>(
                    s.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries));
            }
            set => ViewState["Expanded"] = string.Join(",", value);
        }

        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            // MODIFIED: guests may view the forum (read-only).
            // Only non-guest unauthenticated users go to Login.
            if (!IsGuest && string.IsNullOrWhiteSpace(UserId))
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindCategoryControls();
                LoadPosts();
            }
        }

        // Populate category dropdown + sidebar category buttons
        private void BindCategoryControls()
        {
            var sbOpt = new System.Text.StringBuilder();
            var sbSide = new System.Text.StringBuilder();

            try
            {
                const string sql = @"
                    SELECT ISNULL(category, 'Forum Discussion') AS cat,
                           COUNT(*) AS cnt
                    FROM dbo.forumPostingTable
                    WHERE isDeleted = 0 AND category IS NOT NULL
                    GROUP BY ISNULL(category, 'Forum Discussion')
                    ORDER BY cat";

                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string cat = r["cat"].ToString();
                            int cnt = System.Convert.ToInt32(r["cnt"]);
                            string enc = HttpUtility.HtmlEncode(cat);
                            string val = enc.ToLower();

                            sbOpt.AppendFormat("<option value=\"{0}\">{1}</option>", val, enc);

                            sbSide.AppendFormat(@"
                                <button type=""button"" data-cat=""{0}"" onclick=""sidebarSetCat(this,'{0}')""
                                        class=""cat-btn w-full flex items-center justify-between px-4 py-3 rounded-2xl
                                               text-sm font-black text-gray-500 border border-transparent
                                               hover:bg-blue-50 hover:text-math-dark-blue transition-colors group"">
                                    <span>{1}</span>
                                    <div class=""flex items-center gap-1"">
                                        <span class=""text-[10px] font-black text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full"">{2}</span>
                                        <span class=""material-symbols-outlined text-base text-gray-300 group-hover:text-math-blue"">chevron_right</span>
                                    </div>
                                </button>",
                                val, enc, cnt);
                        }
                    }
                }
            }
            catch { }

            litCategoryOptions.Text = sbOpt.ToString();
            litSidebarCategories.Text = sbSide.ToString();
        }

        protected string GetTotalForumPostCount()
        {
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.forumPostingTable WHERE isDeleted = 0", con))
                {
                    con.Open();
                    return System.Convert.ToString(cmd.ExecuteScalar() ?? 0);
                }
            }
            catch
            {
                return "0";
            }
        }

        // -
        private void LoadPosts()
        {
            var expanded = ExpandedPosts;
            var posts = GetPosts(ActiveCategory, CurrentPage, PageSize, out int total);

            foreach (var p in posts)
            {
                p.ShowComments = expanded.Contains(p.PostID);
                if (p.ShowComments)
                    p.Comments = GetComments(p.PostID);
            }

            rptForum.DataSource = posts;
            rptForum.DataBind();

            btnLoadMore.Visible = (CurrentPage * PageSize) < total;
            btnShowLess.Visible = CurrentPage > 1;

        }

        // DB: posts
        private List<ForumPost> GetPosts(string category, int page, int size, out int total)
        {
            total = 0;
            var list = new List<ForumPost>();

            const string countSql = @"
                SELECT COUNT(*) FROM dbo.forumPostingTable
                WHERE  isDeleted = 0
                  AND  (@cat = 'All' OR ISNULL(category,'Forum Discussion') = @cat)";

            const string sql = @"
                SELECT
                    p.postID, p.authorUserID, p.title, p.content,
                    ISNULL(p.category,'Forum Discussion') AS category,
                    p.isTopSolution, p.isFlagged, p.createdAt,
                    u.fullName,
                    ISNULL(u.AvatarUrl,'') AS AvatarUrl,
                    CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.userRoleTable ur
                        JOIN   dbo.Role r ON r.roleID = ur.roleID
                        WHERE  ur.userID = p.authorUserID
                          AND  r.roleName IN ('Teacher','Admin')
                    ) THEN 1 ELSE 0 END                                        AS IsTeacher,
                    ISNULL((SELECT COUNT(*) FROM dbo.forumLikeTable l
                            WHERE l.postID = p.postID), 0)                     AS LikeCount,
                    CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.forumLikeTable l
                        WHERE l.postID = p.postID AND l.userID = @uid
                    ) THEN 1 ELSE 0 END                                        AS IsLikedByMe,
                    ISNULL((SELECT COUNT(*) FROM dbo.forumCommentTable c
                            WHERE c.postID = p.postID AND c.isDeleted = 0), 0) AS CommentCount
                FROM  dbo.forumPostingTable p
                JOIN  dbo.userTable         u ON u.userID = p.authorUserID
                WHERE p.isDeleted = 0
                  AND (@cat = 'All' OR ISNULL(p.category,'Forum Discussion') = @cat)
                ORDER BY p.isTopSolution DESC, p.createdAt DESC
                OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY";

            // guests have no UserID — use empty string so the SQL param is valid
            string effectiveUid = string.IsNullOrWhiteSpace(UserId) ? "" : UserId;

            try
            {
                using (var con = new SqlConnection(CS))
                {
                    con.Open();
                    using (var cmd = new SqlCommand(countSql, con))
                    {
                        cmd.Parameters.AddWithValue("@cat", category);
                        total = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                    using (var cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@uid", effectiveUid);
                        cmd.Parameters.AddWithValue("@cat", category);
                        cmd.Parameters.AddWithValue("@skip", 0);                    // always start from 0
                        cmd.Parameters.AddWithValue("@take", CurrentPage * size);   // show accumulated total

                        using (var dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                string rawContent = dr["content"].ToString();
                                SplitContent(rawContent, out string text, out string imgUrl);

                                list.Add(new ForumPost
                                {
                                    PostID = dr["postID"].ToString(),
                                    AuthorUserID = dr["authorUserID"].ToString(),
                                    AuthorName = dr["fullName"].ToString(),
                                    AuthorAvatar = dr["AvatarUrl"].ToString(),
                                    AuthorIsTeacher = Convert.ToInt32(dr["IsTeacher"]) == 1,
                                    Title = HttpUtility.HtmlEncode(dr["title"].ToString()),
                                    Content = HttpUtility.HtmlEncode(text),
                                    ImageUrl = imgUrl,
                                    Category = dr["category"].ToString(),
                                    IsTopSolution = Convert.ToInt32(dr["isTopSolution"]) == 1,
                                    IsFlagged = Convert.ToInt32(dr["isFlagged"]) == 1,
                                    TimeAgo = TimeAgoText(Convert.ToDateTime(dr["createdAt"])),
                                    LikeCount = Convert.ToInt32(dr["LikeCount"]),
                                    IsLikedByMe = Convert.ToInt32(dr["IsLikedByMe"]) == 1,
                                    CommentCount = Convert.ToInt32(dr["CommentCount"]),
                                    IsMyPost = dr["authorUserID"].ToString() == UserId
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Forum.GetPosts] " + ex.Message);
            }
            return list;
        }

        // DB: comments
        private List<ForumComment> GetComments(string postId)
        {
            var list = new List<ForumComment>();
            const string sql = @"
                SELECT
                    c.commentID, c.authorUserID, c.content, c.createdAt,
                    u.fullName,
                    ISNULL(u.AvatarUrl,'') AS AvatarUrl,
                    CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.userRoleTable ur
                        JOIN   dbo.Role r ON r.roleID = ur.roleID
                        WHERE  ur.userID = c.authorUserID
                          AND  r.roleName IN ('Teacher','Admin')
                    ) THEN 1 ELSE 0 END AS IsTeacher
                FROM  dbo.forumCommentTable c
                JOIN  dbo.userTable         u ON u.userID = c.authorUserID
                WHERE c.postID = @pid AND c.isDeleted = 0
                ORDER BY c.createdAt ASC";

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@pid", postId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            list.Add(new ForumComment
                            {
                                CommentID = dr["commentID"].ToString(),
                                AuthorUserID = dr["authorUserID"].ToString(),
                                AuthorName = dr["fullName"].ToString(),
                                AuthorAvatar = dr["AvatarUrl"].ToString(),
                                AuthorIsTeacher = Convert.ToInt32(dr["IsTeacher"]) == 1,
                                Content = HttpUtility.HtmlEncode(dr["content"].ToString()),
                                TimeAgo = TimeAgoText(Convert.ToDateTime(dr["createdAt"]))
                            });
                        }
                    }
                }
            }
            catch { }
            return list;
        }

        // Item commands
        protected void rptForum_ItemCommand(object src, RepeaterCommandEventArgs e)
        {
            string postId = e.CommandArgument?.ToString();
            if (string.IsNullOrWhiteSpace(postId)) return;

            switch (e.CommandName)
            {
                case "ToggleLike":
                    // ADDED: guests cannot like posts
                    if (IsGuest) { GuestAlert("like posts"); return; }
                    ToggleLike(postId);
                    break;

                case "ToggleComments":
                    // Reading/expanding comments is allowed for guests — no guard
                    var exp = ExpandedPosts;
                    if (exp.Contains(postId)) exp.Remove(postId);
                    else exp.Add(postId);
                    ExpandedPosts = exp;
                    break;

                case "SubmitComment":
                    // ADDED: guests cannot post comments
                    if (IsGuest) { GuestAlert("post comments"); return; }
                    var tb = e.Item.FindControl("txtComment") as TextBox;
                    string t = tb?.Text?.Trim() ?? "";
                    if (!string.IsNullOrEmpty(t))
                    {
                        InsertComment(postId, t);
                        var exp2 = ExpandedPosts;
                        exp2.Add(postId);
                        ExpandedPosts = exp2;
                    }
                    break;
            }
            LoadPosts();
        }

        // fires a JS alert using the existing page — no new UI needed
        private void GuestAlert(string action)
        {
            // Store the message to display in the modal, then show it via JS
            ScriptManager.RegisterStartupScript(
                this, GetType(), "guestBlock",
                $"showGuestModal('{HttpUtility.JavaScriptStringEncode(action)}');", true);
        }

        private void ToggleLike(string postId)
        {
            const string check = "SELECT COUNT(*) FROM dbo.forumLikeTable WHERE postID=@pid AND userID=@uid";
            const string del = "DELETE FROM dbo.forumLikeTable WHERE postID=@pid AND userID=@uid";
            const string ins = @"
                DECLARE @n int;
                SELECT @n = ISNULL(MAX(TRY_CAST(SUBSTRING(LTRIM(RTRIM(likeID)),2,LEN(likeID)) AS int)),0)+1
                FROM   dbo.forumLikeTable WHERE likeID LIKE 'L[0-9]%';
                INSERT INTO dbo.forumLikeTable (likeID,postID,userID,createdAt)
                VALUES('L'+RIGHT('000000000'+CAST(@n AS nvarchar(9)),9),@pid,@uid,SYSUTCDATETIME())";

            try
            {
                using (var con = new SqlConnection(CS))
                {
                    con.Open();
                    int exists;
                    using (var cmd = new SqlCommand(check, con))
                    {
                        cmd.Parameters.AddWithValue("@pid", postId);
                        cmd.Parameters.AddWithValue("@uid", UserId);
                        exists = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                    using (var cmd = new SqlCommand(exists > 0 ? del : ins, con))
                    {
                        cmd.Parameters.AddWithValue("@pid", postId);
                        cmd.Parameters.AddWithValue("@uid", UserId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }
        }

        private void InsertComment(string postId, string text)
        {
            const string sql = @"
                DECLARE @n int;
                SELECT @n = ISNULL(MAX(TRY_CAST(SUBSTRING(LTRIM(RTRIM(commentID)),3,LEN(commentID)) AS int)),0)+1
                FROM   dbo.forumCommentTable WHERE commentID LIKE 'CM[0-9]%';
                INSERT INTO dbo.forumCommentTable
                    (commentID,postID,authorUserID,content,isDeleted,createdAt)
                VALUES('CM'+RIGHT('00000000'+CAST(@n AS nvarchar(8)),8),
                       @pid,@uid,@txt,0,SYSUTCDATETIME())";

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@pid", postId);
                    cmd.Parameters.AddWithValue("@uid", UserId);
                    cmd.Parameters.AddWithValue("@txt", text);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private void SoftDeletePost(string postId)
        {
            const string sql = @"
                UPDATE dbo.forumPostingTable
                SET    isDeleted = 1, updatedAt = SYSUTCDATETIME()
                WHERE  postID = @pid AND authorUserID = @uid";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@pid", postId);
                    cmd.Parameters.AddWithValue("@uid", UserId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        // Pagination / navigation
        protected void btnLoadMore_Click(object s, EventArgs e)
        {
            CurrentPage++;
            LoadPosts();
        }

        protected void btnShowLess_Click(object s, EventArgs e)
        {
            if (CurrentPage > 1) CurrentPage--;
            LoadPosts();
        }

        protected void btnStartDiscussion_Click(object s, EventArgs e)
        {
            // guests cannot start discussions
            if (IsGuest) { GuestAlert("start a discussion"); return; }
            Response.Redirect("~/PostForum.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnDeleteConfirmed_Click(object sender, EventArgs e)
        {
            if (IsGuest) return;  // guests have nothing to delete
            string postId = hfDeletePostId.Value?.Trim();
            if (!string.IsNullOrEmpty(postId))
            {
                SoftDeletePost(postId);
                if (CurrentPage > 1) CurrentPage--;
            }
            LoadPosts();
        }

        // Helpers
        private static void SplitContent(string raw, out string text, out string imageUrl)
        {
            const string delim = "##IMG##";
            int idx = raw.IndexOf(delim, StringComparison.Ordinal);
            if (idx >= 0)
            {
                text = raw.Substring(0, idx).Trim();
                imageUrl = raw.Substring(idx + delim.Length).Trim();
            }
            else { text = raw; imageUrl = null; }
        }

        protected string ResolveAvatar(string url)
        {
            if (string.IsNullOrWhiteSpace(url))
                return ResolveUrl("~/Image/default-avatar.png");
            if (url.StartsWith("http", StringComparison.OrdinalIgnoreCase)) return url;
            return ResolveUrl("~/" + url.TrimStart('~', '/'));
        }

        protected string ResolvePostImage(string imgUrl)
        {
            if (string.IsNullOrWhiteSpace(imgUrl)) return "";
            if (imgUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase)) return imgUrl;
            return ResolveUrl("~/" + imgUrl.TrimStart('~', '/'));
        }

        private static string TimeAgoText(DateTime dt)
        {
            var utc = dt.Kind == DateTimeKind.Utc
                ? dt
                : DateTime.SpecifyKind(dt, DateTimeKind.Utc);

            var span = DateTime.UtcNow - utc;
            if (span.TotalMinutes < 1) return "just now";
            if (span.TotalMinutes < 60) return $"{(int)span.TotalMinutes} mins ago";
            if (span.TotalHours < 24) return $"{(int)span.TotalHours} hours ago";
            if (span.TotalDays < 7) return $"{(int)span.TotalDays} days ago";
            return utc.ToString("MMM d, yyyy");
        }
    }
}

