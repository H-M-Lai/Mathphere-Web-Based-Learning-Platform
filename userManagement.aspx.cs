using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MathSphere
{
    public partial class userManagement : System.Web.UI.Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["MathSphereDB"].ConnectionString;

        // The one account that can never be disabled or deleted
        private const string SuperAdminId = "U001";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsAdmin"] == null || !(bool)Session["IsAdmin"])
            {
                Response.Redirect("Login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                BindUsers();
                BindStats();
                HandleToasts();
            }
        }

        private void HandleToasts()
        {
            if (Request.QueryString["added"] == "1")
            {
                string raw = Request.QueryString["name"] ?? "User";
                string safeName = HttpUtility.JavaScriptStringEncode(Uri.UnescapeDataString(raw));
                ScriptManager.RegisterStartupScript(this, GetType(), "AddedToast",
                    "document.addEventListener('DOMContentLoaded',function(){showToast('Account created for " + safeName + ".');});", true);
            }
            if (Request.QueryString["saved"] == "1")
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "SavedToast",
                    "document.addEventListener('DOMContentLoaded',function(){showToast('User updated successfully.');});", true);
            }
        }

        // -
        // Bind user table
        // -
        private void BindUsers()
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT
                    u.userID,
                    u.fullName        AS FullName,
                    u.email           AS Email,
                    ISNULL(r.roleName,'Unassigned') AS Role,
                    u.accountStatus   AS IsActive,
                    u.AvatarUrl
                FROM dbo.userTable u
                LEFT JOIN dbo.userRoleTable ur ON ur.userID = u.userID
                LEFT JOIN dbo.Role r           ON r.roleID  = ur.roleID
                WHERE ISNULL(u.isDeleted,0) = 0
                ORDER BY u.CreatedAt DESC;", con))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                con.Open();
                da.Fill(dt);
            }

            litTotal.Text = dt.Rows.Count.ToString(CultureInfo.InvariantCulture);
            rptUsers.DataSource = dt;
            rptUsers.DataBind();
        }

        // -
        // Repeater row builder
        // -
        protected void rptUsers_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            Literal lit = (Literal)e.Item.FindControl("litUserRow");

            string uidRaw = Convert.ToString(row["userID"]) ?? "";
            string uid = HttpUtility.HtmlEncode(uidRaw);
            string nameRaw = Convert.ToString(row["FullName"]) ?? "";
            string name = HttpUtility.HtmlEncode(nameRaw);
            string email = HttpUtility.HtmlEncode(Convert.ToString(row["Email"]) ?? "");
            string roleRaw = (Convert.ToString(row["Role"]) ?? "unassigned").Trim();
            string role = roleRaw.ToLowerInvariant();
            string avatar = row["AvatarUrl"] == DBNull.Value ? "" : Convert.ToString(row["AvatarUrl"]);
            bool isActive = Convert.ToBoolean(row["IsActive"]);
            bool isSuperAdmin = uidRaw == SuperAdminId;

            string avatarHtml = !string.IsNullOrWhiteSpace(avatar)
                ? string.Format("<img src=\"{0}\" alt=\"{1}\" class=\"w-full h-full object-cover{2}\"/>",
                    HttpUtility.HtmlEncode(avatar), name, !isActive ? " grayscale" : "")
                : "<span class=\"material-symbols-outlined text-gray-400 fill-icon\">person</span>";

            string avatarBg =
                role == "teacher" ? "bg-blue-100" :
                role == "student" ? "bg-green-100" :
                role == "admin" ? "bg-yellow-100" : "bg-gray-100";

            string badgeBg, badgeText, badgeBorder, badgeLabel;
            switch (role)
            {
                case "teacher":
                    badgeBg = "bg-blue-100"; badgeText = "text-math-blue"; badgeBorder = "border-blue-200"; badgeLabel = "Teacher"; break;
                case "student":
                    badgeBg = "bg-green-100"; badgeText = "text-math-green"; badgeBorder = "border-green-200"; badgeLabel = "Student"; break;
                case "admin":
                    badgeBg = "bg-yellow-100"; badgeText = "text-primary"; badgeBorder = "border-yellow-200"; badgeLabel = "Admin"; break;
                default:
                    badgeBg = "bg-gray-100"; badgeText = "text-gray-500"; badgeBorder = "border-gray-200";
                    badgeLabel = HttpUtility.HtmlEncode(roleRaw); break;
            }

            string nameCls = !isActive ? "text-gray-400" : "text-math-dark-blue";
            string emailCls = !isActive ? "text-gray-400" : "text-gray-600";
            string idCls = !isActive ? "text-gray-300" : "text-gray-400";
            string opacCls = !isActive ? "opacity-50" : "";
            string trackBg = isActive ? "#84cc16" : "#e5e7eb";
            string thumbTrans = isActive ? "translate-x-5" : "";
            string statusLbl = isActive ? "Active" : "Disabled";
            string statusCls = isActive ? "text-math-green" : "text-gray-400";
            string checkedAtt = isActive ? "checked" : "";
            string togId = "tog-" + uidRaw;
            string jsName = HttpUtility.JavaScriptStringEncode(nameRaw);

            // Toggle cell
            string toggleCell;
            if (isSuperAdmin)
            {
                toggleCell = @"
    <div class=""flex items-center gap-2"">
      <span class=""px-3 py-1 bg-yellow-100 text-yellow-700 border border-yellow-300
                    rounded-full text-[10px] font-black uppercase tracking-wider"">
        Super Admin
      </span>
    </div>";
            }
            else
            {
                toggleCell = string.Format(@"
    <div class=""flex items-center status-wrap"">
      <input {0} class=""toggle-checkbox sr-only"" id=""{1}"" type=""checkbox""
             onchange=""handleToggle('{2}','{3}',this)""/>
      <label class=""toggle-label w-10 h-5 rounded-full cursor-pointer p-0.5
                     transition-colors duration-300 flex items-center""
             for=""{1}"" style=""background:{4};"">
        <div class=""toggle-dot w-4 h-4 bg-white rounded-full shadow-sm
                     transition-transform duration-300 {5}""></div>
      </label>
      <span class=""status-label ml-3 text-[10px] font-black uppercase {6}"">{7}</span>
    </div>",
                    checkedAtt, togId, uidRaw, jsName, trackBg, thumbTrans, statusCls, statusLbl);
            }

            // Action buttons
            string actionButtons;
            if (isSuperAdmin)
            {
                actionButtons = string.Format(@"
      <button type=""button"" onclick=""openResetModal('{0}','{1}')"" title=""Reset Password""
              class=""size-9 rounded-xl bg-gray-50 flex items-center justify-center text-gray-400
                     hover:bg-primary hover:text-math-dark-blue transition-all group/btn"">
        <span class=""material-symbols-outlined text-xl group-hover/btn:rotate-45 transition-transform"">lock_reset</span>
      </button>
      <button type=""button"" onclick=""openEditModal('{0}')"" title=""Edit User""
              class=""size-9 rounded-xl bg-gray-50 flex items-center justify-center text-gray-400
                     hover:bg-math-blue hover:text-white transition-all"">
        <span class=""material-symbols-outlined text-xl"">edit</span>
      </button>
      <span title=""Super admin cannot be deleted""
            class=""size-9 rounded-xl bg-gray-50 flex items-center justify-center
                   text-gray-200 cursor-not-allowed"">
        <span class=""material-symbols-outlined text-xl"">delete</span>
      </span>", uidRaw, jsName);
            }
            else
            {
                actionButtons = string.Format(@"
      <button type=""button"" onclick=""openResetModal('{0}','{1}')"" title=""Reset Password""
              class=""size-9 rounded-xl bg-gray-50 flex items-center justify-center text-gray-400
                     hover:bg-primary hover:text-math-dark-blue transition-all group/btn"">
        <span class=""material-symbols-outlined text-xl group-hover/btn:rotate-45 transition-transform"">lock_reset</span>
      </button>
      <button type=""button"" onclick=""openEditModal('{0}')"" title=""Edit User""
              class=""size-9 rounded-xl bg-gray-50 flex items-center justify-center text-gray-400
                     hover:bg-math-blue hover:text-white transition-all"">
        <span class=""material-symbols-outlined text-xl"">edit</span>
      </button>
      <button type=""button"" onclick=""openDeleteModal('{0}','{1}')"" title=""Delete User""
              class=""size-9 rounded-xl bg-gray-50 flex items-center justify-center text-gray-400
                     hover:bg-red-500 hover:text-white transition-all"">
        <span class=""material-symbols-outlined text-xl"">delete</span>
      </button>", uidRaw, jsName);
            }

            lit.Text = string.Format(@"
<tr class=""hover:bg-gray-50/50 transition-colors"" data-role=""{0}"" data-status=""{1}"">
  <td class=""px-6 py-5"">
    <div class=""flex items-center gap-4"">
      <div class=""size-12 rounded-2xl {2} overflow-hidden border-2 border-white shadow-sm {3}"">{4}</div>
      <div>
        <div class=""font-black text-sm {5}"">{6}</div>
        <div class=""text-[10px] font-bold {7} uppercase tracking-tighter"">ID: {8}</div>
      </div>
    </div>
  </td>
  <td class=""px-6 py-5""><span class=""text-sm font-medium {9}"">{10}</span></td>
  <td class=""px-6 py-5"">
    <span class=""px-4 py-1.5 {11} {12} rounded-full text-[10px] font-black
                  uppercase tracking-wider border {13}"">{14}</span>
  </td>
  <td class=""px-6 py-5"">{15}</td>
  <td class=""px-6 py-5"">
    <div class=""flex justify-end gap-2"">{16}</div>
  </td>
</tr>",
                role, isActive ? "active" : "disabled",
                avatarBg, opacCls, avatarHtml,
                nameCls, name, idCls, uid,
                emailCls, email,
                badgeBg, badgeText, badgeBorder, badgeLabel,
                toggleCell, actionButtons);
        }

        // -
        // Stat cards
        // -
        private void BindStats()
        {
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                ;WITH base AS (
                    SELECT u.userID, u.accountStatus, u.CreatedAt,
                           ISNULL(u.isDeleted,0) AS isDeleted,
                           LOWER(ISNULL(r.roleName,'')) AS roleName
                    FROM dbo.userTable u
                    LEFT JOIN dbo.userRoleTable ur ON ur.userID = u.userID
                    LEFT JOIN dbo.Role r ON r.roleID = ur.roleID
                )
                SELECT
                    SUM(CASE WHEN isDeleted=0 THEN 1 ELSE 0 END)                                                    AS totalUsers,
                    SUM(CASE WHEN isDeleted=0 AND accountStatus=1 THEN 1 ELSE 0 END)                               AS activeUsers,
                    SUM(CASE WHEN isDeleted=0 AND roleName IN ('admin','teacher') THEN 1 ELSE 0 END)               AS staffCount,
                    SUM(CASE WHEN isDeleted=0 AND CreatedAt >= DATEADD(DAY,-7,SYSUTCDATETIME()) THEN 1 ELSE 0 END) AS newLast7Days
                FROM base;", con))
            {
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    int total = Convert.ToInt32(r["totalUsers"], CultureInfo.InvariantCulture);
                    int active = Convert.ToInt32(r["activeUsers"], CultureInfo.InvariantCulture);
                    int staff = Convert.ToInt32(r["staffCount"], CultureInfo.InvariantCulture);
                    int growth = Convert.ToInt32(r["newLast7Days"], CultureInfo.InvariantCulture);

                    litStaffCount.Text = staff.ToString(CultureInfo.InvariantCulture);
                    litActiveRate.Text = total == 0 ? "0%"
                        : (active * 100.0 / total).ToString("0.0", CultureInfo.InvariantCulture) + "%";
                    litGrowth.Text = "+" + growth.ToString(CultureInfo.InvariantCulture);
                }
            }
        }

        // -
        // Navigation
        // -
        protected void lnkDashboard_Click(object sender, EventArgs e) => Response.Redirect("adminDashboard.aspx");
        protected void lnkUserManagement_Click(object sender, EventArgs e) => Response.Redirect("userManagement.aspx");
        protected void lnkSystemSettings_Click(object sender, EventArgs e) => Response.Redirect("systemSetting.aspx");
        protected void lnkForumModeration_Click(object sender, EventArgs e) => Response.Redirect("forumModeration.aspx");
        protected void lnkHelpCenter_Click(object sender, EventArgs e) => Response.Redirect("helpCenter.aspx");

        // -
        // PASSWORD RESET  (admin-initiated)
        // -
        protected void btnConfirmReset_Click(object sender, EventArgs e)
        {
            string uid = (hdnResetUserId.Value ?? "").Trim();
            if (string.IsNullOrEmpty(uid)) return;

            string email = null, fullName = null;

            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT fullName, email, passwordHash
                FROM   dbo.userTable
                WHERE  userID = @uid AND ISNULL(isDeleted,0) = 0;", con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = uid;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read())
                    {
                        ShowToast("User not found.");
                        ScriptManager.RegisterStartupScript(this, GetType(), "CloseReset", "closeResetModal();", true);
                        return;
                    }
                    fullName = Convert.ToString(r["fullName"]);
                    email = Convert.ToString(r["email"]);

                    // Google-only accounts have no passwordHash — the reset link
                    //      flow is meaningless for them; they sign in via Google OAuth.
                    string ph = r["passwordHash"] == DBNull.Value ? null : r["passwordHash"].ToString();
                    if (string.IsNullOrWhiteSpace(ph))
                    {
                        ShowToast($"{fullName} uses Google Sign-In and has no local password to reset.");
                        ScriptManager.RegisterStartupScript(this, GetType(), "CloseResetGoogle", "closeResetModal();", true);
                        return;
                    }
                }
            }

            // Generate token
            string token;
            using (var rng = new RNGCryptoServiceProvider())
            {
                byte[] bytes = new byte[32];
                rng.GetBytes(bytes);
                token = Convert.ToBase64String(bytes)
                    .Replace("+", "-").Replace("/", "_").Replace("=", "");
            }

            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();

                    using (var del = new SqlCommand(@"
                        UPDATE dbo.PasswordResetTokens
                        SET    IsUsed = 1
                        WHERE  UserID = @uid AND IsUsed = 0;", con))
                    {
                        del.Parameters.Add("@uid", SqlDbType.VarChar, 10).Value = uid;
                        try { del.ExecuteNonQuery(); } catch { }
                    }

                    using (var ins = new SqlCommand(@"
                        INSERT INTO dbo.PasswordResetTokens
                            (Token, UserID, Email, ExpiresAt, IsUsed)
                        VALUES
                            (@token, @uid, @email, DATEADD(MINUTE, 30, GETUTCDATE()), 0);", con))
                    {
                        ins.Parameters.Add("@token", SqlDbType.VarChar, 100).Value = token;
                        ins.Parameters.Add("@uid", SqlDbType.VarChar, 10).Value = uid;
                        ins.Parameters.Add("@email", SqlDbType.VarChar, 255).Value = email ?? "";
                        ins.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowToast("Could not generate reset token: " + ex.Message);
                ScriptManager.RegisterStartupScript(this, GetType(), "CloseReset2", "closeResetModal();", true);
                return;
            }

            string baseUrl = Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath.TrimEnd('/');
            string resetLink = $"{baseUrl}/ResetPassword.aspx?token={Uri.EscapeDataString(token)}";

            bool notify = chkNotifyReset.Checked;
            if (notify && !string.IsNullOrEmpty(email))
            {
                try { EmailService.SendPasswordResetLink(email, fullName, resetLink); } catch { }
            }

            TryLogActivity(Convert.ToString(Session["UserID"]), "PWD_RESET", uid,
                $"Password reset requested for user {fullName} ({uid}).");

            ScriptManager.RegisterStartupScript(this, GetType(), "ResetDone",
                notify
                    ? $"closeResetModal(); showToast('Password reset link sent to {HttpUtility.JavaScriptStringEncode(fullName)}.');"
                    : $"closeResetModal(); showToast('Password reset link generated for {HttpUtility.JavaScriptStringEncode(fullName)}.');",
                true);
        }

        // -
        // DISABLE — sets accountStatus = 0
        // -
        protected void btnConfirmDisable_Click(object sender, EventArgs e)
        {
            string uid = (hdnDisableUserId.Value ?? "").Trim();
            if (string.IsNullOrEmpty(uid)) return;

            if (uid == SuperAdminId)
            { ShowToast("The System Administrator account cannot be disabled."); return; }

            string actorUserId = Convert.ToString(Session["UserID"]);
            if (actorUserId == uid)
            { ShowToast("You cannot disable your own admin account."); return; }

            string email = null, fullName = null;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand getCmd = new SqlCommand(@"
                            SELECT fullName, email FROM dbo.userTable
                            WHERE  userID = @uid AND ISNULL(isDeleted,0) = 0;", con, tx))
                        {
                            getCmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = uid;
                            using (SqlDataReader rdr = getCmd.ExecuteReader())
                            {
                                if (!rdr.Read()) { tx.Rollback(); ShowToast("User not found."); return; }
                                fullName = Convert.ToString(rdr["fullName"]);
                                email = Convert.ToString(rdr["email"]);
                            }
                        }

                        using (SqlCommand cmd = new SqlCommand(@"
                            UPDATE dbo.userTable
                            SET    accountStatus = 0, DeactivatedAt = SYSUTCDATETIME()
                            WHERE  userID = @uid AND ISNULL(isDeleted,0) = 0;", con, tx))
                        {
                            cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = uid;
                            cmd.ExecuteNonQuery();
                        }
                        tx.Commit();
                    }
                    catch (Exception ex) { tx.Rollback(); ShowToast(ex.Message); return; }
                }
            }

            TryLogActivity(actorUserId, "USER_DISABLE", uid, $"Disabled user {fullName} ({uid}).");

            if (chkNotifyDisable.Checked && !string.IsNullOrEmpty(email))
                try { EmailService.SendAccountDisabled(email, fullName); } catch { }

            ScriptManager.RegisterStartupScript(this, GetType(), "DisabledMsg",
                "closeDisableModal(); showToast('User account has been disabled.');", true);
            BindUsers(); BindStats();
        }

        // -
        // RE-ENABLE — sets accountStatus = 1
        // -
        protected void btnEnableUser_Click(object sender, EventArgs e)
        {
            string uid = (hdnEnableUserId.Value ?? "").Trim();
            if (string.IsNullOrEmpty(uid)) return;

            string actorUserId = Convert.ToString(Session["UserID"]);
            string email = null, fullName = null;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand getCmd = new SqlCommand(@"
                            SELECT fullName, email FROM dbo.userTable
                            WHERE  userID = @uid AND ISNULL(isDeleted,0) = 0;", con, tx))
                        {
                            getCmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = uid;
                            using (SqlDataReader rdr = getCmd.ExecuteReader())
                                if (rdr.Read())
                                {
                                    fullName = Convert.ToString(rdr["fullName"]);
                                    email = Convert.ToString(rdr["email"]);
                                }
                        }

                        using (SqlCommand cmd = new SqlCommand(@"
                            UPDATE dbo.userTable
                            SET    accountStatus = 1, DeactivatedAt = NULL
                            WHERE  userID = @uid AND ISNULL(isDeleted,0) = 0;", con, tx))
                        {
                            cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = uid;
                            cmd.ExecuteNonQuery();
                        }
                        tx.Commit();
                    }
                    catch (Exception ex) { tx.Rollback(); ShowToast(ex.Message); return; }
                }
            }

            TryLogActivity(actorUserId, "USER_ENABLE", uid, $"Re-enabled user account {uid}.");

            if (!string.IsNullOrEmpty(email))
                try { EmailService.SendAccountReactivated(email, fullName); } catch { }

            BindUsers(); BindStats();
        }

        // -
        // DELETE (soft delete)
        // -
        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string uid = (hdnDeleteUserId.Value ?? "").Trim();
            if (string.IsNullOrEmpty(uid)) return;

            if (uid == SuperAdminId)
            {
                ShowToast("The System Administrator account cannot be deleted.");
                ScriptManager.RegisterStartupScript(this, GetType(), "DelBlock", "closeDeleteModal();", true);
                return;
            }

            string actorUserId = Convert.ToString(Session["UserID"]);
            if (actorUserId == uid)
            {
                ShowToast("You cannot delete your own admin account.");
                ScriptManager.RegisterStartupScript(this, GetType(), "DelSelf", "closeDeleteModal();", true);
                return;
            }

            string fullName = null, email = null;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand getCmd = new SqlCommand(@"
                            SELECT fullName, email FROM dbo.userTable
                            WHERE  userID = @uid AND ISNULL(isDeleted,0) = 0;", con, tx))
                        {
                            getCmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = uid;
                            using (SqlDataReader rdr = getCmd.ExecuteReader())
                            {
                                if (!rdr.Read()) { tx.Rollback(); ShowToast("User not found."); return; }
                                fullName = Convert.ToString(rdr["fullName"]);
                                email = Convert.ToString(rdr["email"]);
                            }
                        }

                        using (SqlCommand cmd = new SqlCommand(@"
                            UPDATE dbo.userTable
                            SET    isDeleted = 1, accountStatus = 0, DeactivatedAt = SYSUTCDATETIME()
                            WHERE  userID = @uid AND ISNULL(isDeleted,0) = 0;", con, tx))
                        {
                            cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = uid;
                            cmd.ExecuteNonQuery();
                        }
                        tx.Commit();
                    }
                    catch (Exception ex) { tx.Rollback(); ShowToast(ex.Message); return; }
                }
            }

            TryLogActivity(actorUserId, "USER_DELETE", uid, $"Soft-deleted user {fullName} ({uid}).");

            if (!string.IsNullOrEmpty(email))
                try { EmailService.SendAccountDeleted(email, fullName); } catch { }

            ScriptManager.RegisterStartupScript(this, GetType(), "DelDone",
                "closeDeleteModal(); showToast('User account deleted.');", true);
            BindUsers(); BindStats();
        }

        // -
        // CREATE user
        // On success: sends a welcome email with the temp password so the
        // new user can log in immediately and change it.
        // -
        protected void btnSaveAdd_Click(object sender, EventArgs e)
        {
            string first = (txtAddFirst.Text ?? "").Trim();
            string last = (txtAddLast.Text ?? "").Trim();
            string email = (txtAddEmail.Text ?? "").Trim().ToLowerInvariant();
            string role = (ddlAddRole.SelectedValue ?? "").Trim();
            string pass = txtAddPassword.Text ?? "";

            if (string.IsNullOrWhiteSpace(first) || string.IsNullOrWhiteSpace(last))
            { ShowToast("Please enter the full name."); return; }
            if (string.IsNullOrWhiteSpace(email) || !email.Contains("@"))
            { ShowToast("Please enter a valid email."); return; }
            if (pass.Length < 8)
            { ShowToast("Password must be at least 8 characters."); return; }

            string fullName = first + " " + last;
            try
            {
                CreateUserAndLog(fullName, email, role, pass, isActive: true);

                // Send welcome email with credentials fire-and-forget
                string capturedEmail = email;
                string capturedName = fullName;
                string capturedPassword = pass;
                string loginUrl = Request.Url.GetLeftPart(UriPartial.Authority)
                                          + Request.ApplicationPath.TrimEnd('/') + "/Login.aspx";
                System.Threading.Tasks.Task.Run(() =>
                {
                    try { EmailService.SendWelcomeWithCredentials(capturedEmail, capturedName, capturedPassword, loginUrl); }
                    catch (Exception ex)
                    { System.Diagnostics.Debug.WriteLine("Welcome email error: " + ex.Message); }
                });

                ScriptManager.RegisterStartupScript(this, GetType(), "AddOk",
                    "closeAddModal(); showToast('Account created for " +
                    HttpUtility.JavaScriptStringEncode(fullName) + ". Welcome email sent.');", true);
                BindUsers(); BindStats();
            }
            catch (Exception ex) { ShowToast(ex.Message); }
        }

        private void CreateUserAndLog(string fullName, string email, string role,
                                      string plainPassword, bool isActive)
        {
            string actorUserId = Convert.ToString(Session["UserID"]);
            string passwordHash = HashPasswordPbkdf2(plainPassword);
            string newUserId = null;

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        newUserId = GenerateNextUserId(conn, tx, role);

                        using (var check = new SqlCommand(@"
                            SELECT COUNT(1) FROM dbo.userTable
                            WHERE  LOWER(email) = LOWER(@Email) AND ISNULL(isDeleted,0) = 0;", conn, tx))
                        {
                            check.Parameters.Add("@Email", SqlDbType.NVarChar, 50).Value = email;
                            if (Convert.ToInt32(check.ExecuteScalar()) > 0)
                                throw new Exception("Email already exists. Please use a different email.");
                        }

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
                            cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 255).Value = passwordHash;
                            cmd.Parameters.Add("@accountStatus", SqlDbType.Bit).Value = isActive;
                            cmd.ExecuteNonQuery();
                        }

                        string roleId = GetRoleIdByName(conn, tx, role);
                        using (var cmdRole = new SqlCommand(@"
                            INSERT INTO dbo.userRoleTable (userID, roleID) VALUES (@uid, @rid);", conn, tx))
                        {
                            cmdRole.Parameters.Add("@uid", SqlDbType.NVarChar, 10).Value = newUserId;
                            cmdRole.Parameters.Add("@rid", SqlDbType.NVarChar, 10).Value = roleId;
                            cmdRole.ExecuteNonQuery();
                        }
                        tx.Commit();
                    }
                    catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
                    { tx.Rollback(); throw new Exception("Duplicate detected (email or userID). Please try again."); }
                    catch { tx.Rollback(); throw; }
                }
            }

            TryLogActivity(actorUserId, "USER_CREATE", newUserId,
                $"Created user {fullName} ({email}) role={role}");
        }


        private string GenerateNextUserId(SqlConnection conn, SqlTransaction tx, string role)
        {
            string prefix;
            switch ((role ?? "").Trim().ToLowerInvariant())
            {
                case "teacher": prefix = "T"; break;
                case "student": prefix = "S"; break;
                case "admin": prefix = "A"; break;
                default: throw new Exception("Invalid role: " + role);
            }

            using (var cmd = new SqlCommand(@"
                SELECT TOP 1 userID FROM dbo.userTable WITH (UPDLOCK, HOLDLOCK)
                WHERE  userID LIKE @prefix + '%' ORDER BY userID DESC;", conn, tx))
            {
                cmd.Parameters.Add("@prefix", SqlDbType.NVarChar, 1).Value = prefix;
                object result = cmd.ExecuteScalar();
                if (result == null || result == DBNull.Value) return prefix + "00001";
                string lastId = Convert.ToString(result);
                if (int.TryParse(lastId.Substring(1), out int num))
                    return prefix + (num + 1).ToString("D5", CultureInfo.InvariantCulture);
                return prefix + "00001";
            }
        }

        private string GetRoleIdByName(SqlConnection conn, SqlTransaction tx, string roleName)
        {
            using (var cmd = new SqlCommand(
                "SELECT TOP 1 roleID FROM dbo.Role WHERE LOWER(roleName) = LOWER(@name);", conn, tx))
            {
                cmd.Parameters.Add("@name", SqlDbType.NVarChar, 50).Value = roleName ?? "";
                object o = cmd.ExecuteScalar();
                if (o == null || o == DBNull.Value) throw new Exception("Role not found: " + roleName);
                return Convert.ToString(o, CultureInfo.InvariantCulture);
            }
        }

        // -
        // Activity log — confirmed schema:
        //   LogID[int], EventType[nvarchar(100)], Description[nvarchar(100)],
        //   CreatedAt[datetime], Status[nvarchar(50)], Priority[nvarchar(50)]
        // -
        private void TryLogActivity(string actorId, string actionType, string targetId, string details)
        {
            try
            {
                string desc = $"{actorId} -> {targetId}: {details}";
                if (desc.Length > 100) desc = desc.Substring(0, 100);
                if (actionType != null && actionType.Length > 100) actionType = actionType.Substring(0, 100);

                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.SysActivityLogTable
                        (EventType, Description, CreatedAt, Status, Priority)
                    VALUES
                        (@type, @desc, GETUTCDATE(), @status, @priority);", con))
                {
                    cmd.Parameters.Add("@type", SqlDbType.NVarChar, 100).Value = actionType ?? "INFO";
                    cmd.Parameters.Add("@desc", SqlDbType.NVarChar, 100).Value = desc;
                    cmd.Parameters.Add("@status", SqlDbType.NVarChar, 50).Value = "OK";
                    cmd.Parameters.Add("@priority", SqlDbType.NVarChar, 50).Value = "Low";
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { /* log failure is non-fatal */ }
        }

        // PBKDF2-SHA256, 100,000 iterations
        private string HashPasswordPbkdf2(string password)
        {
            byte[] salt = new byte[16];
            using (var rng = new RNGCryptoServiceProvider()) rng.GetBytes(salt);
            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256))
            {
                byte[] hash = pbkdf2.GetBytes(32);
                return Convert.ToBase64String(salt) + ":" + Convert.ToBase64String(hash);
            }
        }

        private void ShowToast(string message) =>
            ScriptManager.RegisterStartupScript(this, GetType(), "Toast",
                "showToast('" + HttpUtility.JavaScriptStringEncode(message ?? "") + "');", true);
    }
}
