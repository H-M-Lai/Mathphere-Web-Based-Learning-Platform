using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Services;

namespace MathSphere
{
    [ScriptService]
    public partial class adminDashboard : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            { Response.Redirect("~/Login.aspx", true); return; }
            if (Session["IsAdmin"] == null || !(bool)Session["IsAdmin"])
            { Response.Redirect("~/Login.aspx", true); return; }
            if (!IsPostBack)
                LoadDashboardData();
        }

        private void LoadDashboardData()
        {
            if (Session["AdminEmail"] != null)
            {
                var litAdminUsername = (System.Web.UI.WebControls.Literal)Master.FindControl("litAdminUsername");
                if (litAdminUsername != null)
                    litAdminUsername.Text = Session["AdminEmail"].ToString().Split('@')[0];
            }
            LoadStatsCards();
            LoadRoleDistribution();
            LoadActivityLog();
            LoadAlertBadge();
        }

        // Alert badge
        // adminAlertTable has NO 'category' column — count ALL unresolved alerts.
        private void LoadAlertBadge()
        {
            int total = 0;
            bool hasHigh = false;
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
            SELECT 
                (SELECT COUNT(*) FROM dbo.adminAlertTable WHERE alertStatus <> 'Resolved')
                +
                (SELECT COUNT(*) FROM dbo.ForumFlag ff WHERE ff.status = 'Open'
                 AND NOT EXISTS (
                     SELECT 1 FROM dbo.adminAlertTable a
                     WHERE  a.alertType   = 'Forum'
                       AND  a.alertStatus <> 'Resolved'
                       AND  a.description LIKE '%' + ff.postID + '%'
                 ))", con))
                    total = (int)cmd.ExecuteScalar();

                hasHigh = total >= 5;
            }
            catch { }

            if (total == 0) return;
            string colour = hasHigh ? "bg-red-500" : "bg-primary";
            string pulse = hasHigh ? " animate-pulse" : "";
            litAlertBadge.Visible = true;
            litAlertBadge.Text =
                $"<span class='absolute -top-1 -right-1 size-5 {colour} text-white text-[10px] font-black rounded-full flex items-center justify-center{pulse}'>" +
                (total > 9 ? "9+" : total.ToString()) + "</span>";
        }

        private static string HtmlEncode(string s) => System.Web.HttpUtility.HtmlEncode(s ?? "");

        private void LoadStatsCards() { rptStatsCards.DataSource = GetStatsCardsData(); rptStatsCards.DataBind(); }
        private void LoadRoleDistribution() { rptRoleDistribution.DataSource = GetRoleDistributionData(); rptRoleDistribution.DataBind(); }
        private void LoadActivityLog() { rptActivityLog.DataSource = GetActivityLogData(5); rptActivityLog.DataBind(); }

        // Repeater renderers
        protected void rptStatsCards_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
            StatsCard c = (StatsCard)e.Item.DataItem;
                        ((Literal)e.Item.FindControl("litStatsCard")).Text = $@"
                <div class='flex items-center justify-between gap-5 rounded-[2rem] border border-white/70 bg-white/90 p-8
                     shadow-[0_18px_40px_rgba(30,58,138,0.08)] group hover:-translate-y-1 transition-transform'>
                    <div>
                        <div class='mb-2 text-[11px] font-black uppercase tracking-[0.24em] text-gray-400'>{c.Title}</div>
                        <div class='text-4xl font-black text-math-dark-blue'>{c.Value}</div>
                        <div class='mt-3 inline-flex items-center gap-2 rounded-full border border-white/70 bg-{c.IconBgColor} px-3 py-1.5 text-[11px] font-black uppercase text-{c.SubtitleColor}'>
                            <span class='material-symbols-outlined text-sm'>{c.Icon}</span> {c.Subtitle}
                        </div>
                    </div>
                    <div class='flex size-20 items-center justify-center rounded-[1.75rem] border border-white/70 bg-{c.IconBgColor}
                         text-{c.IconColor} group-hover:scale-105 transition-transform shadow-inner'>
                        <span class='material-symbols-outlined text-5xl fill-icon'>{c.MainIcon}</span>
                    </div>
                </div>";
        }

        protected void rptRoleDistribution_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
            RoleDistribution r = (RoleDistribution)e.Item.DataItem;
                        ((Literal)e.Item.FindControl("litRoleItem")).Text = $@"
                <div class='flex items-center justify-between rounded-2xl border border-white/70 bg-{r.BgColor} px-4 py-3 shadow-sm'>
                    <div class='flex items-center gap-3'>
                        <div class='size-3 rounded-full bg-{r.DotColor}'></div>
                        <span class='text-[11px] font-black uppercase tracking-[0.2em] text-math-dark-blue'>{HtmlEncode(r.RoleName)}</span>
                    </div>
                    <span class='text-sm font-black text-{r.TextColor}'>{r.Percentage}%</span>
                </div>";
        }

        protected void rptActivityLog_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
            ActivityLogItem a = (ActivityLogItem)e.Item.DataItem;

            string resolveBtn = "";
            if (!string.IsNullOrWhiteSpace(a.AlertId))
            {
                resolveBtn = $@"<button type='button' onclick=""resolveFromLog('{HtmlEncode(a.AlertId)}', this)""
            class='ml-2 px-2 py-1 bg-red-100 hover:bg-red-500 text-red-500 hover:text-white
            rounded-lg text-[10px] font-black uppercase transition-all border border-red-200
            hover:border-red-500 inline-flex items-center gap-1'>
            <span class='material-symbols-outlined text-xs'>check_circle</span> Resolve</button>";
            }

    ((Literal)e.Item.FindControl("litActivityRow")).Text = $@"
        <tr class='hover:bg-gray-50/50 transition-colors' id='logrow-{HtmlEncode(a.AlertId ?? "")}'>
            <td class='px-6 py-4'>
                <div class='flex items-center gap-3'>
                    <div class='size-8 bg-{a.IconBgColor} rounded-lg flex items-center justify-center text-{a.IconColor}'>
                        <span class='material-symbols-outlined text-sm'>{a.Icon}</span>
                    </div>
                    <span class='font-bold text-sm'>{HtmlEncode(a.EventType)}</span>
                </div>
            </td>
            <td class='px-6 py-4 font-medium text-sm text-gray-600'>{HtmlEncode(a.Description)}</td>
            <td class='px-6 py-4 text-sm font-bold text-gray-400 italic'>{a.Timestamp}</td>
            <td class='px-6 py-4'>
                <div class='flex items-center gap-2'>
                    <span class='px-3 py-1 bg-{a.StatusBgColor} text-{a.StatusTextColor} rounded-full text-[10px] font-black uppercase'>{HtmlEncode(a.Status)}</span>
                    {resolveBtn}
                </div>
            </td>
        </tr>";
        }

        protected void btnExportLogs_Click(object sender, EventArgs e)
        {
            try
            {
                var logs = GetActivityLogData(1000);
                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AddHeader("Content-Disposition", "attachment;filename=ActivityLog_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                var csv = new StringBuilder();
                csv.AppendLine("Event Type,Description,Timestamp,Status");
                foreach (var log in logs)
                    csv.AppendLine($"\"{log.EventType}\",\"{log.Description}\",\"{log.Timestamp}\",\"{log.Status}\"");
                Response.Write(csv.ToString());
                Response.End();
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine("Export error: " + ex.Message); }
        }

        // -
        //  CARD 1 — System Health  (live from ForumFlag)
        // -
        private StatsCard BuildSystemHealthCard()
        {
            int openFlags = 0, openSecurityAlerts = 0;
            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.ForumFlag WHERE status = 'Open';", con))
                        openFlags = (int)cmd.ExecuteScalar();

                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.adminAlertTable WHERE alertStatus = 'Open';", con))
                        openSecurityAlerts = (int)cmd.ExecuteScalar();
                }
            }
            catch { }

            int health = Math.Max(0, 100 - openFlags * 10 - openSecurityAlerts * 5);
            string trendIcon = health < 70 ? "trending_down" : "trending_up";
            string subtitle, borderColor, subtitleColor, iconBg, iconColor;

            if (health >= 95)
            {
                subtitle = "All systems clear";
                borderColor = subtitleColor = "math-green";
                iconBg = "green-100"; iconColor = "math-green";
            }
            else if (health >= 70)
            {
                int issues = openFlags + openSecurityAlerts;
                subtitle = $"{issues} open issue{(issues == 1 ? "" : "s")} detected";
                borderColor = subtitleColor = "primary";
                iconBg = "yellow-100"; iconColor = "primary";
            }
            else
            {
                int issues = openFlags + openSecurityAlerts;
                subtitle = $"{issues} issues — immediate review needed";
                borderColor = subtitleColor = "red-500";
                iconBg = "red-100"; iconColor = "red-500";
            }

            return new StatsCard
            {
                Title = "System Health",
                Value = health + "%",
                Subtitle = subtitle,
                Icon = trendIcon,
                MainIcon = "pulse_alert",
                BorderColor = borderColor,
                SubtitleColor = subtitleColor,
                IconBgColor = iconBg,
                IconColor = iconColor
            };
        }

        // -
        //  STATS CARDS
        //  IMPORTANT: adminAlertTable has NO 'category' column.
        //  All queries use alertType instead.
        // -
        private List<StatsCard> GetStatsCardsData()
        {
            var cards = new List<StatsCard>();
            cards.Add(BuildSystemHealthCard());

            int totalUsers = 0, newThisWeek = 0, openAlerts = 0;
            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.userTable WHERE accountStatus=1 AND ISNULL(isDeleted,0)=0;", con))
                        totalUsers = (int)cmd.ExecuteScalar();

                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.userTable WHERE accountStatus=1 AND ISNULL(isDeleted,0)=0 AND CreatedAt>=DATEADD(day,-7,SYSUTCDATETIME());", con))
                        newThisWeek = (int)cmd.ExecuteScalar();

                    // No 'category' column — count ALL unresolved alerts
                    using (var cmd = new SqlCommand(@"
                        SELECT 
                            (SELECT COUNT(*) FROM dbo.adminAlertTable WHERE alertStatus = 'Open')
                            +
                            (SELECT COUNT(*) FROM dbo.ForumFlag ff WHERE ff.status = 'Open'
                             AND NOT EXISTS (
                                 SELECT 1 FROM dbo.adminAlertTable a
                                 WHERE  a.alertType   = 'Forum'
                                   AND  a.alertStatus <> 'Resolved'
                                   AND  a.description LIKE '%' + ff.postID + '%'
                             ))", con))
                        openAlerts = (int)cmd.ExecuteScalar();
                }
            }
            catch { }

            cards.Add(new StatsCard
            {
                Title = "Total Users",
                Value = $"{totalUsers:N0} Users",
                Subtitle = newThisWeek > 0 ? $"+{newThisWeek} this week" : "No new users this week",
                Icon = "add_circle",
                MainIcon = "groups_3",
                BorderColor = "math-blue",
                SubtitleColor = "math-blue",
                IconBgColor = "blue-100",
                IconColor = "math-blue"
            });

            string alertBorder = openAlerts == 0 ? "math-green" : openAlerts <= 3 ? "primary" : "red-500";
            string alertIconBg = openAlerts == 0 ? "green-100" : openAlerts <= 3 ? "yellow-100" : "red-100";
            string alertIconColor = openAlerts == 0 ? "math-green" : openAlerts <= 3 ? "primary" : "red-500";
            cards.Add(new StatsCard
            {
                Title = "Security Alerts",
                Value = openAlerts.ToString(),
                Subtitle = openAlerts == 0 ? "No open alerts"
                         : openAlerts == 1 ? "1 alert needs review"
                         : $"{openAlerts} alerts need review",
                Icon = openAlerts == 0 ? "check_circle" : "warning",
                MainIcon = "shield_lock",
                BorderColor = alertBorder,
                SubtitleColor = alertBorder,
                IconBgColor = alertIconBg,
                IconColor = alertIconColor
            });

            return cards;
        }

        // -
        //  Role distribution
        // -
        private List<RoleDistribution> GetRoleDistributionData()
        {
            var roles = new List<RoleDistribution>();
            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT r.roleName,
                           CAST(COUNT(*)*100.0 / NULLIF(t.TotalActive,0) AS INT) AS Percentage
                    FROM       dbo.userRoleTable ur
                    JOIN       dbo.userTable u  ON u.userID = ur.userID
                    JOIN       dbo.Role r        ON r.roleID = ur.roleID
                    CROSS JOIN (SELECT COUNT(*) AS TotalActive FROM dbo.userTable
                                WHERE accountStatus=1 AND ISNULL(isDeleted,0)=0) t
                    WHERE u.accountStatus=1 AND ISNULL(u.isDeleted,0)=0
                    GROUP BY r.roleName, t.TotalActive
                    ORDER BY Percentage DESC;", conn))
                {
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                        while (reader.Read())
                        {
                            string roleName = reader["roleName"].ToString();
                            int pct = Convert.ToInt32(reader["Percentage"]);
                            string bg = "blue-50", dot = "math-blue", txt = "math-blue";
                            string rn = roleName.ToLower();
                            if (rn == "teacher" || rn == "teachers") { bg = "green-50"; dot = "math-green"; txt = "math-green"; }
                            else if (rn == "admin" || rn == "admins") { bg = "yellow-50"; dot = "primary"; txt = "primary"; }
                            else if (rn.Contains("moderator")) { bg = "purple-50"; dot = "purple-500"; txt = "purple-500"; }
                            roles.Add(new RoleDistribution { RoleName = roleName, Percentage = pct, BgColor = bg, DotColor = dot, TextColor = txt });
                        }
                }
            }
            catch { }
            return roles;
        }

        // -
        //  Activity log
        // -
        private List<ActivityLogItem> GetActivityLogData(int topN = 5)
        {
            var activities = new List<ActivityLogItem>();
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Pre-load all open Security alerts into a dict keyed by userID fragment
                    var openAlerts = new Dictionary<string, string>(); // userID ? alertID
                    using (var ac = new SqlCommand(@"
                SELECT alertID, description FROM dbo.adminAlertTable
                WHERE  alertType = 'Security' AND alertStatus = 'Open';", conn))
                    using (var ar = ac.ExecuteReader())
                        while (ar.Read())
                        {
                            string desc = ar["description"]?.ToString() ?? "";
                            string aId = ar["alertID"]?.ToString() ?? "";
                            // description format: "5 failed login attempts for Alice (U003) — alice@mail.com."
                            // extract the userID inside parentheses
                            int p1 = desc.IndexOf('('), p2 = desc.IndexOf(')');
                            if (p1 >= 0 && p2 > p1)
                            {
                                string uid = desc.Substring(p1 + 1, p2 - p1 - 1).Trim();
                                if (!string.IsNullOrWhiteSpace(uid))
                                    openAlerts[uid] = aId;
                            }
                        }

                    using (var cmd = new SqlCommand(
                        $"SELECT TOP {topN} EventType, Description, CreatedAt, Status, Priority " +
                        "FROM dbo.SysActivityLogTable " +
                        "WHERE EventType IS NOT NULL AND LTRIM(RTRIM(EventType)) <> '' " +
                        "ORDER BY CreatedAt DESC;", conn))
                    using (var reader = cmd.ExecuteReader())
                        while (reader.Read())
                        {
                            string eventType = reader["EventType"]?.ToString() ?? "";
                            string description = reader["Description"]?.ToString() ?? "";
                            string status = reader["Status"]?.ToString() ?? "";
                            string priority = reader["Priority"]?.ToString() ?? "";
                            if (string.IsNullOrWhiteSpace(eventType)) continue;

                            DateTime createdAt = reader["CreatedAt"] == DBNull.Value
                                ? DateTime.UtcNow : Convert.ToDateTime(reader["CreatedAt"]);

                            // Match alertId: description contains "(U003)" ? look up openAlerts["U003"]
                            string alertId = "";
                            string evLower = eventType.ToLower();
                            if (evLower.Contains("login") && evLower.Contains("fail"))
                            {
                                int p1 = description.IndexOf('('), p2 = description.IndexOf(')');
                                if (p1 >= 0 && p2 > p1)
                                {
                                    string uid = description.Substring(p1 + 1, p2 - p1 - 1).Trim();
                                    openAlerts.TryGetValue(uid, out alertId);
                                }
                            }

                            MapStatusColors(status, priority, out string statusBg, out string statusText);
                            MapEventIcon(eventType, priority, out string icon, out string iconBg, out string iconColor);

                            activities.Add(new ActivityLogItem
                            {
                                EventType = eventType,
                                Description = description,
                                Timestamp = ToLocalTimestamp(createdAt),
                                Status = string.IsNullOrWhiteSpace(status) ? "Info" : status,
                                Icon = icon,
                                IconBgColor = iconBg,
                                IconColor = iconColor,
                                StatusBgColor = statusBg,
                                StatusTextColor = statusText,
                                AlertId = alertId ?? ""
                            });
                        }
                }
            }
            catch { }
            return activities;
        }

        // -
        //  LogActivity — call from any page to write to SysActivityLogTable
        // -
        public static void LogActivity(string eventType, string description,
                                       string status = "Success", string priority = "Low")
        {
            try
            {
                string cs = ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;
                if (eventType != null && eventType.Length > 100) eventType = eventType.Substring(0, 100);
                if (description != null && description.Length > 100) description = description.Substring(0, 100);
                if (status != null && status.Length > 50) status = status.Substring(0, 50);
                if (priority != null && priority.Length > 50) priority = priority.Substring(0, 50);

                using (var con = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.SysActivityLogTable (EventType, Description, CreatedAt, Status, Priority)
                    VALUES (@evt, @desc, GETDATE(), @status, @priority);", con))
                {
                    cmd.Parameters.Add("@evt", SqlDbType.NVarChar, 100).Value = eventType ?? "";
                    cmd.Parameters.Add("@desc", SqlDbType.NVarChar, 100).Value = description ?? "";
                    cmd.Parameters.Add("@status", SqlDbType.NVarChar, 50).Value = status ?? "Success";
                    cmd.Parameters.Add("@priority", SqlDbType.NVarChar, 50).Value = priority ?? "Low";
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine("[LogActivity] " + ex.Message); }
        }

        // -
        //  ResolveAlert
        //  Uses alertType (not category — that column does not exist).
        // -
        [WebMethod]
        public static bool ResolveAlert(string alertId)
        {
            if (string.IsNullOrWhiteSpace(alertId)) return false;
            try
            {
                string cs = ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;
                string adminId = System.Web.HttpContext.Current?.Session?["UserID"]?.ToString() ?? "SYSTEM";

                if (alertId.StartsWith("FF:", StringComparison.OrdinalIgnoreCase))
                {
                    string flagId = alertId.Substring(3);
                    using (var con = new SqlConnection(cs))
                    using (var cmd = new SqlCommand(@"
                        UPDATE dbo.ForumFlag SET status = 'Reviewed'
                        WHERE  flagID = @fid AND status = 'Open';", con))
                    {
                        cmd.Parameters.AddWithValue("@fid", flagId);
                        con.Open();
                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                            LogActivity("Forum Flag Reviewed",
                                $"Flag {flagId} reviewed by {adminId}.", "OK", "Low");
                        return rows > 0;
                    }
                }

                using (var con = new SqlConnection(cs))
                {
                    con.Open();

                    string alertType = "", description = "";
                    using (var sel = new SqlCommand(
                        "SELECT alertType, description FROM dbo.adminAlertTable WHERE alertID=@id;", con))
                    {
                        sel.Parameters.AddWithValue("@id", alertId);
                        using (var r = sel.ExecuteReader())
                            if (r.Read())
                            {
                                alertType = r["alertType"]?.ToString() ?? "";
                                description = r["description"]?.ToString() ?? "";
                            }
                    }

                    int rows = 0;
                    using (var upd = new SqlCommand(@"
                        UPDATE dbo.adminAlertTable
                        SET    alertStatus = 'Resolved',
                               resolvedAt  = SYSUTCDATETIME(),
                               resolvedBy  = @admin
                        WHERE  alertID     = @id AND alertStatus <> 'Resolved';", con))
                    {
                        upd.Parameters.AddWithValue("@id", alertId);
                        upd.Parameters.AddWithValue("@admin", adminId);
                        rows = upd.ExecuteNonQuery();
                    }
                    if (rows == 0) return false;

                    // Sync ForumFlag if this was a Forum-type alert
                    if (alertType.Equals("Forum", StringComparison.OrdinalIgnoreCase)
                        && description.StartsWith("Post "))
                    {
                        var parts = description.Split(' ');
                        string postId = parts.Length >= 2 ? parts[1].Trim() : "";
                        if (!string.IsNullOrWhiteSpace(postId))
                        {
                            using (var flagUpd = new SqlCommand(@"
                                UPDATE dbo.ForumFlag SET status = 'Reviewed'
                                WHERE  postID = @postId AND status = 'Open';", con))
                            {
                                flagUpd.Parameters.AddWithValue("@postId", postId);
                                flagUpd.ExecuteNonQuery();
                            }
                        }
                    }

                    LogActivity("Alert Resolved",
                        $"Alert {alertId} ({alertType}) resolved by {adminId}.", "OK", "Low");
                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[ResolveAlert] " + ex.Message);
                return false;
            }
        }

        // -
        //  GetOpenAlerts — uses alertType (not category)
        // -
        [WebMethod]
        public static object GetOpenAlerts()
        {
            string cs = ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;
            var rows = new List<object>();
            try
            {
                using (var con = new SqlConnection(cs))
                {
                    con.Open();

                    using (var cmd = new SqlCommand(@"
                        SELECT alertID, alertType, title, description, priority, createdAt
                        FROM   dbo.adminAlertTable
                        WHERE  alertStatus <> 'Resolved'
                        ORDER  BY CASE priority
                            WHEN 'Urgent' THEN 1 WHEN 'High' THEN 2
                            WHEN 'Medium' THEN 3 ELSE 4 END, createdAt DESC;", con))
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            DateTime created = r["createdAt"] == DBNull.Value
                                ? DateTime.UtcNow : Convert.ToDateTime(r["createdAt"]);
                            rows.Add(new
                            {
                                alertId = r["alertID"].ToString(),
                                category = r["alertType"].ToString(),  // JS uses 'category' label
                                title = r["title"].ToString(),
                                description = r["description"].ToString(),
                                priority = r["priority"].ToString(),
                                createdAt = ToLocalTimestamp(created)
                            });
                        }

                    // Orphan ForumFlag rows not yet in adminAlertTable
                    using (var cmd = new SqlCommand(@"
                        SELECT ff.flagID, ff.postID, ff.userID, ff.reason, ff.createdAt
                        FROM   dbo.ForumFlag ff
                        WHERE  ff.status = 'Open'
                          AND  NOT EXISTS (
                              SELECT 1 FROM dbo.adminAlertTable a
                              WHERE  a.alertType   = 'Forum'
                                AND  a.alertStatus <> 'Resolved'
                                AND  a.description LIKE '%' + ff.postID + '%'
                          )
                        ORDER BY ff.createdAt DESC;", con))
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            DateTime created = r["createdAt"] == DBNull.Value
                                ? DateTime.UtcNow : Convert.ToDateTime(r["createdAt"]);
                            rows.Add(new
                            {
                                alertId = "FF:" + r["flagID"].ToString(),
                                category = "Forum",
                                title = "Forum Post Flagged",
                                description = $"Post {r["postID"]} flagged by {r["userID"]}: {r["reason"]}",
                                priority = "Medium",
                                createdAt = ToLocalTimestamp(created)
                            });
                        }
                }
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine("[GetOpenAlerts] " + ex.Message); }
            return rows;
        }

        // -
        //  GetAllActivityLogs
        // -
        [WebMethod]
        public static object GetAllActivityLogs()
        {
            string cs = ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;
            var rows = new List<object>();
            try
            {
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Pre-load open Security alerts keyed by userID
                    var openAlerts = new Dictionary<string, string>();
                    using (var ac = new SqlCommand(@"
                SELECT alertID, description FROM dbo.adminAlertTable
                WHERE  alertType = 'Security' AND alertStatus = 'Open';", conn))
                    using (var ar = ac.ExecuteReader())
                        while (ar.Read())
                        {
                            string desc = ar["description"]?.ToString() ?? "";
                            string aId = ar["alertID"]?.ToString() ?? "";
                            int p1 = desc.IndexOf('('), p2 = desc.IndexOf(')');
                            if (p1 >= 0 && p2 > p1)
                            {
                                string uid = desc.Substring(p1 + 1, p2 - p1 - 1).Trim();
                                if (!string.IsNullOrWhiteSpace(uid))
                                    openAlerts[uid] = aId;
                            }
                        }

                    using (var cmd = new SqlCommand(@"
                SELECT EventType, Description, CreatedAt, Status, Priority
                FROM   dbo.SysActivityLogTable
                WHERE  EventType IS NOT NULL AND LTRIM(RTRIM(EventType)) <> ''
                ORDER  BY CreatedAt DESC;", conn))
                    using (var reader = cmd.ExecuteReader())
                        while (reader.Read())
                        {
                            string eventType = reader["EventType"]?.ToString() ?? "";
                            if (string.IsNullOrWhiteSpace(eventType)) continue;

                            string description = reader["Description"]?.ToString() ?? "";
                            DateTime createdAt = reader["CreatedAt"] == DBNull.Value
                                ? DateTime.UtcNow : Convert.ToDateTime(reader["CreatedAt"]);
                            string s = reader["Status"]?.ToString() ?? "";

                            string alertId = "";
                            string evLower = eventType.ToLower();
                            if (evLower.Contains("login") && evLower.Contains("fail"))
                            {
                                int p1 = description.IndexOf('('), p2 = description.IndexOf(')');
                                if (p1 >= 0 && p2 > p1)
                                {
                                    string uid = description.Substring(p1 + 1, p2 - p1 - 1).Trim();
                                    openAlerts.TryGetValue(uid, out alertId);
                                }
                            }

                            rows.Add(new LogRow
                            {
                                eventType = eventType,
                                description = description,
                                timestamp = ToLocalTimestamp(createdAt),
                                status = string.IsNullOrWhiteSpace(s) ? "Info" : s,
                                priority = reader["Priority"]?.ToString() ?? "",
                                alertId = alertId ?? ""
                            });
                        }
                }
            }
            catch { }
            return rows;
        }

        // -
        //  GetPlatformActivityData
        //  userLoginTable confirmed: loginID, userID, loginDate (date)
        // -
        [WebMethod]
        public static object GetPlatformActivityData()
        {
            string cs = ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;
            var studentData = new List<int>();
            var teacherData = new List<int>();
            var labels = new List<string>();
            try
            {
                using (var con = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    SELECT CAST(sl.loginDate AS DATE) AS LoginDay,
                           SUM(CASE WHEN r.roleName = 'Student' THEN 1 ELSE 0 END) AS StudentLogins,
                           SUM(CASE WHEN r.roleName = 'Teacher' THEN 1 ELSE 0 END) AS TeacherLogins
                    FROM   dbo.userLoginTable sl
                    JOIN   dbo.userRoleTable ur ON ur.userID = sl.userID
                    JOIN   dbo.Role r            ON r.roleID  = ur.roleID
                    WHERE  sl.loginDate >= DATEADD(day, -30, GETDATE())
                    GROUP  BY CAST(sl.loginDate AS DATE)
                    ORDER  BY LoginDay;", con))
                {
                    con.Open();
                    using (var reader = cmd.ExecuteReader())
                        while (reader.Read())
                        {
                            labels.Add(Convert.ToDateTime(reader["LoginDay"]).ToString("dd MMM"));
                            studentData.Add(Convert.ToInt32(reader["StudentLogins"]));
                            teacherData.Add(Convert.ToInt32(reader["TeacherLogins"]));
                        }
                }
            }
            catch { }
            return new { labels, students = studentData, teachers = teacherData };
        }

        // -
        //  GetRoleDistributionChart
        // -
        [WebMethod]
        public static object GetRoleDistributionChart()
        {
            string cs = ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;
            var labels = new List<string>();
            var values = new List<int>();
            try
            {
                using (var con = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    SELECT r.roleName, COUNT(*) AS Cnt
                    FROM   dbo.userRoleTable ur
                    JOIN   dbo.userTable u ON u.userID = ur.userID
                    JOIN   dbo.Role r      ON r.roleID = ur.roleID
                    WHERE  u.accountStatus=1 AND ISNULL(u.isDeleted,0)=0
                    GROUP  BY r.roleName ORDER BY Cnt DESC;", con))
                {
                    con.Open();
                    using (var reader = cmd.ExecuteReader())
                        while (reader.Read())
                        {
                            labels.Add(reader["roleName"].ToString());
                            values.Add(Convert.ToInt32(reader["Cnt"]));
                        }
                }
            }
            catch { }
            return new { labels, values };
        }

        // Helpers
        private static string ToLocalTimestamp(DateTime utcDate)
        {
            TimeZoneInfo myt;
            try { myt = TimeZoneInfo.FindSystemTimeZoneById("Singapore Standard Time"); }
            catch { try { myt = TimeZoneInfo.FindSystemTimeZoneById("Asia/Singapore"); } catch { myt = TimeZoneInfo.Utc; } }

            DateTime local = TimeZoneInfo.ConvertTimeFromUtc(DateTime.SpecifyKind(utcDate, DateTimeKind.Utc), myt);
            DateTime now = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, myt);
            TimeSpan diff = now - local;

            if (diff.TotalSeconds < 60) return "just now";
            if (diff.TotalMinutes < 60) { int m = (int)diff.TotalMinutes; return $"{m} min{(m == 1 ? "" : "s")} ago"; }
            if (diff.TotalHours < 6) { int h = (int)diff.TotalHours; int m = (int)(diff.TotalMinutes % 60); return m > 0 ? $"{h}h {m}m ago" : $"{h}h ago"; }
            if (local.Date == now.Date) return $"Today, {local:h:mm tt}";
            if (local.Date == now.Date.AddDays(-1)) return $"Yesterday, {local:h:mm tt}";
            if (diff.TotalDays < 7) return $"{local:ddd, h:mm tt}";
            if (local.Year == now.Year) return $"{local:d MMM, h:mm tt}";
            return $"{local:d MMM yyyy, h:mm tt}";
        }

        private static void MapStatusColors(string status, string priority, out string bg, out string text)
        {
            bg = "gray-100"; text = "gray-600";
            string pr = (priority ?? "").Trim().ToLower();
            string s = (status ?? "").Trim().ToLower();
            if (pr == "urgent" || pr == "high") { bg = "red-100"; text = "red-500"; return; }
            if (s == "success" || s == "ok") { bg = "green-100"; text = "math-green"; return; }
            if (s == "flagged" || s == "warning") { bg = "yellow-100"; text = "primary"; return; }
            if (s == "error" || s == "failed") { bg = "red-100"; text = "red-500"; return; }
            if (s == "info" || s == "auto") { bg = "blue-100"; text = "math-blue"; return; }
            if (pr == "medium") { bg = "yellow-100"; text = "primary"; }
        }

        private static void MapEventIcon(string eventType, string priority,
                                          out string icon, out string iconBg, out string iconColor)
        {
            icon = "event"; iconBg = "blue-100"; iconColor = "math-blue";
            string pr = (priority ?? "").Trim().ToLower();
            string ev = (eventType ?? "").Trim().ToLower();

            if (pr == "urgent" || pr == "high") { iconBg = "red-100"; iconColor = "red-500"; }
            else if (pr == "medium") { iconBg = "yellow-100"; iconColor = "primary"; }

            if (ev.Contains("login") && ev.Contains("fail")) icon = "lock_person";
            else if (ev.Contains("security")) icon = "security";
            else if (ev.Contains("login")) icon = "login";
            else if (ev.Contains("logout")) icon = "logout";
            else if (ev.Contains("register")) icon = "person_add";
            else if (ev.Contains("module")) icon = "menu_book";
            else if (ev.Contains("quiz")) icon = "quiz";
            else if (ev.Contains("flashcard")) icon = "style";
            else if (ev.Contains("streak") || ev.Contains("xp")) icon = "star";
            else if (ev.Contains("forum") && ev.Contains("flag")) icon = "flag";
            else if (ev.Contains("forum")) icon = "forum";
            else if (ev.Contains("assessment")) icon = "assignment";
            else if (ev.Contains("ticket") || ev.Contains("help")) icon = "support_agent";
            else if (ev.Contains("disab") || ev.Contains("block")) icon = "block";
            else if (ev.Contains("enabl") || ev.Contains("react")) icon = "check_circle";
            else if (ev.Contains("course")) icon = "school";
            else if (ev.Contains("alert")) icon = "notifications";
            else if (ev.Contains("settings")) icon = "settings";
            else if (ev.Contains("backup")) icon = "cloud_upload";
            else if (ev.Contains("user")) icon = "person";
            else if (ev.Contains("create") || ev.Contains("seed")) icon = "add_circle";
        }

        // Data models
        public class LogRow { public string eventType, description, timestamp, status, priority, alertId; }
        public class StatsCard { public string Title, Value, Subtitle, Icon, MainIcon, BorderColor, SubtitleColor, IconBgColor, IconColor; }
        public class RoleDistribution { public string RoleName, BgColor, DotColor, TextColor; public int Percentage; }
        public class ActivityLogItem
        {
            public string EventType, Description, Timestamp, Status, Icon,
                          IconBgColor, IconColor, StatusBgColor, StatusTextColor, AlertId;
        }
    }
}




