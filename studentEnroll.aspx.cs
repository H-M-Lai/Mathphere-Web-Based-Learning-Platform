using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using DocumentFormat.OpenXml.Packaging;
using XlsxSheet = DocumentFormat.OpenXml.Spreadsheet.Sheet;
using XlsxRow = DocumentFormat.OpenXml.Spreadsheet.Row;
using XlsxCell = DocumentFormat.OpenXml.Spreadsheet.Cell;
using XlsxSheetData = DocumentFormat.OpenXml.Spreadsheet.SheetData;
using CellValues = DocumentFormat.OpenXml.Spreadsheet.CellValues;
using SharedStringTable = DocumentFormat.OpenXml.Spreadsheet.SharedStringTable;

namespace MathSphere
{
    public partial class studentEnroll : System.Web.UI.Page
    {
        private readonly string cs = System.Configuration.ConfigurationManager
            .ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCourses();
                BindStudents();
                BindWizards();
            }
        }

        private string GetTeacherId() => Session["userID"]?.ToString() ?? "";

        // Courses
        private void BindCourses()
        {
            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    SELECT courseID, courseName
                    FROM   dbo.courseTable
                    WHERE  teacherID = @tid
                    ORDER  BY courseName", conn))
                {
                    cmd.Parameters.AddWithValue("@tid", GetTeacherId());
                    conn.Open();

                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    ddlCourse.Items.Clear();
                    ddlCourse.Items.Add(new ListItem("-- Select Course --", ""));
                    foreach (DataRow r in dt.Rows)
                        ddlCourse.Items.Add(new ListItem(r["courseName"].ToString(), r["courseID"].ToString()));

                    rptCourseFilter.DataSource = dt;
                    rptCourseFilter.DataBind();
                }
            }
            catch (Exception ex) { ShowAlert("Error loading courses: " + ex.Message); }
        }

        // Enrolled students roster
        private void BindStudents()
        {
            try
            {
                const string sql = @"
                    ;WITH BestAttempts AS
                    (
                        SELECT
                            aa.userID,
                            aa.assessmentID,
                            MAX(CASE WHEN a.totalMarks > 0
                                THEN CAST(aa.score AS DECIMAL(10,2)) / a.totalMarks * 100.0
                                ELSE 0 END) AS BestPct
                        FROM  dbo.assessmentAttemptTable aa
                        JOIN  dbo.assessmentTable        a  ON a.assessmentID = aa.assessmentID
                        GROUP BY aa.userID, aa.assessmentID
                    ),
                    StudentAvgScore AS
                    (
                        SELECT
                            ba.userID,
                            a.courseID,
                            CAST(AVG(ba.BestPct) AS DECIMAL(5,2)) AS AvgScore
                        FROM  BestAttempts ba
                        JOIN  dbo.assessmentTable a ON a.assessmentID = ba.assessmentID
                        GROUP BY ba.userID, a.courseID
                    ),
                    TotalAssessments AS
                    (
                        SELECT courseID, COUNT(*) AS TotalCount
                        FROM   dbo.assessmentTable
                        WHERE  isPublished = 1
                        GROUP  BY courseID
                    ),
                    AttemptedAssessments AS
                    (
                        SELECT
                            aa.userID,
                            a.courseID,
                            COUNT(DISTINCT aa.assessmentID) AS AttemptedCount
                        FROM  dbo.assessmentAttemptTable aa
                        JOIN  dbo.assessmentTable        a ON a.assessmentID = aa.assessmentID
                        WHERE a.isPublished = 1
                        GROUP BY aa.userID, a.courseID
                    ),
                    StudentProgress AS
                    (
                        SELECT
                            e.userID,
                            e.courseID,
                            CASE WHEN ta.TotalCount > 0
                                THEN CAST(ISNULL(att.AttemptedCount, 0) AS DECIMAL(10,2))
                                     / ta.TotalCount * 100.0
                                ELSE 0
                            END AS Progress
                        FROM  dbo.studentEnrolmentTable e
                        JOIN  TotalAssessments          ta  ON ta.courseID  = e.courseID
                        LEFT JOIN AttemptedAssessments  att ON att.userID   = e.userID
                                                           AND att.courseID = e.courseID
                    )
                    SELECT
                        e.enrolmentID,
                        u.userID,
                        u.fullName                              AS StudentName,
                        ISNULL(u.AvatarUrl, '')                 AS AvatarUrl,
                        c.courseName,
                        e.enrolStatus,
                        CAST(ISNULL(sp.Progress, 0) AS INT)     AS Progress,
                        CAST(ISNULL(sa.AvgScore,  0) AS INT)    AS AvgScore,
                        CASE WHEN e.enrolStatus = 1 THEN 1 ELSE 0 END AS IsActive
                    FROM   dbo.studentEnrolmentTable e
                    JOIN   dbo.userTable             u  ON u.userID   = e.userID
                    JOIN   dbo.courseTable           c  ON c.courseID = e.courseID
                    LEFT JOIN StudentAvgScore        sa ON sa.userID  = e.userID
                                                      AND sa.courseID = e.courseID
                    LEFT JOIN StudentProgress        sp ON sp.userID  = e.userID
                                                      AND sp.courseID = e.courseID
                    WHERE  c.teacherID     = @tid
                      AND  u.accountStatus = 1
                    ORDER  BY u.fullName, c.courseName";

                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@tid", GetTeacherId());
                    conn.Open();

                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    litShowing.Text = litTotal.Text = dt.Rows.Count.ToString();
                    rptStudents.DataSource = dt;
                    rptStudents.DataBind();
                }
            }
            catch (Exception ex) { ShowAlert("Error loading students: " + ex.Message); }
        }

        protected void rptStudents_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row = (DataRowView)e.Item.DataItem;
            var litRow = (Literal)e.Item.FindControl("litRow");

            string enrolId = He(row["enrolmentID"].ToString());
            string sid = He(row["userID"].ToString());
            string name = He(row["StudentName"].ToString());
            string course = He(row["courseName"].ToString());
            int score = Convert.ToInt32(row["AvgScore"]);
            int progress = Convert.ToInt32(row["Progress"]);
            bool active = Convert.ToInt32(row["IsActive"]) == 1;
            string avatar = row["AvatarUrl"].ToString();

            score = Math.Max(0, Math.Min(100, score));
            progress = Math.Max(0, Math.Min(100, progress));

            string scoreBg, scoreFg, icon;
            if (score >= 80) { scoreBg = "#84cc16"; scoreFg = "white"; icon = "trending_up"; }
            else if (score >= 60) { scoreBg = "#f9d006"; scoreFg = "#1e3a8a"; icon = "horizontal_rule"; }
            else { scoreBg = "#f87171"; scoreFg = "white"; icon = "trending_down"; }

            string perf = progress >= 90 ? "Outstanding"
                        : progress >= 70 ? "Excellent"
                        : progress >= 50 ? "On Track"
                        : progress >= 30 ? "Needs Help" : "At Risk";

            string[] pal = {
                "bg-math-blue/10 text-math-blue",
                "bg-primary/10 text-yellow-700",
                "bg-math-green/10 text-math-green",
                "bg-purple-100 text-purple-600"
            };

            string stClass = active
                ? "inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-math-green/10 text-math-green text-[10px] font-black uppercase tracking-widest"
                : "inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-gray-100 text-gray-400 text-[10px] font-black uppercase tracking-widest";
            string dot = active ? "size-2 rounded-full bg-math-green" : "size-2 rounded-full bg-gray-300";
            string stTxt = active ? "Active" : "Inactive";

            string avatarHtml = string.IsNullOrEmpty(avatar)
                ? @"<div class=""w-full h-full flex items-center justify-center bg-math-blue/10""><span class=""material-symbols-outlined text-math-blue text-xl fill-icon"">person</span></div>"
                : $@"<img src=""{He(avatar)}"" alt=""{name}"" class=""w-full h-full object-cover""/>";

            litRow.Text = $@"
