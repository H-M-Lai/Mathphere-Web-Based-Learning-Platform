using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace MathSphere
{
    public partial class setCourseValidity : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string courseName = Request.QueryString["courseName"];
                if (!string.IsNullOrEmpty(courseName))
                    litCourseName.Text = Server.HtmlEncode(courseName);

                txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");

                string sd = Request.QueryString["startDate"];
                string ed = Request.QueryString["endDate"];
                if (!string.IsNullOrEmpty(sd)) txtStartDate.Text = sd;
                if (!string.IsNullOrEmpty(ed)) txtEndDate.Text = ed;

                string arch = Request.QueryString["autoArchive"];
                bool autoArchive = true;
                if (!string.IsNullOrEmpty(arch))
                    bool.TryParse(arch, out autoArchive);
                hdnAutoArchive.Value = autoArchive ? "true" : "false";
            }
        }

        protected void btnSaveValidity_Click(object sender, EventArgs e)
        {
            string returnUrl = Request.QueryString["returnUrl"] ?? "teacherCreateCourse.aspx";
            string courseName = litCourseName.Text;
            string startDate = txtStartDate.Text.Trim();
            string endDate = txtEndDate.Text.Trim();

            bool autoArchive = true;
            bool.TryParse(hdnAutoArchive.Value, out autoArchive);

            // SERVER-SIDE VALIDATION
            // 1. End date is required
            if (string.IsNullOrEmpty(endDate))
            {
                ShowError("End date is required.");
                return;
            }

            // 2. Parse start date
            DateTime parsedStart = DateTime.MinValue;
            if (!string.IsNullOrEmpty(startDate))
            {
                if (!DateTime.TryParse(startDate, out parsedStart))
                {
                    ShowError("Start date is not a valid date.");
                    return;
                }
                // Year must be exactly 4 digits (between 1000 and 9999)
                if (parsedStart.Year < 1000 || parsedStart.Year > 9999)
                {
                    ShowError("Start date year must be a 4-digit year (e.g. 2025).");
                    return;
                }
                // Year must be reasonable — not more than 10 years in the future
                if (parsedStart.Year > DateTime.Today.Year + 10)
                {
                    ShowError("Start date year seems too far in the future. Please check.");
                    return;
                }
            }

            // 3. Parse end date
            DateTime parsedEnd;
            if (!DateTime.TryParse(endDate, out parsedEnd))
            {
                ShowError("End date is not a valid date.");
                return;
            }
            if (parsedEnd.Year < 1000 || parsedEnd.Year > 9999)
            {
                ShowError("End date year must be a 4-digit year (e.g. 2026).");
                return;
            }
            if (parsedEnd.Year > DateTime.Today.Year + 10)
            {
                ShowError("End date year seems too far in the future. Please check.");
                return;
            }

            // 4. End must be after start
            if (parsedStart != DateTime.MinValue && parsedEnd <= parsedStart)
            {
                ShowError("End date must be after the start date.");
                return;
            }

            // 5. End date must be in the future
            if (parsedEnd.Date < DateTime.Today)
            {
                ShowError("End date cannot be in the past.");
                return;
            }

            // All valid — determine status
            string status = "Draft";
            if (parsedStart != DateTime.MinValue && parsedStart.Date <= DateTime.Today)
                status = "Active";

            string qs = string.Format(
                "?startDate={0}&endDate={1}&autoArchive={2}&status={3}&courseName={4}",
                Uri.EscapeDataString(startDate),
                Uri.EscapeDataString(endDate),
                autoArchive.ToString().ToLower(),
                Uri.EscapeDataString(status),
                Uri.EscapeDataString(courseName));

            Response.Redirect(returnUrl + qs, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string message)
        {
            // Re-populate the course name label after postback
            string courseName = Request.QueryString["courseName"];
            if (!string.IsNullOrEmpty(courseName))
                litCourseName.Text = Server.HtmlEncode(courseName);

            pnlError.Visible = true;
            lblError.Text = message;
        }
    }
}
