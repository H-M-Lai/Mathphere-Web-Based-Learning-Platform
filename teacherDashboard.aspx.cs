using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace MathSphere
{
    public partial class teacherDashboard : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            string teacherId = Session["UserID"].ToString();

            if (!IsPostBack)
            {
                try
                {
                    LoadTeacherGreeting(teacherId);
                    LoadStats(teacherId);
                    BindCourseFilter(teacherId);
                    BindTopModules(teacherId);
                    GenerateChartData(teacherId, "");
                }
                catch (Exception ex)
                {
                    litMsg.Text = "<div class='mb-6 p-4 rounded-xl bg-red-50 text-red-700 font-bold'>DB Error: "
                                  + Server.HtmlEncode(ex.Message) + "</div>";
                }
            }
        }

        // Teacher greeting
        private void LoadTeacherGreeting(string teacherId)
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT fullName FROM dbo.userTable WHERE RTRIM(userID) = @tid", conn))
            {
                cmd.Parameters.AddWithValue("@tid", teacherId);
                conn.Open();
                string name = cmd.ExecuteScalar()?.ToString() ?? "";
                litTeacherName.Text = string.IsNullOrWhiteSpace(name) ? "Teacher" : Server.HtmlEncode(name);
            }
        }

        // -
        //  STAT CARDS
        //
        //  Stat 1 — Total Students
        //      COUNT(DISTINCT userID) across all non-archived courses.
        //
        //  Stat 2 — Avg Engagement  (litAvgEngagement)
        //      Live: AVG( completed blocks / total blocks * 100 )
        //      per (student, module) across all teacher's courses.
        //      Source: studentBlockProgressTable.
        //
        //  Stat 3 — Draft Assessments  (litPendingAssessments)
        //      COUNT of assessments with isPublished = 0 in teacher's courses.
        //
        //  Quiz Score is shown in the chart and top modules panel only.
        //
        //  Quiz block chain (used in chart + top modules):
        //      moduleBlockTable (blockType='Quiz')
        //      ? blockContentTable.quizID = assessmentTable.assessmentID
        //      Only assessments reachable via this chain count as quiz scores.
        // -
        private void LoadStats(string teacherId)
        {
            const string sql = @"
                ;WITH TeacherCourses AS
                (
                    SELECT courseID
                    FROM   dbo.courseTable
                    WHERE  teacherID = @tid
                      AND  status   <> 'Archived'
                ),
                ActiveEnrolments AS
                (
                    SELECT se.userID, se.courseID
                    FROM   dbo.studentEnrolmentTable se
                    JOIN   TeacherCourses tc ON tc.courseID = se.courseID
                    WHERE  se.enrolStatus = 1
                ),

                -- Stat 1: Total distinct active students
                TotalStudentsCTE AS
                (
                    SELECT COUNT(DISTINCT userID) AS TotalStudents
                    FROM   ActiveEnrolments
                ),

                -- Stat 2: Avg Student Engagement
                -- Per (student, module): completed_blocks / total_blocks * 100
                -- Then average across all (student, module) pairs
                StudentModulePct AS
                (
                    SELECT
                        ae.userID,
                        m.moduleID,
                        CAST(
                            CAST(SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) AS DECIMAL(10,2))
                            / NULLIF(COUNT(mb.blockID), 0) * 100.0
                        AS DECIMAL(10,2)) AS ModulePct
                    FROM   ActiveEnrolments ae
                    JOIN   dbo.moduleTable               m   ON  m.courseID  = ae.courseID
                    JOIN   dbo.moduleBlockTable          mb  ON  mb.moduleID = m.moduleID
                    LEFT JOIN dbo.studentBlockProgressTable sbp
                                                         ON  sbp.blockID = mb.blockID
                                                         AND sbp.userID  = ae.userID
                    GROUP BY ae.userID, m.moduleID
                ),
                EngagementCTE AS
                (
                    SELECT CAST(ISNULL(AVG(ModulePct), 0) AS DECIMAL(5,2)) AS AvgEngagement
                    FROM   StudentModulePct
                ),

                -- Stat 3: Draft assessments (isPublished = 0) in teacher's courses
                DraftAssessmentCTE AS
                (
                    SELECT COUNT(*) AS DraftAssessments
                    FROM   dbo.assessmentTable a
                    JOIN   TeacherCourses tc ON tc.courseID = a.courseID
                    WHERE  a.isPublished = 0
                )
                SELECT
                    ts.TotalStudents,
                    eng.AvgEngagement,
                    da.DraftAssessments
                FROM TotalStudentsCTE     ts
                CROSS JOIN EngagementCTE  eng
                CROSS JOIN DraftAssessmentCTE da;";

            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tid", teacherId);
                conn.Open();

                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        litTotalStudents.Text = Convert.ToString(r["TotalStudents"]);

                        decimal avgEngagement = Convert.ToDecimal(r["AvgEngagement"]);
                        litAvgEngagement.Text = avgEngagement.ToString("0.##") + "%";

                        litPendingAssessments.Text = Convert.ToString(r["DraftAssessments"]);
                    }
                    else
                    {
                        litTotalStudents.Text = "0";
                        litAvgEngagement.Text = "0%";
                        litPendingAssessments.Text = "0";
                    }
                }
            }
        }

        // Course filter dropdown
        private void BindCourseFilter(string teacherId)
        {
            const string sql = @"
                SELECT courseID, courseName
                FROM   dbo.courseTable
                WHERE  teacherID = @tid
                  AND  status   <> 'Archived'
                ORDER  BY courseName;";

            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tid", teacherId);
                conn.Open();
                var dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);

                ddlCourseFilter.Items.Clear();
                ddlCourseFilter.Items.Add(
                    new System.Web.UI.WebControls.ListItem("All Courses", ""));

                foreach (DataRow row in dt.Rows)
                    ddlCourseFilter.Items.Add(
                        new System.Web.UI.WebControls.ListItem(
                            row["courseName"].ToString(),
                            row["courseID"].ToString()));
            }
        }

        protected void ddlCourseFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            string teacherId = Session["UserID"]?.ToString() ?? "";
            string courseId = ddlCourseFilter.SelectedValue;
            GenerateChartData(teacherId, courseId);
            BindTopModules(teacherId, courseId);
        }

        // -
        //  TOP MODULES — ranked by avg quiz score (first attempt)
        //  Quiz chain: moduleBlockTable.blockType='Quiz'
        //              ? blockContentTable.quizID = assessmentTable.assessmentID
        // -
        private void BindTopModules(string teacherId, string courseId = "")
        {
            string courseFilter = string.IsNullOrWhiteSpace(courseId)
                ? "" : " AND c.courseID = @cid ";

            string sql = @"
                ;WITH TeacherModules AS
                (
                    SELECT m.moduleID, m.moduleTitle
                    FROM   dbo.courseTable c
                    JOIN   dbo.moduleTable m ON m.courseID = c.courseID
                    WHERE  c.teacherID = @tid
                      AND  c.status   <> 'Archived' " + courseFilter + @"
                ),
                -- Quiz scores via quizTable.blockID ? moduleID chain
                QuizTotalPoints AS
                (
                    SELECT qq.quizID,
                           NULLIF(SUM(qq.points), 0) AS TotalPoints
                    FROM   dbo.quizQuestionTable qq
                    GROUP BY qq.quizID
                ),
                FirstQuizAttempts AS
                (
                    SELECT
                        qa.userID,
                        q.moduleID,
                        CAST(qa.score AS DECIMAL(10,2))
                            / NULLIF(qtp.TotalPoints, 0) * 100.0 AS QuizPct,
                        ROW_NUMBER() OVER (
                            PARTITION BY qa.userID, qa.quizID
                            ORDER     BY qa.attemptedAt ASC
                        ) AS rn
                    FROM  dbo.QuizAttempt            qa
                    JOIN  dbo.quizTable              q   ON  q.quizID    = qa.quizID
                    JOIN  TeacherModules             tm  ON  tm.moduleID = q.moduleID
                    LEFT JOIN QuizTotalPoints        qtp ON  qtp.quizID  = qa.quizID
                ),
                FirstOnly AS
                (
                    SELECT moduleID, QuizPct AS percentage
                    FROM   FirstQuizAttempts
                    WHERE  rn = 1
                )
                SELECT TOP 3
                    tm.moduleTitle AS ModuleTitle,
                    CAST(ISNULL(AVG(CAST(fo.percentage AS DECIMAL(10,2))), 0)
                         AS DECIMAL(5,2)) AS AvgScore
                FROM  TeacherModules tm
                LEFT JOIN FirstOnly fo ON fo.moduleID = tm.moduleID
                GROUP  BY tm.moduleID, tm.moduleTitle
                ORDER  BY AvgScore DESC, tm.moduleTitle ASC;";

            var dt = new DataTable();
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tid", teacherId);
                if (!string.IsNullOrWhiteSpace(courseId))
                    cmd.Parameters.AddWithValue("@cid", courseId);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }

            if (!dt.Columns.Contains("AvgScoreFmt")) dt.Columns.Add("AvgScoreFmt", typeof(string));
            if (!dt.Columns.Contains("BarWidth")) dt.Columns.Add("BarWidth", typeof(string));
            if (!dt.Columns.Contains("HasScore")) dt.Columns.Add("HasScore", typeof(string));

            if (dt.Rows.Count == 0)
            {
                if (!dt.Columns.Contains("ModuleTitle")) dt.Columns.Add("ModuleTitle", typeof(string));
                if (!dt.Columns.Contains("AvgScore")) dt.Columns.Add("AvgScore", typeof(decimal));
                DataRow empty = dt.NewRow();
                empty["ModuleTitle"] = "No modules yet";
                empty["AvgScore"] = 0m;
                empty["AvgScoreFmt"] = "0";
                empty["BarWidth"] = "0";
                empty["HasScore"] = "0";
                dt.Rows.Add(empty);
            }
            else
            {
                foreach (DataRow row in dt.Rows)
                {
                    decimal score = Convert.ToDecimal(row["AvgScore"]);
                    decimal displayScore = Clamp(score, 0m, 100m);
                    row["AvgScoreFmt"] = displayScore.ToString("0.##");
                    row["BarWidth"] = displayScore.ToString("0.##");
                    row["HasScore"] = score > 0 ? "1" : "0";
                }
            }

            rptTopModules.DataSource = dt;
            rptTopModules.DataBind();
        }

        // -
        //  CHART DATA
        //  Blue  = Avg Quiz Score  (blockContentTable.quizID chain)
        //  Green = Avg Completion % (live from studentBlockProgressTable)
        //  Yellow = Attempt Count
        // -
        private void GenerateChartData(string teacherId, string courseId)
        {
            string courseFilter = string.IsNullOrWhiteSpace(courseId)
                ? "" : " AND c.courseID = @cid ";

            string sql = @"
                ;WITH TeacherModules AS
                (
                    SELECT m.moduleID, m.moduleTitle
                    FROM   dbo.courseTable c
                    JOIN   dbo.moduleTable m ON m.courseID = c.courseID
                    WHERE  c.teacherID = @tid
                      AND  c.status   <> 'Archived' " + courseFilter + @"
                ),
                -- Quiz scores: quizTable links blockID ? moduleID
                -- QuizAttempt stores score (raw points) per attempt
                -- Percentage = score / totalPoints * 100
                -- totalPoints = SUM(quizQuestionTable.points) per quiz
                QuizTotalPoints AS
                (
                    SELECT qq.quizID,
                           NULLIF(SUM(qq.points), 0) AS TotalPoints
                    FROM   dbo.quizQuestionTable qq
                    GROUP BY qq.quizID
                ),
                FirstQuizAttempts AS
                (
                    SELECT
                        qa.userID,
                        q.moduleID,
                        CAST(qa.score AS DECIMAL(10,2))
                            / NULLIF(qtp.TotalPoints, 0) * 100.0 AS QuizPct,
                        ROW_NUMBER() OVER (
                            PARTITION BY qa.userID, qa.quizID
                            ORDER     BY qa.attemptedAt ASC
                        ) AS rn
                    FROM  dbo.QuizAttempt            qa
                    JOIN  dbo.quizTable              q   ON  q.quizID    = qa.quizID
                    JOIN  TeacherModules             tm  ON  tm.moduleID = q.moduleID
                    LEFT JOIN QuizTotalPoints        qtp ON  qtp.quizID  = qa.quizID
                ),
                FirstOnly AS
                (
                    SELECT moduleID, QuizPct AS percentage, userID
                    FROM   FirstQuizAttempts
                    WHERE  rn = 1
                ),
                StudentModCompletion AS
                (
                    SELECT
                        m.moduleID,
                        se.userID,
                        CAST(
                            CAST(SUM(CASE WHEN ISNULL(sbp.isCompleted,0)=1 THEN 1 ELSE 0 END) AS DECIMAL(10,2))
                            / NULLIF(COUNT(mb.blockID), 0) * 100.0
                        AS DECIMAL(10,2)) AS StudentPct
                    FROM   dbo.moduleTable               m
                    JOIN   dbo.moduleBlockTable          mb  ON mb.moduleID = m.moduleID
                    JOIN   dbo.studentEnrolmentTable     se  ON se.courseID = m.courseID
                                                            AND se.enrolStatus = 1
                    LEFT JOIN dbo.studentBlockProgressTable sbp
                                                            ON sbp.blockID = mb.blockID
                                                           AND sbp.userID  = se.userID
                    GROUP BY m.moduleID, se.userID
                ),
                AvgLiveCompletion AS
                (
                    SELECT moduleID,
                           CAST(ISNULL(AVG(StudentPct), 0) AS DECIMAL(5,2)) AS AvgCompletion
                    FROM   StudentModCompletion
                    GROUP BY moduleID
                )
                SELECT TOP 8
                    tm.moduleTitle                                                          AS ModuleTitle,
                    CAST(ISNULL(AVG(CAST(fo.percentage AS DECIMAL(10,2))), 0)
                         AS DECIMAL(5,2))                                                   AS AvgQuizScore,
                    ISNULL(lc.AvgCompletion, 0)                                             AS AvgCompletion,
                    COUNT(DISTINCT fo.userID)                                                AS AttemptCount
                FROM  TeacherModules       tm
                LEFT JOIN FirstOnly        fo ON fo.moduleID = tm.moduleID
                LEFT JOIN AvgLiveCompletion lc ON lc.moduleID = tm.moduleID
                GROUP  BY tm.moduleID, tm.moduleTitle, lc.AvgCompletion
                ORDER  BY tm.moduleTitle ASC;";

            var dt = new DataTable();
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tid", teacherId);
                if (!string.IsNullOrWhiteSpace(courseId))
                    cmd.Parameters.AddWithValue("@cid", courseId);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                litChartJson.Text = "[]";
                litMaxAttempts.Text = "1";
                return;
            }

            int maxAttempts = 1;
            foreach (DataRow row in dt.Rows)
            {
                int cnt = Convert.ToInt32(row["AttemptCount"]);
                if (cnt > maxAttempts) maxAttempts = cnt;
            }
            litMaxAttempts.Text = maxAttempts.ToString();

            var list = new System.Collections.Generic.List<object>();
            foreach (DataRow row in dt.Rows)
            {
                string title = row["ModuleTitle"].ToString();
                int quiz = Clamp((int)Math.Round(Convert.ToDecimal(row["AvgQuizScore"])), 0, 100);
                int comp = Clamp((int)Math.Round(Convert.ToDecimal(row["AvgCompletion"])), 0, 100);
                int att = Convert.ToInt32(row["AttemptCount"]);
                int attPct = maxAttempts > 0
                    ? Clamp((int)Math.Round((double)att / maxAttempts * 100), 0, 100)
                    : 0;

                list.Add(new
                {
                    label = title.Length > 14 ? title.Substring(0, 14) + "…" : title,
                    fullLabel = title,
                    quiz = quiz,
                    comp = comp,
                    att = att,
                    attPct = attPct
                });
            }

            litChartJson.Text = new JavaScriptSerializer().Serialize(list);
        }

        // Helpers
        private static int Clamp(int v, int min, int max) => v < min ? min : (v > max ? max : v);
        private static decimal Clamp(decimal v, decimal min, decimal max) => v < min ? min : (v > max ? max : v);
    }
}