<tr class=""hover:bg-gray-50/50 transition-colors"">
  <td class=""px-8 py-6"">
    <div class=""flex items-center gap-4"">
      <div class=""size-12 rounded-2xl overflow-hidden border-2 border-math-blue/20 flex-shrink-0"">{avatarHtml}</div>
      <div>
        <div class=""font-black text-lg text-math-dark-blue"">{name}</div>
        <div class=""text-xs font-bold text-gray-400 uppercase tracking-tighter"">ID: {sid}</div>
      </div>
    </div>
  </td>
  <td class=""px-6 py-6"">
    <div class=""inline-flex items-center px-3 py-1 rounded-full {pal[Math.Abs(course.GetHashCode()) % pal.Length]} text-xs font-black uppercase tracking-wider"">{course}</div>
  </td>
  <td class=""px-6 py-6"">
    <div class=""inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-sm font-black shadow-sm"" style=""background:{scoreBg};color:{scoreFg}"">
      <span class=""material-symbols-outlined text-sm"">{icon}</span>{score}%
    </div>
  </td>
  <td class=""px-6 py-6"">
    <div class=""flex flex-col gap-1.5 w-40"">
      <div class=""flex justify-between text-[10px] font-black uppercase text-gray-400"">
        <span>{progress}% Complete</span><span class=""text-math-green"">{perf}</span>
      </div>
      <div class=""progress-bar-container""><div class=""progress-bar-fill"" style=""width:{progress}%""></div></div>
    </div>
  </td>
  <td class=""px-6 py-6"">
    <div class=""{stClass}""><span class=""{dot}""></span>{stTxt}</div>
  </td>
  <td class=""px-8 py-6 text-right"">
    <button type=""button"" onclick=""confirmDelete('{enrolId.Trim()}','{name.Replace("'", "\\'")}')""
            class=""p-2 hover:bg-red-50 rounded-xl transition-colors group/btn"">
      <span class=""material-symbols-outlined text-gray-400 group-hover/btn:text-red-500"">delete</span>
    </button>
  </td>
