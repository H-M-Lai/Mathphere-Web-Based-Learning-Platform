using System;
using System.Configuration;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace MathSphere
{
    public static class EmailService
    {
        private static readonly string GmailUser =
            ConfigurationManager.AppSettings["GmailUser"];
        private static readonly string GmailPass =
            ConfigurationManager.AppSettings["GmailAppPassword"];

        // Welcome email with credentials (admin-created accounts)
        // Sent when an admin creates a new user account. Includes the
        // user's email address, temporary password, and a direct login link
        // so they can sign in immediately and change their password.
        public static void SendWelcomeWithCredentials(
            string toEmail, string toName, string tempPassword, string loginUrl)
        {
            string subject = "Welcome to MathSphere — Your Account is Ready";
            string safeUrl = System.Web.HttpUtility.HtmlEncode(loginUrl);
            string safeName = System.Web.HttpUtility.HtmlEncode(toName);
            string safeEmail = System.Web.HttpUtility.HtmlEncode(toEmail);
      
            // this is the one-time credential the user needs to log in.
            // Users are expected to change it immediately after first login.
            string safePass = System.Web.HttpUtility.HtmlEncode(tempPassword);

            string body = $@"
<!DOCTYPE html><html>
<body style='font-family:Arial,sans-serif;background:#f8f8f5;padding:30px;margin:0;'>
  <div style='max-width:540px;margin:auto;background:#fff;border-radius:20px;
              padding:40px;box-shadow:0 4px 24px rgba(0,0,0,0.08);'>

    <div style='text-align:center;margin-bottom:30px;'>
      <h1 style='color:#1e3a8a;font-size:28px;margin:0;'>MathSphere</h1>
      <p style='color:#6b7280;font-size:14px;margin-top:6px;'>Your account has been created</p>
    </div>

    <div style='text-align:center;margin-bottom:28px;'>
      <div style='display:inline-block;background:#eff6ff;border-radius:50%;
                  width:80px;height:80px;line-height:80px;font-size:42px;'>🎓</div>
    </div>

    <p style='color:#1e3a8a;font-size:16px;margin-bottom:8px;'>Hi <strong>{safeName}</strong>,</p>
    <p style='color:#374151;font-size:15px;line-height:1.6;'>
      Welcome to <strong>MathSphere</strong>! An administrator has created an account for you.
      Use the credentials below to log in for the first time.
    </p>

    <div style='background:#f0f9ff;border:2px solid #bae6fd;border-radius:16px;
                padding:24px;margin:28px 0;'>
      <p style='margin:0 0 4px 0;color:#6b7280;font-size:11px;font-weight:900;
                text-transform:uppercase;letter-spacing:0.1em;'>Your Login Credentials</p>
      <table style='width:100%;margin-top:12px;border-collapse:collapse;'>
        <tr>
          <td style='padding:8px 0;color:#374151;font-size:14px;font-weight:bold;width:120px;'>Email</td>
          <td style='padding:8px 0;color:#1e3a8a;font-size:14px;font-family:monospace;'>{safeEmail}</td>
        </tr>
        <tr>
          <td style='padding:8px 0;color:#374151;font-size:14px;font-weight:bold;'>Password</td>
          <td style='padding:8px 0;color:#1e3a8a;font-size:14px;font-family:monospace;
                     background:#fff;border-radius:8px;padding:6px 12px;
                     border:1px solid #e0f2fe;'>{safePass}</td>
        </tr>
      </table>
    </div>

    <div style='background:#fefce8;border-left:4px solid #f59e0b;border-radius:12px;
                padding:16px 20px;margin-bottom:28px;'>
      <p style='margin:0;color:#92400e;font-size:13px;line-height:1.6;'>
        ⚠️ <strong>Please change your password</strong> immediately after your first login.
        This temporary password should not be kept.
      </p>
    </div>

    <div style='text-align:center;margin:32px 0;'>
      <a href='{safeUrl}'
         style='background:#2563eb;color:#fff;padding:16px 36px;border-radius:12px;
                text-decoration:none;font-weight:bold;font-size:15px;
                display:inline-block;letter-spacing:0.05em;'>Log In to MathSphere</a>
    </div>

    <p style='color:#6b7280;font-size:13px;line-height:1.6;text-align:center;'>
      Or copy this link:<br/>
      <a href='{safeUrl}' style='color:#2563eb;word-break:break-all;'>{safeUrl}</a>
    </p>

    <hr style='border:none;border-top:1px solid #e5e7eb;margin:28px 0;'/>
    <p style='color:#9ca3af;font-size:13px;text-align:center;'>
      If you weren't expecting this email, please contact your administrator.
    </p>
    <p style='color:#d1d5db;font-size:12px;text-align:center;margin-top:16px;'>
      &copy; 2026 MathSphere Studios. All Rights Calculated.
    </p>
  </div>
</body></html>";

            Send(toEmail, subject, body);
        }

        // Password Reset Link
        public static void SendPasswordResetLink(string toEmail, string toName, string resetLink)
        {
            string subject = "MathSphere — Reset Your Password";
            string safeLink = System.Web.HttpUtility.HtmlEncode(resetLink);

            string body = $@"
<!DOCTYPE html><html>
<body style='font-family:Arial,sans-serif;background:#f8f8f5;padding:30px;margin:0;'>
  <div style='max-width:520px;margin:auto;background:#fff;border-radius:20px;
              padding:40px;box-shadow:0 4px 24px rgba(0,0,0,0.08);'>
    <div style='text-align:center;margin-bottom:30px;'>
      <h1 style='color:#1e3a8a;font-size:28px;margin:0;'>MathSphere</h1>
      <p style='color:#6b7280;font-size:14px;margin-top:6px;'>Password Reset Request</p>
    </div>
    <p style='color:#1e3a8a;font-size:16px;margin-bottom:8px;'>Hi <strong>{System.Web.HttpUtility.HtmlEncode(toName)}</strong>,</p>
    <p style='color:#374151;font-size:15px;line-height:1.6;'>
      We received a request to reset your MathSphere password.
      Click the button below to set a new password.
      This link expires in <strong>30 minutes</strong>.
    </p>
    <div style='text-align:center;margin:32px 0;'>
      <a href='{safeLink}'
         style='background:#2563eb;color:#fff;padding:16px 36px;border-radius:12px;
                text-decoration:none;font-weight:bold;font-size:15px;
                display:inline-block;letter-spacing:0.05em;'>Reset My Password</a>
    </div>
    <p style='color:#6b7280;font-size:13px;line-height:1.6;'>
      Or copy and paste this link:<br/>
      <a href='{safeLink}' style='color:#2563eb;word-break:break-all;'>{safeLink}</a>
    </p>
    <hr style='border:none;border-top:1px solid #e5e7eb;margin:24px 0;'/>
    <p style='color:#9ca3af;font-size:13px;text-align:center;'>
      If you did not request this, you can safely ignore this email.
    </p>
    <p style='color:#d1d5db;font-size:12px;text-align:center;margin-top:16px;'>
      &copy; 2026 MathSphere Studios. All Rights Calculated.
    </p>
  </div>
</body></html>";
            Send(toEmail, subject, body);
        }

        // Course Enrollment
        public static void SendCourseEnrollment(
            string toEmail, string toName, string courseName, string teacherName)
        {
            string subject = $"MathSphere — You've Been Enrolled in {courseName}!";
            string body = $@"
<!DOCTYPE html><html>
<body style='font-family:Arial,sans-serif;background:#f8f8f5;padding:30px;margin:0;'>
  <div style='max-width:520px;margin:auto;background:#fff;border-radius:20px;
              padding:40px;box-shadow:0 4px 24px rgba(0,0,0,0.08);'>
    <div style='text-align:center;margin-bottom:30px;'>
      <h1 style='color:#1e3a8a;font-size:28px;margin:0;'>MathSphere</h1>
      <p style='color:#6b7280;font-size:14px;margin-top:6px;'>Course Enrollment Confirmation</p>
    </div>
    <div style='text-align:center;margin-bottom:28px;'>
      <div style='display:inline-block;background:#eff6ff;border-radius:50%;
                  width:80px;height:80px;line-height:80px;font-size:42px;'>📚</div>
    </div>
    <p style='color:#1e3a8a;font-size:16px;margin-bottom:8px;'>Hi <strong>{System.Web.HttpUtility.HtmlEncode(toName)}</strong>,</p>
    <p style='color:#374151;font-size:15px;line-height:1.6;'>
      Great news! You have been enrolled in a new course on MathSphere. Your magical mathematics journey is about to begin! 🎉
    </p>
    <div style='background:#eff6ff;border-left:4px solid #2563eb;border-radius:12px;
                padding:20px 24px;margin:24px 0;'>
      <p style='margin:0 0 6px 0;color:#6b7280;font-size:12px;font-weight:bold;
                text-transform:uppercase;letter-spacing:0.08em;'>Course Enrolled</p>
      <p style='margin:0 0 10px 0;color:#1e3a8a;font-size:20px;font-weight:900;'>{System.Web.HttpUtility.HtmlEncode(courseName)}</p>
      <p style='margin:0;color:#374151;font-size:14px;'>  🧑‍🏫Instructor: <strong>{System.Web.HttpUtility.HtmlEncode(teacherName)}</strong></p>
    </div>
    <p style='color:#374151;font-size:15px;line-height:1.6;'>
      Log in to MathSphere to access your course materials, assignments, and track your progress.
    </p>
    <hr style='border:none;border-top:1px solid #e5e7eb;margin:28px 0;'/>
    <p style='color:#9ca3af;font-size:13px;text-align:center;'>
      If you believe this enrollment was made in error, please contact your instructor.
    </p>
    <p style='color:#d1d5db;font-size:12px;text-align:center;margin-top:16px;'>
      &copy; 2026 MathSphere Studios. All Rights Calculated.
    </p>
  </div>
</body></html>";
            Send(toEmail, subject, body);
        }

        // Account Disabled
        public static void SendAccountDisabled(string toEmail, string toName)
        {
            string subject = "MathSphere — Your Account Has Been Disabled";
            string body = $@"
<!DOCTYPE html><html>
<body style='font-family:Arial,sans-serif;background:#f8f8f5;padding:30px;margin:0;'>
  <div style='max-width:520px;margin:auto;background:#fff;border-radius:20px;
              padding:40px;box-shadow:0 4px 24px rgba(0,0,0,0.08);'>
    <div style='text-align:center;margin-bottom:30px;'>
      <h1 style='color:#1e3a8a;font-size:28px;margin:0;'>MathSphere</h1>
      <p style='color:#6b7280;font-size:14px;margin-top:6px;'>Account Status Update</p>
    </div>
    <div style='text-align:center;margin-bottom:28px;'>
      <div style='display:inline-block;background:#fef9c3;border-radius:50%;
                  width:80px;height:80px;line-height:80px;font-size:42px;'>⚠️</div>
    </div>
    <p style='color:#1e3a8a;font-size:16px;margin-bottom:8px;'>Hi <strong>{System.Web.HttpUtility.HtmlEncode(toName)}</strong>,</p>
    <p style='color:#374151;font-size:15px;line-height:1.6;'>
      Your MathSphere account has been <strong>temporarily disabled</strong> by an administrator.
    </p>
    <div style='background:#fef9c3;border-left:4px solid #f59e0b;border-radius:12px;
                padding:20px 24px;margin:24px 0;'>
      <p style='margin:0;color:#92400e;font-size:14px;line-height:1.7;'>
        While your account is disabled, you will not be able to log in or access any course materials.
        Your data and progress are safely retained.
      </p>
    </div>
    <p style='color:#374151;font-size:15px;line-height:1.6;'>
      If you believe this is a mistake, please contact the MathSphere support team.
    </p>
    <hr style='border:none;border-top:1px solid #e5e7eb;margin:28px 0;'/>
    <p style='color:#9ca3af;font-size:13px;text-align:center;'>
      This is an automated notification. Please do not reply to this email.
    </p>
    <p style='color:#d1d5db;font-size:12px;text-align:center;margin-top:16px;'>
      &copy; 2026 MathSphere Studios. All Rights Calculated.
    </p>
  </div>
</body></html>";
            Send(toEmail, subject, body);
        }

        // Account Reactivated
        public static void SendAccountReactivated(string toEmail, string toName)
        {
            string subject = "MathSphere — Your Account Has Been Reactivated";
            string body = $@"
<!DOCTYPE html><html>
<body style='font-family:Arial,sans-serif;background:#f8f8f5;padding:30px;margin:0;'>
  <div style='max-width:520px;margin:auto;background:#fff;border-radius:20px;
              padding:40px;box-shadow:0 4px 24px rgba(0,0,0,0.08);'>
    <div style='text-align:center;margin-bottom:30px;'>
      <h1 style='color:#1e3a8a;font-size:28px;margin:0;'>MathSphere</h1>
      <p style='color:#6b7280;font-size:14px;margin-top:6px;'>Account Status Update</p>
    </div>
    <div style='text-align:center;margin-bottom:28px;'>
      <div style='display:inline-block;background:#dcfce7;border-radius:50%;
                  width:80px;height:80px;line-height:80px;font-size:42px;'>✅</div>
    </div>
    <p style='color:#1e3a8a;font-size:16px;margin-bottom:8px;'>Hi <strong>{System.Web.HttpUtility.HtmlEncode(toName)}</strong>,</p>
    <p style='color:#374151;font-size:15px;line-height:1.6;'>
      Great news! Your MathSphere account has been <strong>reactivated</strong> by an administrator.
      You can now log in and resume your learning journey! 🎉
    </p>
    <div style='background:#dcfce7;border-left:4px solid #22c55e;border-radius:12px;
                padding:20px 24px;margin:24px 0;'>
      <p style='margin:0;color:#166534;font-size:14px;line-height:1.7;'>
        Full access to your courses, assignments, and progress has been restored.
        Welcome back to MathSphere!
      </p>
    </div>
    <hr style='border:none;border-top:1px solid #e5e7eb;margin:28px 0;'/>
    <p style='color:#9ca3af;font-size:13px;text-align:center;'>
      This is an automated notification. Please do not reply to this email.
    </p>
    <p style='color:#d1d5db;font-size:12px;text-align:center;margin-top:16px;'>
      &copy; 2026 MathSphere Studios. All Rights Calculated.
    </p>
  </div>
</body></html>";
            Send(toEmail, subject, body);
        }

        // Account Deleted
        public static void SendAccountDeleted(string toEmail, string toName)
        {
            string subject = "MathSphere — Your Account Has Been Removed";
            string body = $@"
<!DOCTYPE html><html>
<body style='font-family:Arial,sans-serif;background:#f8f8f5;padding:30px;margin:0;'>
  <div style='max-width:520px;margin:auto;background:#fff;border-radius:20px;
              padding:40px;box-shadow:0 4px 24px rgba(0,0,0,0.08);'>
    <div style='text-align:center;margin-bottom:30px;'>
      <h1 style='color:#1e3a8a;font-size:28px;margin:0;'>MathSphere</h1>
      <p style='color:#6b7280;font-size:14px;margin-top:6px;'>Account Removal Notice</p>
    </div>
    <div style='text-align:center;margin-bottom:28px;'>
      <div style='display:inline-block;background:#fee2e2;border-radius:50%;
                  width:80px;height:80px;line-height:80px;font-size:42px;'>🗑️</div>
    </div>
    <p style='color:#1e3a8a;font-size:16px;margin-bottom:8px;'>Hi <strong>{System.Web.HttpUtility.HtmlEncode(toName)}</strong>,</p>
    <p style='color:#374151;font-size:15px;line-height:1.6;'>
      Your MathSphere account associated with <strong>{System.Web.HttpUtility.HtmlEncode(toEmail)}</strong> has been
      <strong>permanently removed</strong> from our platform by an administrator.
    </p>
    <div style='background:#fee2e2;border-left:4px solid #ef4444;border-radius:12px;
                padding:20px 24px;margin:24px 0;'>
      <p style='margin:0;color:#991b1b;font-size:14px;line-height:1.7;'>
        All associated data, course progress, and records have been removed.
        This action cannot be undone.
      </p>
    </div>
    <p style='color:#374151;font-size:15px;line-height:1.6;'>
      If you believe this was done in error, please reach out to the MathSphere admin team as soon as possible.
    </p>
    <hr style='border:none;border-top:1px solid #e5e7eb;margin:28px 0;'/>
    <p style='color:#9ca3af;font-size:13px;text-align:center;'>
      Thank you for being part of the MathSphere community.
    </p>
    <p style='color:#d1d5db;font-size:12px;text-align:center;margin-top:16px;'>
      &copy; 2026 MathSphere Studios. All Rights Calculated.
    </p>
  </div>
</body></html>";
            Send(toEmail, subject, body);
        }

        // Shared sender
        private static void Send(string toEmail, string subject, string htmlBody)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(GmailUser) || string.IsNullOrWhiteSpace(GmailPass))
                {
                    System.Diagnostics.Debug.WriteLine("EmailService: GmailUser or GmailAppPassword not configured in Web.config.");
                    return;
                }

                var message = new MimeMessage();
                message.From.Add(new MailboxAddress("MathSphere", GmailUser));
                message.To.Add(MailboxAddress.Parse(toEmail));
                message.Subject = subject;
                message.Body = new BodyBuilder { HtmlBody = htmlBody }.ToMessageBody();

                using (var client = new SmtpClient())
                {
                    client.Connect("smtp.gmail.com", 587, SecureSocketOptions.StartTls);
                    client.Authenticate(GmailUser, GmailPass);
                    client.Send(message);
                    client.Disconnect(true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Email send error: " + ex.Message);
            }
        }

        // Forum Post Warning
        public static void SendForumWarning(
            string toEmail, string toName, string postTitle,
            string warnType, string reason, string customMessage)
        {
            string subject = "MathSphere — Warning Issued for Your Forum Post";
            string body = $@"
                <!DOCTYPE html><html>
                <body style='font-family:Arial,sans-serif;background:#f8f8f5;padding:30px;margin:0;'>
                  <div style='max-width:520px;margin:auto;background:#fff;border-radius:20px;
                              padding:40px;box-shadow:0 4px 24px rgba(0,0,0,0.08);'>
                    <div style='text-align:center;margin-bottom:30px;'>
                      <h1 style='color:#1e3a8a;font-size:28px;margin:0;'>MathSphere</h1>
                      <p style='color:#6b7280;font-size:14px;margin-top:6px;'>Forum Moderation Notice</p>
                    </div>
                    <div style='text-align:center;margin-bottom:28px;'>
                      <div style='display:inline-block;background:#fef9c3;border-radius:50%;
                                  width:80px;height:80px;line-height:80px;font-size:42px;'>⚠️</div>
                    </div>
                    <p style='color:#1e3a8a;font-size:16px;margin-bottom:8px;'>
                      Hi <strong>{System.Web.HttpUtility.HtmlEncode(toName)}</strong>,
                    </p>
                    <p style='color:#374151;font-size:15px;line-height:1.6;'>
                      Your forum post has received a <strong>{System.Web.HttpUtility.HtmlEncode(warnType)} Warning</strong>
                      from a MathSphere moderator and is currently <strong>under review</strong>.
                    </p>
                    <div style='background:#fffbeb;border:2px solid #fde68a;border-radius:16px;
                                padding:24px;margin:24px 0;'>
                      <p style='margin:0 0 12px 0;color:#6b7280;font-size:11px;font-weight:900;
                                text-transform:uppercase;letter-spacing:0.1em;'>Post Details</p>
                      <p style='margin:0 0 8px 0;color:#1e3a8a;font-size:15px;font-weight:900;'>
                        &ldquo;{System.Web.HttpUtility.HtmlEncode(postTitle)}&rdquo;
                      </p>
                      <table style='width:100%;margin-top:12px;border-collapse:collapse;'>
                        <tr>
                          <td style='padding:6px 0;color:#374151;font-size:13px;font-weight:bold;width:100px;'>Warning Type</td>
                          <td style='padding:6px 0;color:#b45309;font-size:13px;font-weight:900;'>{System.Web.HttpUtility.HtmlEncode(warnType)}</td>
                        </tr>
                        <tr>
                          <td style='padding:6px 0;color:#374151;font-size:13px;font-weight:bold;'>Reason</td>
                          <td style='padding:6px 0;color:#374151;font-size:13px;'>{System.Web.HttpUtility.HtmlEncode(reason)}</td>
                        </tr>
                        {(!string.IsNullOrWhiteSpace(customMessage) ? $@"
                        <tr>
                          <td style='padding:6px 0;color:#374151;font-size:13px;font-weight:bold;vertical-align:top;'>Message</td>
                          <td style='padding:6px 0;color:#374151;font-size:13px;font-style:italic;'>{System.Web.HttpUtility.HtmlEncode(customMessage)}</td>
                        </tr>" : "")}
                      </table>
                    </div>
                    <div style='background:#fef2f2;border-left:4px solid #ef4444;border-radius:12px;
                                padding:16px 20px;margin-bottom:24px;'>
                      <p style='margin:0;color:#991b1b;font-size:13px;line-height:1.6;'>
                        ⚠️ Your post is currently <strong>under moderator review</strong>. 
                        Repeated violations may result in post removal or account suspension.
                        Please review our community guidelines.
                      </p>
                    </div>
                    <p style='color:#374151;font-size:14px;line-height:1.6;'>
                      If you believe this warning was issued in error, please contact the MathSphere support team.
                    </p>
                    <hr style='border:none;border-top:1px solid #e5e7eb;margin:28px 0;'/>
                    <p style='color:#9ca3af;font-size:13px;text-align:center;'>
                      This is an automated moderation notice. Please do not reply to this email.
                    </p>
                    <p style='color:#d1d5db;font-size:12px;text-align:center;margin-top:16px;'>
                      &copy; 2026 MathSphere Studios. All Rights Calculated.
                    </p>
                  </div>
                </body></html>";
            Send(toEmail, subject, body);
        }


        // Inactivity Reminder
        public static void SendInactivityReminder(
            string toEmail, string toName, int inactiveDays, DateTime lastActiveDate)
        {
            string subject = "MathSphere — We Miss You! 👋 Come Back and Keep Your Streak";
            string body = $@"
                <!DOCTYPE html><html>
                <body style='font-family:Arial,sans-serif;background:#f8f8f5;padding:30px;margin:0;'>
                  <div style='max-width:520px;margin:auto;background:#fff;border-radius:20px;
                              padding:40px;box-shadow:0 4px 24px rgba(0,0,0,0.08);'>
                    <div style='text-align:center;margin-bottom:30px;'>
                      <h1 style='color:#1e3a8a;font-size:28px;margin:0;'>MathSphere</h1>
                      <p style='color:#6b7280;font-size:14px;margin-top:6px;'>We miss you!</p>
                    </div>
                    <div style='text-align:center;margin-bottom:28px;'>
                      <div style='display:inline-block;background:#fef9c3;border-radius:50%;
                                  width:80px;height:80px;line-height:80px;font-size:42px;'>😴</div>
                    </div>
                    <p style='color:#1e3a8a;font-size:16px;margin-bottom:8px;'>
                      Hi <strong>{System.Web.HttpUtility.HtmlEncode(toName)}</strong>,
                    </p>
                    <p style='color:#374151;font-size:15px;line-height:1.6;'>
                      You haven't visited MathSphere in <strong>{inactiveDays} days</strong>
                      (last active: {System.Web.HttpUtility.HtmlEncode(lastActiveDate.ToString("dd MMM yyyy"))}).
                      Your streak is at risk — come back and keep the momentum going! 🔥
                    </p>
                    <div style='background:#fffbeb;border:2px solid #fde68a;border-radius:16px;
                                padding:24px;margin:24px 0;text-align:center;'>
                      <p style='margin:0 0 6px 0;color:#6b7280;font-size:12px;font-weight:900;
                                text-transform:uppercase;letter-spacing:0.1em;'>Your streak is waiting</p>
                      <p style='margin:0;color:#b45309;font-size:36px;font-weight:900;'>🔥</p>
                      <p style='margin:8px 0 0 0;color:#92400e;font-size:13px;font-weight:bold;'>
                        Log in today to keep it alive!
                      </p>
                    </div>
                    <div style='text-align:center;margin:32px 0;'>
                      <a href='https://localhost:44392/Login.aspx'
                         style='background:#2563eb;color:#fff;padding:16px 36px;border-radius:12px;
                                text-decoration:none;font-weight:bold;font-size:15px;
                                display:inline-block;letter-spacing:0.05em;'>
                        Resume Learning 🚀
                      </a>
                    </div>
                    <hr style='border:none;border-top:1px solid #e5e7eb;margin:28px 0;'/>
                    <p style='color:#9ca3af;font-size:13px;text-align:center;'>
                      This is an automated reminder. You can manage notification preferences in your account settings.
                    </p>
                    <p style='color:#d1d5db;font-size:12px;text-align:center;margin-top:16px;'>
                      &copy; 2026 MathSphere Studios. All Rights Calculated.
                    </p>
                  </div>
                </body></html>";
            Send(toEmail, subject, body);
        }


    }
}
