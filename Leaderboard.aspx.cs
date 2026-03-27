using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;

namespace Assignment
{
    public partial class Leaderboard : System.Web.UI.Page
    {
        private string CS => ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        private const int PageSize = 10;

        private bool IsGuest =>
            Session["IsGuest"] is bool b && b &&
            string.IsNullOrWhiteSpace(
                (Session["UserID"] ?? Session["userID"])?.ToString());

        // Tab: "points" or "streak"
        protected string ActiveTab
        {
            get => (ViewState["LBTab"] as string) ?? "points";
            set => ViewState["LBTab"] = value;
        }

        private int CurrentPage
        {
            get => (ViewState["LBPage"] == null) ? 1 : (int)ViewState["LBPage"];
            set => ViewState["LBPage"] = value;
        }

        // Player model used by both tabs
        public class Player
        {
            public int Rank { get; set; }
            public string UserID { get; set; }
            public string Name { get; set; }
            public string AvatarUrl { get; set; }
            public int XP { get; set; }
            public int CurrentStreak { get; set; }   // from StudentStreak
            public int BestStreak { get; set; }   // from StudentStreak
            public int DisplayStreak { get; set; }   // live current streak shown in the UI
        }

        // -
        //  Page lifecycle
        // -
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsGuest)
            {
                string uid = (Session["UserID"] ?? Session["userID"])?.ToString()?.Trim();
                if (string.IsNullOrWhiteSpace(uid))
                {
                    Response.Redirect("~/Login.aspx", true);
                    return;
                }
            }

