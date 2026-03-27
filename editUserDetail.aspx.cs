using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;

namespace MathSphere
{
    public partial class editUserDetail : System.Web.UI.Page
    {
        private readonly string connectionString =
            System.Configuration.ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsAdmin"] == null || !(bool)Session["IsAdmin"])
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                string uid = (Request.QueryString["uid"] ?? "").Trim();
                if (string.IsNullOrWhiteSpace(uid))
                {
                    Response.Redirect("userManagement.aspx", true);
                    return;
                }

                hdnUserId.Value = uid;
                LoadUser(uid);
            }
        }

        private void LoadUser(string uid)
        {
            DataRow row = GetUserById(uid);

            if (row == null)
            {
                ShowError("User not found.");
                btnSaveChanges.Enabled = false;
                return;
            }

            txtFullName.Text = Convert.ToString(row["fullName"]);
            txtEmail.Text = Convert.ToString(row["email"]);
            modal_status_toggle.Checked = Convert.ToBoolean(row["accountStatus"]);

            string role = Convert.ToString(row["roleName"] ?? "student").ToLowerInvariant();
            foreach (System.Web.UI.WebControls.ListItem item in ddlRole.Items)
                item.Selected = (item.Value == role);
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            string uid = (hdnUserId.Value ?? "").Trim();
            string name = (txtFullName.Text ?? "").Trim();
            string email = (txtEmail.Text ?? "").Trim();
            string role = (ddlRole.SelectedValue ?? "").Trim();
            bool isActive = modal_status_toggle.Checked;

            if (string.IsNullOrWhiteSpace(uid)) { ShowError("Missing user ID."); return; }
            if (string.IsNullOrWhiteSpace(name)) { ShowError("Full name is required."); return; }
            if (string.IsNullOrWhiteSpace(email)) { ShowError("Email is required."); return; }
            if (!email.Contains("@")) { ShowError("Please enter a valid email."); return; }

            if (role != "admin" && role != "teacher" && role != "student")
            { ShowError("Please select a valid role."); return; }

            try
            {
                SaveUser(uid, name, email, role, isActive);
                Response.Redirect("userManagement.aspx?saved=1", true);
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        private void SaveUser(string uid, string name, string email, string role, bool accountStatus)
        {
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        // Prevent duplicate email (excluding the current user)
                        using (var dup = new SqlCommand(@"
                            SELECT COUNT(1) FROM dbo.userTable
                            WHERE  email = @Email AND userID <> @UID AND ISNULL(isDeleted,0) = 0;", conn, tx))
                        {
                            dup.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                            dup.Parameters.Add("@UID", SqlDbType.NVarChar, 10).Value = uid;
                            if (Convert.ToInt32(dup.ExecuteScalar(), CultureInfo.InvariantCulture) > 0)
                                throw new Exception("Email already in use. Please choose a different email.");
                        }

                        // Update userTable
                        using (var cmd = new SqlCommand(@"
                            UPDATE dbo.userTable
                            SET    fullName      = @Name,
                                   email         = @Email,
                                   accountStatus = @accountStatus
                            WHERE  userID = @UID AND ISNULL(isDeleted,0) = 0;", conn, tx))
                        {
                            cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = name;
                            cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                            cmd.Parameters.Add("@accountStatus", SqlDbType.Bit).Value = accountStatus;
                            cmd.Parameters.Add("@UID", SqlDbType.NVarChar, 10).Value = uid;

                            int rows = cmd.ExecuteNonQuery();
                            if (rows == 0) throw new Exception("User not found (may have been deleted).");
                        }

                        // Upsert role assignment
                        string roleId = GetRoleIdByName(conn, tx, role);
                        using (var up = new SqlCommand(@"
                            IF EXISTS (SELECT 1 FROM dbo.userRoleTable WHERE userID = @uid)
                                UPDATE dbo.userRoleTable SET roleID = @rid WHERE userID = @uid
                            ELSE
                                INSERT INTO dbo.userRoleTable (userID, roleID) VALUES (@uid, @rid);", conn, tx))
                        {
                            up.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = uid;
                            up.Parameters.Add("@rid", SqlDbType.NVarChar, 10).Value = roleId;
                            up.ExecuteNonQuery();
                        }

                        // Activity log — CreatedAt is [datetime], use GETUTCDATE()
                        TryInsertSysLog(conn, tx, "USER_UPDATE",
                            $"Updated {uid}: name='{name}', email='{email}', role='{role}', active={accountStatus}");

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        // SysActivityLogTable: CreatedAt is [datetime] — use GETUTCDATE() not SYSUTCDATETIME()
        private void TryInsertSysLog(SqlConnection conn, SqlTransaction tx,
                                     string eventType, string description)
        {
            try
            {
                if (eventType != null && eventType.Length > 100) eventType = eventType.Substring(0, 100);
                if (description != null && description.Length > 100) description = description.Substring(0, 100);

                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.SysActivityLogTable
                        (EventType, Description, CreatedAt, Status, Priority)
                    VALUES
                        (@type, @desc, GETUTCDATE(), @status, @priority);", conn, tx))
                {
                    cmd.Parameters.Add("@type", SqlDbType.NVarChar, 100).Value = eventType ?? "INFO";
                    cmd.Parameters.Add("@desc", SqlDbType.NVarChar, 100).Value = description ?? "";
                    cmd.Parameters.Add("@status", SqlDbType.NVarChar, 50).Value = "OK";
                    cmd.Parameters.Add("@priority", SqlDbType.NVarChar, 50).Value = "Low";
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { /* non-fatal */ }
        }

        private string GetRoleIdByName(SqlConnection conn, SqlTransaction tx, string roleName)
        {
            using (var cmd = new SqlCommand(@"
                SELECT TOP 1 roleID FROM dbo.Role
                WHERE  LOWER(roleName) = LOWER(@name);", conn, tx))
            {
                cmd.Parameters.Add("@name", SqlDbType.NVarChar, 50).Value = roleName ?? "";
                object o = cmd.ExecuteScalar();
                if (o == null || o == DBNull.Value)
                    throw new Exception("Role not found: " + roleName);
                return Convert.ToString(o);
            }
        }

        private DataRow GetUserById(string uid)
        {
            var dt = new DataTable();

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT u.userID, u.fullName, u.email, u.accountStatus, u.AvatarUrl,
                       ISNULL(r.roleName,'student') AS roleName
                FROM   dbo.userTable u
                LEFT JOIN dbo.userRoleTable ur ON ur.userID = u.userID
                LEFT JOIN dbo.Role r           ON r.roleID  = ur.roleID
                WHERE  u.userID = @UID AND ISNULL(u.isDeleted,0) = 0;", conn))
            {
                cmd.Parameters.Add("@UID", SqlDbType.NVarChar, 10).Value = uid;
                using (var da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            litError.Text = $"<span class='text-sm font-bold text-red-600'>{HttpUtility.HtmlEncode(msg)}</span>";
        }
    }
}