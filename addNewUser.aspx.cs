using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.UI;

namespace MathSphere
{
    public partial class addNewUser : System.Web.UI.Page
    {
        private string connectionString =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsAdmin"] == null || !(bool)Session["IsAdmin"])
            {
                Response.Redirect("Login.aspx", true);
                return;
            }
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            string first = (txtFirst.Text ?? "").Trim();
            string last = (txtLast.Text ?? "").Trim();
            string email = (txtEmail.Text ?? "").Trim().ToLowerInvariant();
            string pwd = txtPassword.Text ?? "";
            string role = (ddlRole.SelectedValue ?? "").Trim();

            if (string.IsNullOrWhiteSpace(role)) { ShowError("Please select a role."); return; }
            if (string.IsNullOrWhiteSpace(first) || string.IsNullOrWhiteSpace(last))
            { ShowError("Please enter the full name."); return; }
            if (string.IsNullOrWhiteSpace(email) || !email.Contains("@"))
            { ShowError("Please enter a valid email address."); return; }
            if (pwd.Length < 8) { ShowError("Password must be at least 8 characters."); return; }

            bool accountStatus = true;
            bool.TryParse(hdnActiveStatus.Value, out accountStatus);

            string fullName = first + " " + last;

            // Keep redirect handling separate so save errors still surface clearly.
            bool redirecting = false;
            try
            {
                SaveUser(fullName, email, role, pwd, accountStatus);
                redirecting = true;
            }
            catch (ThreadAbortException)
            {
                // Response.Redirect(..., true) ends the request with ThreadAbortException.
                throw;
            }
            catch (Exception ex)
            {
                // Show the actual save error.
                ShowError(ex.Message);
                return;
            }

            if (redirecting)
            {
                // Redirect after the save succeeds.
                Response.Redirect(
                    "userManagement.aspx?added=1&name=" + Uri.EscapeDataString(fullName),
                    true);
            }
        }

        private void SaveUser(string fullName, string email, string role, string password, bool isActive)
        {
            string hashedPwd = HashPasswordSha256(password);

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();

                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        // Prevent duplicate email addresses.
                        using (var check = new SqlCommand(@"
                            SELECT COUNT(1)
                            FROM   dbo.userTable
                            WHERE  LOWER(email) = LOWER(@Email)
                              AND  ISNULL(isDeleted,0) = 0;", conn, tx))
                        {
                            check.Parameters.Add("@Email", SqlDbType.NVarChar, 50).Value = email;
                            int exists = Convert.ToInt32(check.ExecuteScalar(), CultureInfo.InvariantCulture);
                            if (exists > 0)
                                throw new Exception("Email already exists. Please use a different email.");
                        }

                        // Generate the next user ID inside the transaction.
                        string newUserId = GenerateUserIdLocked(conn, tx, role);

                        // Insert the user record.
                        using (var cmd = new SqlCommand(@"
                            INSERT INTO dbo.userTable
                                (userID, fullName, email, passwordHash, accountStatus, CreatedAt, isDeleted)
                            VALUES
                                (@userID, @FullName, @Email, @PasswordHash, @accountStatus, SYSUTCDATETIME(), 0);",
                            conn, tx))
                        {
                            cmd.Parameters.Add("@userID", SqlDbType.NVarChar, 10).Value = newUserId;
                            cmd.Parameters.Add("@FullName", SqlDbType.NVarChar, 50).Value = fullName;
                            cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 50).Value = email;
                            cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 255).Value = hashedPwd;
                            cmd.Parameters.Add("@accountStatus", SqlDbType.Bit).Value = isActive;
                            cmd.ExecuteNonQuery();
                        }

                        // Link the user to the selected role.
                        string roleId = GetRoleIdByName(conn, tx, role);

                        using (var cmdRole = new SqlCommand(@"
                            INSERT INTO dbo.userRoleTable (userID, roleID)
                            VALUES (@uid, @rid);", conn, tx))
                        {
                            cmdRole.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = newUserId;
                            cmdRole.Parameters.Add("@rid", SqlDbType.NVarChar, 10).Value = roleId;
                            cmdRole.ExecuteNonQuery();
                        }

                        // Log the creation event.
                        using (var logCmd = new SqlCommand(@"
                            INSERT INTO dbo.SysActivityLogTable
                                (EventType, Description, CreatedAt, Status, Priority)
                            VALUES
                                (@type, @desc, SYSUTCDATETIME(), @status, @priority);", conn, tx))
                        {
                            logCmd.Parameters.Add("@type", SqlDbType.NVarChar, 50).Value = "USER_CREATE";
                            logCmd.Parameters.Add("@desc", SqlDbType.NVarChar, 0).Value =
                                $"Created user {fullName} ({newUserId}) email={email} role={role}";
                            logCmd.Parameters.Add("@status", SqlDbType.NVarChar, 20).Value = "INFO";
                            logCmd.Parameters.Add("@priority", SqlDbType.NVarChar, 20).Value = "LOW";
                            logCmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;           // re-throw so btnCreate_Click can display the real message
                    }
                }
            }
        }

        private string GenerateUserIdLocked(SqlConnection conn, SqlTransaction tx, string role)
        {
            string prefix;
            switch ((role ?? "").Trim().ToLowerInvariant())
            {
                case "teacher": prefix = "T"; break;
                case "student": prefix = "S"; break;
                case "admin": prefix = "A"; break;
                default: throw new Exception("Invalid role selected.");
            }

            using (var cmd = new SqlCommand(@"
                SELECT TOP 1 userID
                FROM   dbo.userTable WITH (UPDLOCK, HOLDLOCK)
                WHERE  userID LIKE @pfx + '%'
                ORDER  BY userID DESC;", conn, tx))
            {
                cmd.Parameters.Add("@pfx", SqlDbType.NVarChar, 1).Value = prefix;
                object result = cmd.ExecuteScalar();

                if (result == null || result == DBNull.Value)
                    return prefix + "00001";

                string lastId = Convert.ToString(result, CultureInfo.InvariantCulture);
                int number = int.Parse(lastId.Substring(1), CultureInfo.InvariantCulture) + 1;
                return prefix + number.ToString("D5", CultureInfo.InvariantCulture);
            }
        }

        private string GetRoleIdByName(SqlConnection conn, SqlTransaction tx, string roleName)
        {
            using (var cmd = new SqlCommand(@"
                SELECT TOP 1 roleID
                FROM   dbo.Role
                WHERE  LOWER(roleName) = LOWER(@name);", conn, tx))
            {
                cmd.Parameters.Add("@name", SqlDbType.NVarChar, 50).Value = roleName ?? "";
                object o = cmd.ExecuteScalar();

                if (o == null || o == DBNull.Value)
                    throw new Exception("Role not found in Role table: " + roleName);

                return Convert.ToString(o, CultureInfo.InvariantCulture);
            }
        }

        private static string HashPasswordSha256(string password)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password ?? ""));
                return Convert.ToBase64String(bytes);
            }
        }

        private void ShowError(string message)
        {
            string script = string.Format(
                "document.getElementById('formError').textContent='{0}';" +
                "document.getElementById('formError').classList.remove('hidden');",
                (message ?? "").Replace("'", "\\'")
            );
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowError", script, true);
        }
    }
}