            if (!IsPostBack)
            {
                CurrentPage = 1;
                ActiveTab = "points";
                LoadLeaderboard();
            }
        }

        // -
        //  Tab button handlers
        // -
        protected void btnTabPoints_Click(object sender, EventArgs e)
        {
            ActiveTab = "points";
            CurrentPage = 1;
            LoadLeaderboard();
        }

        protected void btnTabStreak_Click(object sender, EventArgs e)
        {
            ActiveTab = "streak";
            CurrentPage = 1;
            LoadLeaderboard();
        }

        // -
        //  Existing handlers (unchanged)
        // -
        protected void btnLoadMore_Click(object sender, EventArgs e)
        {
            CurrentPage++;
            LoadLeaderboard();
        }

        protected void btnFilterGlobal_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            LoadLeaderboard();
        }

        protected void btnBoostRank_Click(object sender, EventArgs e)
        {
            if (IsGuest) { Response.Redirect("~/Register.aspx"); return; }
            Response.Redirect("~/Missions.aspx");
        }

        // -
        //  Main load — dispatches to Points or Streak
        // -
        private void LoadLeaderboard()
        {
            int take = CurrentPage * PageSize;
            int totalCount = GetTotalPlayerCount();
            var players = ActiveTab == "streak"
                             ? GetStreakLeaderboard(take)
                             : GetPointsLeaderboard(take);

            // Pass tab state to ASPX so CSS classes can be applied
            // (read via protected property below)
            BindTop3(players);

            rptLeaderboard.DataSource = players;
            rptLeaderboard.DataBind();

            btnLoadMore.Visible = (take < totalCount);

            // Show/hide correct column header label
            litSortLabel.Text = ActiveTab == "streak" ? "Best Streak" : "XP";
            ApplyTabState();
        }

        // -
        //  Tab CSS helpers — read by ASPX data-binding

        private void ApplyTabState()
        {
            btnTabPoints.CssClass = TabPointsCss;
            btnTabStreak.CssClass = TabStreakCss;
        }
        // -
        protected string TabPointsCss => ActiveTab == "points"
            ? "inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-math-blue text-white font-black text-sm uppercase tracking-widest shadow-lg shadow-math-blue/20 transition-all cursor-pointer scale-[1.02]"
            : "inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-white border-2 border-gray-200 text-gray-500 font-black text-sm uppercase tracking-widest hover:border-math-blue/30 hover:text-math-blue hover:-translate-y-[1px] transition-all cursor-pointer";

        protected string TabStreakCss => ActiveTab == "streak"
            ? "inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-orange-500 text-white font-black text-sm uppercase tracking-widest shadow-lg shadow-orange-500/20 transition-all cursor-pointer scale-[1.02]"
            : "inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-white border-2 border-gray-200 text-gray-500 font-black text-sm uppercase tracking-widest hover:border-orange-300 hover:text-orange-500 hover:-translate-y-[1px] transition-all cursor-pointer";

        // -
        //  Bind Top-3 podium
        // -
        private void BindTop3(List<Player> players)
        {
            if (players == null || players.Count == 0) return;

            bool isStreak = ActiveTab == "streak";
            string podiumLabel = isStreak ? "Best Streak" : "Score";

            litPodiumLabel1.Text = podiumLabel;
            litPodiumLabel2.Text = podiumLabel;
            litPodiumLabel3.Text = podiumLabel;

            if (players.Count >= 1)
            {
                imgRank1.ImageUrl = ResolveAvatar(players[0].AvatarUrl);
                litRank1Name.Text = players[0].Name;
                litRank1XP.Text = isStreak
                    ? players[0].BestStreak + " day best"
                    : players[0].XP.ToString("N0") + " XP";
                litRank1Streak.Text = players[0].DisplayStreak.ToString();
            }
            if (players.Count >= 2)
            {
                imgRank2.ImageUrl = ResolveAvatar(players[1].AvatarUrl);
                litRank2Name.Text = players[1].Name;
                litRank2XP.Text = isStreak
                    ? players[1].BestStreak + " day best"
                    : players[1].XP.ToString("N0") + " XP";
                litRank2Streak.Text = players[1].DisplayStreak.ToString();
            }
            if (players.Count >= 3)
            {
                imgRank3.ImageUrl = ResolveAvatar(players[2].AvatarUrl);
                litRank3Name.Text = players[2].Name;
                litRank3XP.Text = isStreak
                    ? players[2].BestStreak + " day best"
                    : players[2].XP.ToString("N0") + " XP";
                litRank3Streak.Text = players[2].DisplayStreak.ToString();
            }
        }

        // -
        //  Total player count (shared by both tabs for Load More)
        // -
        private int GetTotalPlayerCount()
        {
            const string sql = @"
                SELECT COUNT(DISTINCT u.userID)
                FROM   dbo.userTable u
                WHERE  u.accountStatus        = 1
                  AND  ISNULL(u.isDeleted, 0) = 0
                  AND  EXISTS (
                           SELECT 1 FROM dbo.studentEnrolmentTable e
                           WHERE  e.userID = u.userID
                       );";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        // -
        //  POINTS leaderboard — ranked by total XP
        //  Streak shown as DisplayStreak (current streak from StudentStreak)
        // -
        private List<Player> GetPointsLeaderboard(int take)
        {
            var list = new List<Player>();

            const string sql = @"
                ;WITH base AS (
                    SELECT
                        u.userID,
                        u.fullName,
                        ISNULL(u.AvatarUrl, '')  AS AvatarUrl,
                        TotalXP = ISNULL((
                            SELECT SUM(s.points)
                            FROM   dbo.studentScoreEventTable s
                            WHERE  s.userID = u.userID
                        ), 0),
                        -- Source of truth: StudentStreak
                        CurrentStreak = ISNULL(ss.currentStreak, 0),
                        BestStreak    = ISNULL(ss.bestStreak,    0),
                        lastActivityDate = ss.lastActivityDate
                    FROM dbo.userTable u
                    LEFT JOIN dbo.StudentStreak ss ON ss.userID = u.userID
                    WHERE u.accountStatus        = 1
                      AND ISNULL(u.isDeleted, 0) = 0
                      AND EXISTS (
                              SELECT 1 FROM dbo.studentEnrolmentTable e
                              WHERE  e.userID = u.userID
                          )
                ),
                ranked AS (
                    SELECT *,
                        RankNo = ROW_NUMBER() OVER (
                            ORDER BY TotalXP       DESC,
                                     CurrentStreak DESC,
                                     fullName      ASC,
                                     userID        ASC
                        )
                    FROM base
                )
                SELECT TOP (@take)
                    userID, fullName, AvatarUrl,
                    TotalXP, CurrentStreak, BestStreak, lastActivityDate, RankNo
                FROM  ranked
                ORDER BY RankNo ASC;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@take", take);
                con.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        list.Add(new Player
                        {
                            Rank = Convert.ToInt32(dr["RankNo"]),
                            UserID = dr["userID"].ToString(),
                            Name = dr["fullName"].ToString(),
                            AvatarUrl = dr["AvatarUrl"].ToString(),
                            XP = Convert.ToInt32(dr["TotalXP"]),
                            CurrentStreak = Convert.ToInt32(dr["CurrentStreak"]),
                            BestStreak = Convert.ToInt32(dr["BestStreak"]),
                            DisplayStreak = CalcDisplayStreak(Convert.ToInt32(dr["CurrentStreak"]), dr["lastActivityDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["lastActivityDate"]).Date)
                        });
                    }
                }
            }

            return list;
        }

        // -
        //  STREAK leaderboard — ranked by bestStreak DESC, then currentStreak
        //  Shows bestStreak as the primary stat, currentStreak as secondary
        // -
        private List<Player> GetStreakLeaderboard(int take)
        {
            var list = new List<Player>();

            const string sql = @"
                ;WITH base AS (
                    SELECT
                        u.userID,
                        u.fullName,
                        ISNULL(u.AvatarUrl, '')  AS AvatarUrl,
                        TotalXP       = ISNULL((
                            SELECT SUM(s.points)
                            FROM   dbo.studentScoreEventTable s
                            WHERE  s.userID = u.userID
                        ), 0),
                        CurrentStreak = ISNULL(ss.currentStreak, 0),
                        BestStreak    = ISNULL(ss.bestStreak,    0),
                        lastActivityDate = ss.lastActivityDate
                    FROM dbo.userTable u
                    LEFT JOIN dbo.StudentStreak ss ON ss.userID = u.userID
                    WHERE u.accountStatus        = 1
                      AND ISNULL(u.isDeleted, 0) = 0
                      AND EXISTS (
                              SELECT 1 FROM dbo.studentEnrolmentTable e
                              WHERE  e.userID = u.userID
                          )
                ),
                ranked AS (
                    SELECT *,
                        RankNo = ROW_NUMBER() OVER (
                            ORDER BY BestStreak    DESC,
                                     CurrentStreak DESC,
                                     TotalXP       DESC,
                                     fullName      ASC,
                                     userID        ASC
                        )
                    FROM base
                )
                SELECT TOP (@take)
                    userID, fullName, AvatarUrl,
                    TotalXP, CurrentStreak, BestStreak, lastActivityDate, RankNo
                FROM  ranked
                ORDER BY RankNo ASC;";

            using (var con = new SqlConnection(CS))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@take", take);
                con.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        list.Add(new Player
                        {
                            Rank = Convert.ToInt32(dr["RankNo"]),
                            UserID = dr["userID"].ToString(),
                            Name = dr["fullName"].ToString(),
                            AvatarUrl = dr["AvatarUrl"].ToString(),
                            XP = Convert.ToInt32(dr["TotalXP"]),
                            CurrentStreak = Convert.ToInt32(dr["CurrentStreak"]),
                            BestStreak = Convert.ToInt32(dr["BestStreak"]),
                            DisplayStreak = CalcDisplayStreak(Convert.ToInt32(dr["CurrentStreak"]), dr["lastActivityDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["lastActivityDate"]).Date)
                        });
                    }
                }
            }

            return list;
        }

        private int CalcDisplayStreak(int stored, DateTime? lastActivity)
        {
            if (stored <= 0 || lastActivity == null) return 0;

            DateTime today = DateTime.UtcNow.AddHours(8).Date;
            return (lastActivity.Value == today || lastActivity.Value == today.AddDays(-1)) ? stored : 0;
        }

        protected string ResolveAvatar(string avatarUrl)
        {
            if (string.IsNullOrWhiteSpace(avatarUrl))
                return ResolveUrl("~/Image/default-avatar.png");
            if (avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                return avatarUrl;
            return ResolveUrl("~/" + avatarUrl.TrimStart('~', '/'));
        }
    }
}




