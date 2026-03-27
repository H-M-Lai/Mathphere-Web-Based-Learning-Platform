using Google.Apis.Auth;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace MathSphere
{
    public partial class GoogleCallback : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(PageLoadAsync));
        }

        private async System.Threading.Tasks.Task PageLoadAsync()
        {
            string code = Request.QueryString["code"];
            string state = Request.QueryString["state"];

            System.Diagnostics.Debug.WriteLine($"=== GOOGLE CALLBACK ===");
            System.Diagnostics.Debug.WriteLine($"code:  {code}");
            System.Diagnostics.Debug.WriteLine($"state: {state}");
            System.Diagnostics.Debug.WriteLine($"URL:   {Request.Url}");

            if (string.IsNullOrWhiteSpace(code))
            {
                System.Diagnostics.Debug.WriteLine("ERROR: No code received");
                Redirect(GetReturnPage(state), "Google sign-in was cancelled.");
                return;
            }

            try
            {
                string clientId = ConfigurationManager.AppSettings["GoogleClientId"];
                string clientSecret = ConfigurationManager.AppSettings["GoogleClientSecret"];
                string redirectUri = ConfigurationManager.AppSettings["GoogleRedirectUri"];

                System.Diagnostics.Debug.WriteLine($"redirectUri: {redirectUri}");

                string tokenJson = await ExchangeCodeForToken(code, clientId, clientSecret, redirectUri);
                System.Diagnostics.Debug.WriteLine($"tokenJson null? {tokenJson == null}");
                System.Diagnostics.Debug.WriteLine($"tokenJson: {tokenJson}");
                if (tokenJson == null)
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: Token exchange failed");
                    Redirect(GetReturnPage(state), "Google sign-in failed. Please try again.");
                    return;
                }

                dynamic tokenData = new System.Web.Script.Serialization.JavaScriptSerializer()
                    .DeserializeObject(tokenJson);
                string idToken = tokenData["id_token"];
                System.Diagnostics.Debug.WriteLine($"idToken null? {idToken == null}");

                GoogleJsonWebSignature.Payload payload =
                    await GoogleJsonWebSignature.ValidateAsync(idToken,
                        new GoogleJsonWebSignature.ValidationSettings
                        {
                            Audience = new List<string> { clientId }
                        });

                string googleEmail = payload.Email?.Trim().ToLower();
                string googleName = payload.Name ?? googleEmail;
                System.Diagnostics.Debug.WriteLine($"googleEmail: {googleEmail}");
                System.Diagnostics.Debug.WriteLine($"googleName:  {googleName}");
                System.Diagnostics.Debug.WriteLine($"state: {state}");

                if (string.IsNullOrWhiteSpace(googleEmail))
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: No email from Google");
                    Redirect(GetReturnPage(state), "Could not retrieve email from Google.");
                    return;
                }

                if (!googleEmail.EndsWith("@gmail.com", StringComparison.OrdinalIgnoreCase))
                {
                    System.Diagnostics.Debug.WriteLine($"ERROR: Not gmail: {googleEmail}");
                    Redirect(GetReturnPage(state), "Only Gmail (@gmail.com) accounts are allowed.");
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"Routing: state={state}");

                if (state == "login")
                {
                    System.Diagnostics.Debug.WriteLine($"Calling HandleLogin for {googleEmail}");
                    HandleLogin(googleEmail);
                }
                else
                {
                    string role = state == "teacher" ? "Teacher" : "Student";
                    System.Diagnostics.Debug.WriteLine($"Calling HandleRegister for {googleEmail} as {role}");
                    HandleRegister(googleEmail, googleName, role);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"EXCEPTION: {ex.GetType().Name}: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"STACK: {ex.StackTrace}");
                Redirect(GetReturnPage(state), "Google sign-in failed. Please try again.");
            }
        }

        private void HandleLogin(string email)
        {
            System.Diagnostics.Debug.WriteLine($"HandleLogin called with: {email}");

            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
        SELECT u.userID, u.fullName, u.accountStatus,
               ISNULL(u.isDeleted,0) AS isDeleted,
               RTRIM(r.roleName) AS roleName
        FROM   dbo.userTable u
        LEFT JOIN dbo.userRoleTable ur ON RTRIM(ur.userID) = RTRIM(u.userID)
        LEFT JOIN dbo.Role r           ON RTRIM(r.roleID)  = RTRIM(ur.roleID)
        WHERE  LOWER(RTRIM(LTRIM(u.email))) = @email", conn))
            {
                cmd.Parameters.AddWithValue("@email", email);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    System.Diagnostics.Debug.WriteLine($"Query executed, has rows: {r.HasRows}");

                    if (!r.Read())
                    {
                        r.Close();
                        System.Diagnostics.Debug.WriteLine($"ERROR: No user found for email: {email}");
                        Redirect("Login.aspx", "No account found. Please register first.");
                        return;
                    }

                    string userId = r["userID"].ToString().Trim();
                    string fullName = r["fullName"].ToString();
                    bool isActive = Convert.ToBoolean(r["accountStatus"]);
                    bool isDeleted = Convert.ToBoolean(r["isDeleted"]);
                    string roleName = r["roleName"]?.ToString()?.Trim() ?? "Student";
                    r.Close();

                    System.Diagnostics.Debug.WriteLine($"Found user: {userId}, {fullName}, role={roleName}, active={isActive}, deleted={isDeleted}");

                    if (isDeleted)
                    { Redirect("Login.aspx", "This account has been permanently deleted."); return; }

                    if (!isActive)
                    { Redirect("Login.aspx", "Your account has been disabled by an administrator."); return; }

                    Session["UserID"] = userId;
                    Session["FullName"] = fullName;
                    Session["RoleName"] = roleName;
                    Session["IsAdmin"] = roleName.Equals("Admin", StringComparison.OrdinalIgnoreCase);

                    System.Diagnostics.Debug.WriteLine($"Session set, redirecting to dashboard for role: {roleName}");

                    switch (roleName.ToLower())
                    {
                        case "admin": Response.Redirect("~/adminDashboard.aspx", false); break;
                        case "teacher": Response.Redirect("~/teacherDashboard.aspx", false); break;
                        default: Response.Redirect("~/studentDashboard.aspx", false); break;
                    }
                    Context.ApplicationInstance.CompleteRequest();
                }
            }
        }

        private void HandleRegister(string email, string fullName, string role)
        {
            // If account already exists, just log them in
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.userTable WHERE LOWER(email)=@email AND ISNULL(isDeleted,0)=0", conn))
            {
                cmd.Parameters.AddWithValue("@email", email);
                conn.Open();
                if ((int)cmd.ExecuteScalar() > 0)
                {
                    HandleLogin(email);
                    return;
                }
            }

            string userId = GenerateUserId();
            string roleId = GetRoleId(role);

            if (string.IsNullOrEmpty(roleId))
            {
                Redirect(role == "Teacher" ? "teacherRegistration.aspx" : "Register.aspx",
                    "System error: role not configured.");
                return;
            }

            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        using (var cmd = new SqlCommand(@"
            INSERT INTO dbo.userTable
                (userID,fullName,email,passwordHash,accountStatus,CreatedAt,isDeleted)
            VALUES(@uid,@name,@email,'GOOGLE_AUTH',1,SYSUTCDATETIME(),0)", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.Parameters.AddWithValue("@name", fullName);
                            cmd.Parameters.AddWithValue("@email", email);
                            cmd.ExecuteNonQuery();
                        }

                        using (var cmd = new SqlCommand(
                            "INSERT INTO dbo.userRoleTable(userID,roleID) VALUES(@uid,@rid)", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.Parameters.AddWithValue("@rid", roleId);
                            cmd.ExecuteNonQuery();
                        }

                        // AUTO-ENROL into all active courses (Students only)
                        if (role == "Student")
                        {
                            // Get next enrolment number
                            int nextEnrolNum;
                            using (var cmd = new SqlCommand(@"
                SELECT ISNULL(MAX(CAST(SUBSTRING(RTRIM(enrolmentID),2,10) AS INT)),0)+1
                FROM   dbo.studentEnrolmentTable WITH (UPDLOCK,HOLDLOCK)
                WHERE  RTRIM(enrolmentID) LIKE 'E[0-9]%'", conn, tx))
                            {
                                var r = cmd.ExecuteScalar();
                                nextEnrolNum = (r == null || r == DBNull.Value) ? 1 : Convert.ToInt32(r);
                            }

                            // Get all active courses
                            var courseIds = new List<string>();
                            using (var cmd = new SqlCommand(
                                "SELECT courseID FROM dbo.courseTable ORDER BY courseID", conn, tx))
                            using (var dr = cmd.ExecuteReader())
                                while (dr.Read())
                                    courseIds.Add(dr["courseID"].ToString());

                            // Insert one enrolment row per course
                            foreach (var cid in courseIds)
                            {
                                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.studentEnrolmentTable
                        (enrolmentID,userID,courseID,enrolDate,enrolStatus,completionPercentage)
                    VALUES (@eid,@uid,@cid,SYSUTCDATETIME(),1,0)", conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@eid", "E" + nextEnrolNum.ToString("D3"));
                                    cmd.Parameters.AddWithValue("@uid", userId);
                                    cmd.Parameters.AddWithValue("@cid", cid);
                                    cmd.ExecuteNonQuery();
                                    nextEnrolNum++;
                                }
                            }
                        }

                        tx.Commit();
                    }
                    catch { tx.Rollback(); throw; }
                }

                Session["UserID"] = userId;
                Session["FullName"] = fullName;
                Session["RoleName"] = role;
                Session["IsAdmin"] = false;

                Response.Redirect(role == "Teacher" ? "~/teacherDashboard.aspx" : "~/StudentDashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        private string GenerateUserId()
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT ISNULL(MAX(CAST(SUBSTRING(RTRIM(userID),2,LEN(RTRIM(userID))-1) AS INT)),0)+1
                FROM dbo.userTable
                WHERE RTRIM(userID) LIKE 'U[0-9]%'
                  AND ISNUMERIC(SUBSTRING(RTRIM(userID),2,LEN(RTRIM(userID))-1))=1", conn))
            {
                conn.Open();
                return "U" + ((int)cmd.ExecuteScalar()).ToString("D3");
            }
        }

        private string GetRoleId(string roleName)
        {
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(
                "SELECT TOP 1 roleID FROM dbo.Role WHERE RTRIM(roleName)=@name", conn))
            {
                cmd.Parameters.AddWithValue("@name", roleName);
                conn.Open();
                return cmd.ExecuteScalar()?.ToString()?.Trim();
            }
        }

        private string GetReturnPage(string state)
        {
            if (state == "teacher") return "teacherRegistration.aspx";
            if (state == "login") return "Login.aspx";
            return "Register.aspx";
        }

        private void Redirect(string page, string error)
        {
            Response.Redirect($"~/{page}?error={HttpUtility.UrlEncode(error)}", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private async System.Threading.Tasks.Task<string> ExchangeCodeForToken(
            string code, string clientId, string clientSecret, string redirectUri)
        {
            using (var client = new System.Net.Http.HttpClient())
            {
                var content = new System.Net.Http.FormUrlEncodedContent(new[]
                {
                    new KeyValuePair<string,string>("code",          code),
                    new KeyValuePair<string,string>("client_id",     clientId),
                    new KeyValuePair<string,string>("client_secret", clientSecret),
                    new KeyValuePair<string,string>("redirect_uri",  redirectUri),
                    new KeyValuePair<string,string>("grant_type",    "authorization_code"),
                });

                var response = await client.PostAsync("https://oauth2.googleapis.com/token", content);
                if (!response.IsSuccessStatusCode) return null;
                return await response.Content.ReadAsStringAsync();
            }
        }
    }
}
