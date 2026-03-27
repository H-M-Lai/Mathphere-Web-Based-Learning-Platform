using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;

namespace MathSphere
{
    public partial class forumModeration : System.Web.UI.Page
    {
        private string CS =>
            System.Configuration.ConfigurationManager
                  .ConnectionStrings["MathSphereDB"].ConnectionString;

        // Picked up by the inline toast script — same pattern as systemSetting.aspx.cs
        protected string toastFlag = "0";
        protected string toastMessage = "";

        // -
        //  Page Load
        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindPendingFlags();
                RefreshPendingLabel();
                LoadStats();
            }
        }

        // -
        //  Bind flagged posts
        //
        //  Tables used (exact columns from DB schema):
        //  + ForumFlag         : flagID, postID, userID, reason, createdAt, status
        //  + forumPostingTable : postID, authorUserID, title, content, status,
        //  ¦                     isDeleted, createdAt, updatedAt, category,
        //  ¦                     isTopSolution, isFlagged
        //  + userTable (author): userID, fullName, AvatarUrl
        //  + userTable (flagger): userID, fullName  (for "Flagged by:" label)
        //  + ForumModerationAction : for warn history per author
        //
        //  Extra columns added for Warn modal footer:
        //    LastWarnText — date of last WARNED action for this author (or '')
        //    WarnCount    — total WARNED actions for this author
        // -
        private void BindPendingFlags()
        {
            const string sql = @"
        SELECT
            f.flagID,
            f.postID,
            f.reason AS FlagReason,
            f.createdAt AS FlaggedAt,
            p.title AS PostTitle,

            CASE
                WHEN CHARINDEX('##IMG##', p.content) > 0
                    THEN LEFT(p.content, CHARINDEX('##IMG##', p.content) - 1)
                ELSE p.content
            END AS PostContent,

            CASE
                WHEN CHARINDEX('##IMG##', p.content) > 0
                    THEN SUBSTRING(
                        p.content,
                        CHARINDEX('##IMG##', p.content) + 7,
                        LEN(p.content)
                    )
                ELSE ''
            END AS PostImageUrl,

            p.authorUserID,
            p.category,

            u.fullName AS StudentName,
            ISNULL(u.AvatarUrl,
                'https://ui-avatars.com/api/?name='
                + REPLACE(u.fullName, ' ', '+')
                + '&background=2563eb&color=fff') AS StudentAvatar,

            ISNULL(uf.fullName, f.userID) AS FlaggedByName,

            CASE
                WHEN DATEDIFF(MINUTE, f.createdAt, GETUTCDATE()) < 1
                    THEN 'Just now'
                WHEN DATEDIFF(MINUTE, f.createdAt, GETUTCDATE()) < 60
                    THEN CAST(DATEDIFF(MINUTE, f.createdAt, GETUTCDATE()) AS NVARCHAR(20)) + 'm ago'
                WHEN DATEDIFF(HOUR, f.createdAt, GETUTCDATE()) < 24
                    THEN CAST(DATEDIFF(HOUR, f.createdAt, GETUTCDATE()) AS NVARCHAR(20)) + 'h ago'
                ELSE CAST(DATEDIFF(DAY, f.createdAt, GETUTCDATE()) AS NVARCHAR(20)) + 'd ago'
            END AS TimeAgo,

            ISNULL(
                (
                    SELECT TOP 1 CONVERT(NVARCHAR(50), ma.createdAt, 107)
                    FROM dbo.ForumModerationAction ma
                    JOIN dbo.forumPostingTable pp
                        ON pp.postID = ma.postID
                       AND pp.authorUserID = p.authorUserID
                    WHERE ma.actionType = 'WARNED'
                    ORDER BY ma.createdAt DESC
                ),
                ''
            ) AS LastWarnText,

            ISNULL(
                (
                    SELECT COUNT(*)
                    FROM dbo.ForumModerationAction ma
                    JOIN dbo.forumPostingTable pp
                        ON pp.postID = ma.postID
                       AND pp.authorUserID = p.authorUserID
                    WHERE ma.actionType = 'WARNED'
                ),
                0
            ) AS WarnCount

        FROM dbo.ForumFlag f
        JOIN dbo.forumPostingTable p ON p.postID = f.postID
        JOIN dbo.userTable u ON u.userID = p.authorUserID
        LEFT JOIN dbo.userTable uf ON uf.userID = f.userID
        WHERE f.status = 'Open'
          AND p.isDeleted = 0
        ORDER BY f.createdAt DESC";

            using (var con = new SqlConnection(CS))
            using (var da = new SqlDataAdapter(sql, con))
            {
                var dt = new DataTable();
                da.Fill(dt);
                rptFlaggedPosts.DataSource = dt;
                rptFlaggedPosts.DataBind();
            }
        }

        // -
        //  Keep Post — ItemCommand handler
        // -
        protected void rptFlaggedPosts_ItemCommand(object source,
            System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (!string.Equals(e.CommandName, "KEEP", StringComparison.OrdinalIgnoreCase))
                return;

            string flagId = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(flagId)) return;

            var info = GetFlagInfo(flagId);
            if (info == null) { FireToast("Flag not found."); return; }

            using (var con = new SqlConnection(CS))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                {
                    try
                    {
                        // Dismiss flag
                        Exec(con, tx, @"
                            UPDATE dbo.ForumFlag
                            SET    status = 'Dismissed'
                            WHERE  flagID = @flagID",
                            P("@flagID", flagId));

                        // Restore post to Published
                        Exec(con, tx, @"
                            UPDATE dbo.forumPostingTable
                            SET    status    = 'Published',
                                   isFlagged = 0,
                                   updatedAt = SYSUTCDATETIME()
                            WHERE  postID    = @postID",
                            P("@postID", info.PostId));

                        LogAction(info.PostId, "KEPT",
                            "Flag dismissed — post kept by admin.", con, tx);

                        tx.Commit();
                    }
                    catch { tx.Rollback(); throw; }
                }
            }

            BindPendingFlags();
            RefreshPendingLabel();
            LoadStats();
            FireToast("Post kept — flag dismissed.");
        }

        // -
        //  Delete Post
        // -
        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string flagId = hfFlagId.Value?.Trim();
            string reason = ddlDeleteReason.SelectedValue ?? "";
            if (string.IsNullOrEmpty(flagId)) return;

            var info = GetFlagInfo(flagId);
            if (info == null) { FireToast("Flag not found."); return; }

            using (var con = new SqlConnection(CS))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                {
                    try
                    {
                        // Soft-delete the post
                        Exec(con, tx, @"
                            UPDATE dbo.forumPostingTable
                            SET    isDeleted = 1,
                                   status    = 'Hidden',
                                   updatedAt = SYSUTCDATETIME()
                            WHERE  postID    = @postID",
                            P("@postID", info.PostId));

                        // Mark flag Reviewed
                        Exec(con, tx, @"
                            UPDATE dbo.ForumFlag
                            SET    status = 'Reviewed'
                            WHERE  flagID = @flagID",
                            P("@flagID", flagId));

                        LogAction(info.PostId, "DELETED",
                            "DeleteReason: " + reason, con, tx);

                        tx.Commit();
                    }
                    catch { tx.Rollback(); throw; }
                }
            }

            BindPendingFlags();
            RefreshPendingLabel();
            LoadStats();

            toastFlag = "1";
            toastMessage = "Post deleted successfully.";
            Page.ClientScript.RegisterStartupScript(GetType(), "closeDel", "closeDel();", true);
        }

        // -
        //  Send Warning
        // -
        protected void btnSendWarning_Click(object sender, EventArgs e)
        {
            string flagId = hfFlagId.Value?.Trim();
            string warnType = hfWarnType.Value ?? "Major";
            string reason = ddlWarnReason.SelectedValue ?? "";
            string message = (txtWarnMsg.Text ?? "").Trim();
            if (string.IsNullOrEmpty(flagId)) return;

            var info = GetFlagInfo(flagId);
            if (info == null) { FireToast("Flag not found."); return; }

            using (var con = new SqlConnection(CS))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                {
                    try
                    {
                        // -- Option B: flag stays OPEN, post stays visible
                        //    but isFlagged=1 so forum can show a warning banner --
                        Exec(con, tx, @"
                    UPDATE dbo.forumPostingTable
                    SET    isFlagged = 1,
                           updatedAt = SYSUTCDATETIME()
                    WHERE  postID    = @postID",
                            P("@postID", info.PostId));

                        // Log warning action
                        string notes = $"WarnType={warnType}, Reason={reason}" +
                                       (string.IsNullOrWhiteSpace(message) ? "" : $", Msg={message}");
                        LogAction(info.PostId, "WARNED", notes, con, tx);

                        // In-app notification to post author
                        InsertNotification(info.AuthorUserId,
                            $"{warnType} Warning Issued",
                            $"Your post received a {warnType} warning: {reason}",
                            con, tx);

                        tx.Commit();
                    }
                    catch { tx.Rollback(); throw; }
                }
            }

            // Send warning email to post author
            try
            {
                string postTitle = GetPostTitle(info.PostId);
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(
                    "SELECT email, fullName FROM dbo.userTable WHERE userID = @uid", con))
                {
                    cmd.Parameters.AddWithValue("@uid", info.AuthorUserId);
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                        if (r.Read())
                            EmailService.SendForumWarning(
                                r["email"].ToString(),
                                r["fullName"].ToString(),
                                postTitle, warnType, reason, message);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[ForumWarning Email] " + ex.Message);
            }

            txtWarnMsg.Text = "";
            BindPendingFlags();
            RefreshPendingLabel();
            LoadStats();

            toastFlag = "1";
            toastMessage = "Warning sent. Post remains under review.";
            Page.ClientScript.RegisterStartupScript(GetType(), "closeWarn", "closeWarn();", true);
        }

        // -
        //  Insert notification to student (notificationTable)
        //  Columns: notificationID nvarchar(10), userID nvarchar(10),
        //           title nvarchar(120), message nvarchar(500),
        //           type nvarchar(30), linkUrl nvarchar(400),
        //           isRead bit, createdAt datetime2
        // -
        private void InsertNotification(string userId, string title,
                                         string message, SqlConnection con,
                                         SqlTransaction tx)
        {
            if (string.IsNullOrEmpty(userId)) return;

            string nid = GenerateId("NT", "notificationTable", "notificationID", con, tx);

            using (var cmd = new SqlCommand(@"
                INSERT INTO dbo.notificationTable
                    (notificationID, userID, title, message, type, isRead, createdAt)
                VALUES
                    (@nid, @uid, @title, @msg, 'Warning', 0, SYSUTCDATETIME())",
                con, tx))
            {
                cmd.Parameters.AddWithValue("@nid", nid);
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@title", title);
                cmd.Parameters.AddWithValue("@msg", message);
                cmd.ExecuteNonQuery();
            }
        }

        // -
        //  Load live stats into the three stat cards — from real DB
        //
        //  litOpenFlags    ? ForumFlag WHERE status='Open'
        //  litResolvedToday ? ForumModerationAction WHERE DATE(createdAt)=TODAY
        //  litTotalActions  ? ForumModerationAction total rows
        // -
        private void LoadStats()
        {
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(@"
                    SELECT
                        (SELECT COUNT(*) FROM dbo.ForumFlag
                         WHERE  status = 'Open')                                AS OpenFlags,

                        (SELECT COUNT(*) FROM dbo.ForumModerationAction
                         WHERE  CAST(createdAt AS DATE) = CAST(SYSUTCDATETIME() AS DATE))
                                                                                AS ResolvedToday,

                        (SELECT COUNT(*) FROM dbo.ForumModerationAction)       AS TotalActions;",
                    con))
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) return;
                        litOpenFlags.Text = r["OpenFlags"].ToString();
                        litResolvedToday.Text = r["ResolvedToday"].ToString();
                        litTotalActions.Text = r["TotalActions"].ToString();
                    }
                }
            }
            catch { /* keep defaults */ }
        }

        // -
        //  Refresh pending reports label in page header
        // -
        private void RefreshPendingLabel()
        {
            try
            {
                int pending;
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.ForumFlag WHERE status = 'Open';", con))
                {
                    con.Open();
                    pending = Convert.ToInt32(cmd.ExecuteScalar(), CultureInfo.InvariantCulture);
                }

                litPendingReports.Text = string.Format(
                    "<span class='font-bold text-math-dark-blue'>{0} Pending Report{1}</span>",
                    pending, pending == 1 ? "" : "s");
            }
            catch
            {
                litPendingReports.Text = "<span class='font-bold text-math-dark-blue'>— Pending Reports</span>";
            }
        }

        // -
        //  Log action to ForumModerationAction
        //  Columns: actionID nvarchar(10), postID nvarchar(10),
        //           moderatorID nvarchar(10), actionType nvarchar(30),
        //           notes nvarchar(500), createdAt datetime2
        // -
        private void LogAction(string postId, string actionType,
                                string notes, SqlConnection con,
                                SqlTransaction tx)
        {
            string actionId = GenerateId("MA", "ForumModerationAction", "actionID", con, tx);
            string moderatorId = Session["UserID"]?.ToString() ?? "";

            using (var cmd = new SqlCommand(@"
                INSERT INTO dbo.ForumModerationAction
                    (actionID, postID, moderatorID, actionType, notes)
                VALUES
                    (@actionID, @postID, @modID, @actionType, @notes)",
                con, tx))
            {
                cmd.Parameters.AddWithValue("@actionID", actionId);
                cmd.Parameters.AddWithValue("@postID", postId);
                cmd.Parameters.AddWithValue("@modID", moderatorId);
                cmd.Parameters.AddWithValue("@actionType", actionType);
                cmd.Parameters.AddWithValue("@notes",
                    string.IsNullOrEmpty(notes) ? (object)DBNull.Value : notes);
                cmd.ExecuteNonQuery();
            }
        }

        // -
        //  GetFlagInfo — load flagID, postID, authorUserID from DB
        // -
        private FlagInfo GetFlagInfo(string flagId)
        {
            const string sql = @"
                SELECT f.flagID, f.postID, p.authorUserID
                FROM   dbo.ForumFlag         f
                JOIN   dbo.forumPostingTable  p ON p.postID = f.postID
                WHERE  f.flagID = @fid";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@fid", flagId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return null;
                    return new FlagInfo
                    {
                        FlagId = r["flagID"].ToString(),
                        PostId = r["postID"].ToString(),
                        AuthorUserId = r["authorUserID"].ToString()
                    };
                }
            }
        }

        // -
        //  ID generator  prefix + D3 number  e.g. MA001, NT001
        //  Works for any nvarchar(10) PK
        // -
        private string GenerateId(string prefix, string tableName,
                                   string idColumn,
                                   SqlConnection con, SqlTransaction tx)
        {
            string sql = $@"
                SELECT ISNULL(MAX(CAST(SUBSTRING({idColumn}, {prefix.Length + 1},
                       LEN({idColumn})) AS INT)), 0) + 1
                FROM   dbo.[{tableName}]
                WHERE  {idColumn} LIKE '{prefix}[0-9]%'";

            using (var cmd = new SqlCommand(sql, con, tx))
                return prefix + ((int)cmd.ExecuteScalar()).ToString("D3");
        }

        // -
        //  Helpers
        // -
        private string GetPostTitle(string postId)
        {
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(
                    "SELECT title FROM dbo.forumPostingTable WHERE postID = @pid", con))
                {
                    cmd.Parameters.AddWithValue("@pid", postId);
                    con.Open();
                    return cmd.ExecuteScalar()?.ToString() ?? "Your Post";
                }
            }
            catch { return "Your Post"; }
        }

        // Used by FooterTemplate to decide whether to show empty state
        protected bool rptFlaggedPosts_IsEmpty() =>
            rptFlaggedPosts.Items.Count == 0;

        // Fire toast via toastFlag pattern (shows on next render)
        private void FireToast(string msg)
        {
            toastFlag = "1";
            toastMessage = msg;
        }

        // Shorthand for parameterless ExecuteNonQuery
        private void Exec(SqlConnection con, SqlTransaction tx,
                                  string sql, params SqlParameter[] parms)
        {
            using (var cmd = new SqlCommand(sql, con, tx))
            {
                foreach (var p in parms) cmd.Parameters.Add(p);
                cmd.ExecuteNonQuery();
            }
        }

        // Shorthand SqlParameter factory
        private SqlParameter P(string name, object value) =>
            new SqlParameter(name, value ?? DBNull.Value);

        private sealed class FlagInfo
        {
            public string FlagId { get; set; }
            public string PostId { get; set; }
            public string AuthorUserId { get; set; }
        }
    }
}

