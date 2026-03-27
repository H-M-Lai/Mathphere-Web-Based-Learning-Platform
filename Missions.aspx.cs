using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Assignment
{
    public partial class Missions : System.Web.UI.Page
    {
        private string CS => ConfigurationManager
            .ConnectionStrings["MathSphereDB"].ConnectionString;

        private Dictionary<string, string> _settings;

        private Dictionary<string, string> GetSystemSettings()
        {
            if (_settings != null) return _settings;
            _settings = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            const string sql = "SELECT SettingKey, SettingValue FROM dbo.SystemSettings";
            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            _settings[dr["SettingKey"].ToString()] = dr["SettingValue"].ToString();
                }
            }
            catch { }
            if (!_settings.ContainsKey("FlashcardCompletion")) _settings["FlashcardCompletion"] = "10";
            if (!_settings.ContainsKey("QuizPerfectScore")) _settings["QuizPerfectScore"] = "50";
            if (!_settings.ContainsKey("StreakBonus7Day")) _settings["StreakBonus7Day"] = "100";
            if (!_settings.ContainsKey("DailyActivityWindowHours")) _settings["DailyActivityWindowHours"] = "24";
            if (!_settings.ContainsKey("InactivityThresholdDays")) _settings["InactivityThresholdDays"] = "3";
            return _settings;
        }

        private int SettingInt(string key, int fallback = 0)
        {
            var s = GetSystemSettings();
            return s.TryGetValue(key, out string v) && int.TryParse(v, out int i) ? i : fallback;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string userId = (Session["UserID"] as string)?.Trim()
                         ?? (Session["userID"] as string)?.Trim();

            if (string.IsNullOrWhiteSpace(userId))
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindSettingsBanner();
                BindMissions(userId);
            }
        }

        private void BindSettingsBanner()
        {
            litFlashcardPts.Text = SettingInt("FlashcardCompletion", 10).ToString();
            litQuizPts.Text = SettingInt("QuizPerfectScore", 50).ToString();
            litStreakPts.Text = SettingInt("StreakBonus7Day", 100).ToString();
        }

        // Missions — progress calculated LIVE from studentBlockProgressTable
        // Matches exactly what moduleContent.aspx and moduleOverview.aspx show.
        // studentProgressTable is NOT used as the source because it can be stale
        // (e.g. last block completion didn't fire a postback, or was completed via
        // a different flow). Counting directly from studentBlockProgressTable is
        // always accurate and consistent across all pages.
        private void BindMissions(string userId)
        {
            int flashcardPts = SettingInt("FlashcardCompletion", 10);
            var dt = new DataTable();

            const string sql = @"
                SELECT
                    m.moduleID,
                    m.moduleTitle,
                    ISNULL(m.moduleDescription, '')  AS moduleDescription,
                    c.courseName,
                    -- Live progress from studentBlockProgressTable
                    CAST(ROUND(
                        CAST(
                            SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END)
                        AS float)
                        /
                        NULLIF(COUNT(mb.blockID), 0)
                        * 100
                    , 0) AS int)                     AS progress,
                    MAX(sbp.completedAt)              AS lastActiveAt
                FROM dbo.studentEnrolmentTable   e
                INNER JOIN dbo.courseTable        c  ON  c.courseID  = e.courseID
                                                    AND  c.status    = 'Active'
                INNER JOIN dbo.moduleTable        m  ON  m.courseID  = c.courseID
                                                    AND  m.Status    = 'Active'
                INNER JOIN dbo.moduleBlockTable   mb ON  mb.moduleID = m.moduleID
                LEFT  JOIN dbo.studentBlockProgressTable sbp
                                                   ON  sbp.blockID  = mb.blockID
                                                   AND sbp.userID   = e.userID
                WHERE e.userID      = @uid
                  AND e.enrolStatus = 1
                GROUP BY m.moduleID, m.moduleTitle, m.moduleDescription, c.courseName
                -- Only show started but incomplete modules
                HAVING
                    SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) > 0
                    AND
                    SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END)
                        < COUNT(mb.blockID)
                ORDER BY
                    CAST(
                        SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END)
                    AS float) / NULLIF(COUNT(mb.blockID),0) DESC,
                    MAX(sbp.completedAt) DESC";

            try
            {
                using (var con = new SqlConnection(CS))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }
            catch (Exception ex)
            {
                pnlSettingsBanner.Visible = false;
                pnlNoMissions.Visible = true;
                pnlNoMissions.Controls.Add(new System.Web.UI.LiteralControl(
                    "<p class='text-red-500 text-sm font-bold mt-2'>DB Error: " +
                    System.Web.HttpUtility.HtmlEncode(ex.Message) + "</p>"));
                rptMissions.Visible = false;
                return;
            }

            if (dt.Rows.Count == 0)
            {
                pnlSettingsBanner.Visible = false;
                pnlNoMissions.Visible = true;
                rptMissions.Visible = false;
                return;
            }

            dt.Columns.Add("AccentClass", typeof(string));
            dt.Columns.Add("BadgeClass", typeof(string));
            dt.Columns.Add("Icon", typeof(string));
            dt.Columns.Add("FlashcardPts", typeof(int));

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                ApplyCardStyle(dt.Rows[i], i);
                dt.Rows[i]["FlashcardPts"] = flashcardPts;
            }

            pnlSettingsBanner.Visible = true;
            pnlNoMissions.Visible = false;
            rptMissions.Visible = true;
            rptMissions.DataSource = dt;
            rptMissions.DataBind();
        }

        private void ApplyCardStyle(DataRow row, int index)
        {
            switch (index % 3)
            {
                case 0:
                    row["AccentClass"] = "bg-math-blue shadow-math-blue/20";
                    row["BadgeClass"] = "bg-math-blue/10 text-math-blue border border-math-blue/10";
                    row["Icon"] = "menu_book";
                    break;
                case 1:
                    row["AccentClass"] = "bg-math-green shadow-math-green/20";
                    row["BadgeClass"] = "bg-math-green/10 text-math-green border border-math-green/10";
                    row["Icon"] = "reorder";
                    break;
                default:
                    row["AccentClass"] = "bg-primary text-math-dark-blue shadow-primary/15";
                    row["BadgeClass"] = "bg-primary/25 text-math-dark-blue border border-primary/30";
                    row["Icon"] = "school";
                    break;
            }
        }
    }
}