</tr>";
        }

        // Wizards: ALL active students
        private void BindWizards()
        {
            try
            {
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();

                    var dtStudents = new DataTable();
                    using (var cmd = new SqlCommand(@"
                        SELECT u.userID, u.fullName, ISNULL(u.AvatarUrl,'') AS AvatarUrl
                        FROM   dbo.userTable u
                        JOIN   dbo.userRoleTable ur ON ur.userID = u.userID
                        JOIN   dbo.Role r           ON r.roleID  = ur.roleID
                        WHERE  u.accountStatus = 1
                          AND  RTRIM(r.roleName) = 'Student'
                        ORDER  BY u.fullName", conn))
                    {
                        new SqlDataAdapter(cmd).Fill(dtStudents);
                    }

                    var dtEnrolled = new DataTable();
                    using (var cmd = new SqlCommand(@"
                        SELECT e.userID, c.courseName
                        FROM   dbo.studentEnrolmentTable e
                        JOIN   dbo.courseTable c ON c.courseID = e.courseID
                        WHERE  c.teacherID = @tid", conn))
                    {
                        cmd.Parameters.AddWithValue("@tid", GetTeacherId());
                        new SqlDataAdapter(cmd).Fill(dtEnrolled);
                    }

                    var enrolledCourses = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
                    foreach (DataRow r in dtEnrolled.Rows)
                    {
                        string uid = r["userID"].ToString();
                        if (!enrolledCourses.ContainsKey(uid))
                            enrolledCourses[uid] = new List<string>();
                        enrolledCourses[uid].Add(r["courseName"].ToString());
                    }

                    dtStudents.Columns.Add("EnrolledCourses", typeof(string));
                    foreach (DataRow r in dtStudents.Rows)
                    {
                        string uid = r["userID"].ToString();
                        r["EnrolledCourses"] = enrolledCourses.ContainsKey(uid)
                            ? string.Join(", ", enrolledCourses[uid])
                            : "";
                    }

                    rptWizards.DataSource = dtStudents;
                    rptWizards.DataBind();
                }
            }
            catch (Exception ex) { ShowAlert("Error loading wizards: " + ex.Message); }
        }

        protected void rptWizards_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row = (DataRowView)e.Item.DataItem;
            var lit = (Literal)e.Item.FindControl("litWizardRow");

            string wid = He(row["userID"].ToString());
            string name = He(row["fullName"].ToString());
            string avatar = row["AvatarUrl"].ToString();
            string enrolledIn = row["EnrolledCourses"].ToString();

            string avatarHtml = string.IsNullOrEmpty(avatar)
                ? @"<div class=""w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center""><span class=""material-symbols-outlined text-math-blue fill-icon"">person</span></div>"
                : $@"<img src=""{He(avatar)}"" alt=""{name}"" class=""w-12 h-12 rounded-full p-1"" style=""background:#e0e7ff;""/>";

            string enrolledBadge = !string.IsNullOrEmpty(enrolledIn)
                ? $@"<p class=""text-[10px] text-math-blue font-bold mt-0.5 truncate max-w-[160px]"" title=""{He(enrolledIn)}"">
                         <span class=""material-symbols-outlined text-[10px] align-middle"">check_circle</span>
                         In: {He(enrolledIn)}
                     </p>"
                : "";

            lit.Text = $@"
<div class=""wizard-row group flex items-center justify-between p-3 rounded-2xl border border-transparent hover:border-blue-200 hover:bg-blue-50/40 transition-all cursor-pointer""
     data-id=""{wid}"" data-selected=""false"" onclick=""toggleWizard(this)"">
  <div class=""flex items-center gap-4"">
    <div class=""relative flex-shrink-0"">{avatarHtml}</div>
    <div class=""min-w-0"">
      <h4 class=""font-bold text-slate-800 leading-none"">{name}</h4>
      <p class=""text-xs text-slate-500 mt-0.5 uppercase tracking-wider font-medium"">ID: {wid}</p>
      {enrolledBadge}
    </div>
  </div>
  <div class=""wizard-check w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all flex-shrink-0""
       style=""border-color:rgba(37,99,235,0.3);""></div>
</div>";
        }

        // Manual enrol
        protected void btnSubmitEnrol_Click(object sender, EventArgs e)
        {
            string courseId = ddlCourse.SelectedValue;
            string ids = hdnSelectedWizards.Value;

            if (string.IsNullOrEmpty(courseId)) { ShowAlert("Please select a course."); return; }
            if (string.IsNullOrEmpty(ids)) { ShowAlert("Please select at least one student."); return; }

            string teacherName = GetTeacherName();
            string courseName = ddlCourse.SelectedItem?.Text ?? "";

            int ok = 0, skip = 0;
            var errorLines = new StringBuilder();

            foreach (string uid in ids.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                var r = TryEnrol(uid.Trim(), courseId, out string msg);
                if (r == EnrolResult.Success)
                {
                    ok++;
                    SendEnrollmentEmail(uid.Trim(), courseName, teacherName);
                }
                else
                {
                    skip++;
                    string ico = r == EnrolResult.AlreadyEnrolled ? "?" : "?";
                    string cls = r == EnrolResult.AlreadyEnrolled ? "text-slate-400" : "text-red-600";
                    errorLines.Append($@"<p class=""text-xs {cls} py-0.5"">{ico} <span class=""font-mono"">{He(uid.Trim())}</span> — {He(msg)}</p>");
                }
            }

            ShowSuccessModal(ok, skip, errorLines.ToString());
            BindStudents();
            BindWizards();
        }

        // Bulk enrol (CSV / XLSX)
        protected void btnBulkEnrol_Click(object sender, EventArgs e)
        {
            if (!fuBulk.HasFile) { ShowAlert("Please select a CSV or XLSX file."); return; }

            string courseId = ddlCourse.SelectedValue;
            if (string.IsNullOrEmpty(courseId)) { ShowAlert("Please select a course first."); return; }

            string ext = Path.GetExtension(fuBulk.FileName).ToLowerInvariant();
            if (ext != ".csv" && ext != ".xlsx") { ShowAlert("Only .csv or .xlsx files are supported."); return; }

            List<string> emails;
            try
            {
                emails = ext == ".csv"
                    ? ParseEmailsCsv(fuBulk.FileContent)
                    : ParseEmailsXlsx(fuBulk.FileContent);
            }
            catch (Exception ex) { ShowAlert("Could not read file: " + ex.Message); return; }

            emails = emails
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Select(x => x.Trim().ToLowerInvariant())
                .Distinct()
                .ToList();

            if (emails.Count == 0)
            {
                ShowAlert("No emails found. Make sure your file has an 'email' column header.");
                return;
            }

            string teacherName = GetTeacherName();
            string courseName = ddlCourse.SelectedItem?.Text ?? "";

            int ok = 0, skip = 0;
            var errorLines = new StringBuilder();

            foreach (string email in emails)
            {
                string userId = FindUserIdByEmail(email);
                if (userId == null)
                {
                    skip++;
                    errorLines.Append($@"<p class=""text-xs text-orange-600 py-0.5"">? <span class=""font-mono"">{He(email)}</span> — not found / inactive account</p>");
                    continue;
                }

                var result = TryEnrol(userId, courseId, out string msg);
                if (result == EnrolResult.Success)
                {
                    ok++;
                    var info = GetStudentInfo(userId);
                    if (info != null)
                        EmailService.SendCourseEnrollment(info.Email, info.FullName, courseName, teacherName);
                }
                else
                {
                    skip++;
                    string ico = result == EnrolResult.AlreadyEnrolled ? "?" : "?";
                    string cls = result == EnrolResult.AlreadyEnrolled ? "text-slate-400" : "text-red-500";
                    errorLines.Append($@"<p class=""text-xs {cls} py-0.5"">{ico} <span class=""font-mono"">{He(email)}</span> — {He(msg)}</p>");
                }
            }

            ShowSuccessModal(ok, skip, errorLines.ToString());
            BindStudents();
            BindWizards();
        }

        // Send enrollment email helper
        private void SendEnrollmentEmail(string userId, string courseName, string teacherName)
        {
            try
            {
                var info = GetStudentInfo(userId);
                if (info != null)
                    EmailService.SendCourseEnrollment(info.Email, info.FullName, courseName, teacherName);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Enrollment email error: " + ex.Message);
            }
        }

        // Fetch student email + name by userId
        private class StudentInfo { public string Email; public string FullName; }

        private StudentInfo GetStudentInfo(string userId)
        {
            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(
                    "SELECT email, fullName FROM dbo.userTable WHERE userID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                            return new StudentInfo
                            {
                                Email = rdr["email"].ToString(),
                                FullName = rdr["fullName"].ToString()
                            };
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("GetStudentInfo error: " + ex.Message);
            }
            return null;
        }

        // Fetch logged-in teacher's full name
        private string GetTeacherName()
        {
            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(
                    "SELECT fullName FROM dbo.userTable WHERE userID = @tid", conn))
                {
                    cmd.Parameters.AddWithValue("@tid", GetTeacherId());
                    conn.Open();
                    var val = cmd.ExecuteScalar();
                    return val?.ToString() ?? "Your Instructor";
                }
            }
            catch { return "Your Instructor"; }
        }

        // Find userID by email
        private string FindUserIdByEmail(string email)
        {
            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    SELECT userID FROM dbo.userTable
                    WHERE  LOWER(email) = @email AND accountStatus = 1", conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);
                    conn.Open();
                    var val = cmd.ExecuteScalar();
                    return (val != null && val != DBNull.Value) ? val.ToString() : null;
                }
            }
            catch { return null; }
        }

        // Enrol one student
        private enum EnrolResult { Success, AlreadyEnrolled, Failed }

        private EnrolResult TryEnrol(string userId, string courseId, out string message)
        {
            message = "Enrolment failed.";
            try
            {
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction(IsolationLevel.Serializable))
                    {
                        using (var chk = new SqlCommand(
                            "SELECT COUNT(*) FROM dbo.studentEnrolmentTable WHERE userID=@uid AND courseID=@cid",
                            conn, tx))
                        {
                            chk.Parameters.AddWithValue("@uid", userId);
                            chk.Parameters.AddWithValue("@cid", courseId);
                            if ((int)chk.ExecuteScalar() > 0)
                            {
                                message = "already enrolled in this course";
                                tx.Commit();
                                return EnrolResult.AlreadyEnrolled;
                            }
                        }

                        int nextNum;
                        using (var idCmd = new SqlCommand(@"
                            SELECT ISNULL(MAX(CAST(SUBSTRING(RTRIM(enrolmentID),2,10) AS INT)),0)+1
                            FROM   dbo.studentEnrolmentTable WITH (UPDLOCK,HOLDLOCK)
                            WHERE  RTRIM(enrolmentID) LIKE 'E[0-9]%';", conn, tx))
                        {
                            var r = idCmd.ExecuteScalar();
                            nextNum = (r == null || r == DBNull.Value) ? 1 : Convert.ToInt32(r);
                        }

                        string newId = "E" + nextNum.ToString("D3");

                        using (var ins = new SqlCommand(@"
                            INSERT INTO dbo.studentEnrolmentTable
                                (enrolmentID,userID,courseID,enrolDate,enrolStatus,completionPercentage)
                            VALUES (@eid,@uid,@cid,SYSUTCDATETIME(),1,0);", conn, tx))
                        {
                            ins.Parameters.AddWithValue("@eid", newId);
                            ins.Parameters.AddWithValue("@uid", userId);
                            ins.Parameters.AddWithValue("@cid", courseId);
                            ins.ExecuteNonQuery();
                        }

                        tx.Commit();
                        message = "enrolled";
                        return EnrolResult.Success;
                    }
                }
            }
            catch (SqlException ex) { message = ex.Message; return EnrolResult.Failed; }
            catch (Exception ex) { message = ex.Message; return EnrolResult.Failed; }
        }

        // Parse CSV
        private List<string> ParseEmailsCsv(Stream stream)
        {
            var result = new List<string>();
            if (stream.CanSeek) stream.Position = 0;

            using (var reader = new StreamReader(stream, Encoding.UTF8, true))
            {
                string headerLine = reader.ReadLine();
                if (headerLine == null) return result;

                string[] headers = SplitCsvRow(headerLine);
                int emailIdx = Array.FindIndex(headers,
                    h => h.Trim().Equals("email", StringComparison.OrdinalIgnoreCase));
                if (emailIdx < 0)
                    throw new Exception("Column 'email' not found.");

                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    if (string.IsNullOrWhiteSpace(line)) continue;
                    string[] cols = SplitCsvRow(line);
                    if (emailIdx < cols.Length && !string.IsNullOrWhiteSpace(cols[emailIdx]))
                        result.Add(cols[emailIdx].Trim());
                }
            }
            return result;
        }

        private string[] SplitCsvRow(string line)
        {
            var fields = new List<string>();
            bool inQ = false; var cur = new StringBuilder();
            foreach (char c in line)
            {
                if (c == '"') inQ = !inQ;
                else if (c == ',' && !inQ) { fields.Add(cur.ToString()); cur.Clear(); }
                else cur.Append(c);
            }
            fields.Add(cur.ToString());
            return fields.ToArray();
        }

        // Parse XLSX
        private List<string> ParseEmailsXlsx(Stream stream)
        {
            var result = new List<string>();
            byte[] buf;
            using (var ms = new MemoryStream()) { stream.CopyTo(ms); buf = ms.ToArray(); }

            using (var ms = new MemoryStream(buf))
            using (var doc = SpreadsheetDocument.Open(ms, false))
            {
                var wbPart = doc.WorkbookPart;
                var sheet = wbPart.Workbook.Sheets.GetFirstChild<XlsxSheet>();
                var wsPart = (WorksheetPart)wbPart.GetPartById(sheet.Id);
                var rows = wsPart.Worksheet.GetFirstChild<XlsxSheetData>().Elements<XlsxRow>();
                var sst = wbPart.SharedStringTablePart?.SharedStringTable;

                bool firstRow = true; int emailColIdx = -1;

                foreach (var row in rows)
                {
                    var map = new Dictionary<int, string>();
                    foreach (var cell in row.Elements<XlsxCell>())
                    {
                        int ci = GetColumnIndex(cell.CellReference?.Value);
                        if (ci >= 0) map[ci] = GetCellText(cell, sst);
                    }

                    if (firstRow)
                    {
                        firstRow = false;
                        foreach (var kv in map)
                            if ((kv.Value ?? "").Trim().Equals("email", StringComparison.OrdinalIgnoreCase))
                            { emailColIdx = kv.Key; break; }
                        if (emailColIdx < 0)
                            throw new Exception("Column 'email' not found in row 1 of the XLSX file.");
                        continue;
                    }

                    if (emailColIdx >= 0 && map.TryGetValue(emailColIdx, out string emailVal)
                        && !string.IsNullOrWhiteSpace(emailVal))
                        result.Add(emailVal.Trim());
                }
            }
            return result;
        }

        private static int GetColumnIndex(string cellRef)
        {
            if (string.IsNullOrWhiteSpace(cellRef)) return -1;
            int i = 0;
            while (i < cellRef.Length && char.IsLetter(cellRef[i])) i++;
            string col = cellRef.Substring(0, i).ToUpperInvariant();
            int sum = 0;
            foreach (char c in col) sum = sum * 26 + (c - 'A' + 1);
            return sum - 1;
        }

        private static string GetCellText(XlsxCell cell, SharedStringTable sst)
        {
            if (cell == null) return "";
            if (cell.DataType != null && cell.DataType.Value == CellValues.InlineString)
                return cell.InlineString?.Text?.Text?.Trim() ?? "";
            string raw = cell.CellValue?.Text ?? "";
            if (cell.DataType != null && cell.DataType.Value == CellValues.SharedString
                && sst != null && int.TryParse(raw, out int idx) && idx >= 0 && idx < sst.ChildElements.Count)
                return sst.ChildElements[idx].InnerText.Trim();
            return raw.Trim();
        }

        // Delete (unenrol)
        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string enrolmentId = hdnDeleteStudentId.Value.Trim();
            if (string.IsNullOrEmpty(enrolmentId)) return;

            try
            {
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(
                    "DELETE FROM dbo.studentEnrolmentTable WHERE enrolmentID=@eid", conn))
                {
                    cmd.Parameters.AddWithValue("@eid", enrolmentId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "CloseDelete",
                    "closeDeleteModal(); showToast('Student removed from roster.');", true);

                BindStudents();
                BindWizards();
            }
            catch (Exception ex) { ShowAlert("Error removing student: " + ex.Message); }
        }

        // ShowSuccessModal
        private void ShowSuccessModal(int ok, int skip, string errorHtml)
        {
            string summaryMsg;
            if (ok > 0 && skip == 0)
                summaryMsg = $"{ok} student{(ok == 1 ? "" : "s")} enrolled successfully.";
            else if (ok > 0 && skip > 0)
                summaryMsg = $"{ok} enrolled. {skip} skipped — not found in system or already enrolled.";
            else if (ok == 0 && skip > 0)
                summaryMsg = $"No students enrolled. {skip} skipped — emails not found in system or already enrolled.";
            else
                summaryMsg = "No students were enrolled.";

            litSuccessCount.Text = summaryMsg;
            litSuccessNum.Text = ok.ToString();
            litErrorNum.Text = skip.ToString();
            Literal1.Text = skip.ToString();
            litErrorDetail.Text = errorHtml;

            bool hasErrors = !string.IsNullOrEmpty(errorHtml);
            string showErr = hasErrors
                ? "document.getElementById('errorDetailWrap').classList.remove('hidden');"
                : "document.getElementById('errorDetailWrap').classList.add('hidden');";

            string toastMsg = summaryMsg.Replace("'", "\\'");

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowSuccess", $@"
        document.addEventListener('DOMContentLoaded', function() {{
            var enrol = document.getElementById('enrolOverlay');
            if (enrol) enrol.classList.add('hidden');

            var success = document.getElementById('successOverlay');
            if (success) success.classList.remove('hidden');

            var errWrap = document.getElementById('errorDetailWrap');
            if (errWrap) {{ {showErr} }}

            showToast('{toastMsg}', 8000);
        }});
    ", true);
        }

        // Helpers
        private static string He(string s) => System.Web.HttpUtility.HtmlEncode(s ?? "");

        private void ShowAlert(string msg) =>
            ScriptManager.RegisterStartupScript(this, GetType(), "Alert",
                $"alert('{(msg ?? "").Replace("'", "\\'")}');", true);
    }
}
