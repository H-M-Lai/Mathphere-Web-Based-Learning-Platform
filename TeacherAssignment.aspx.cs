using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Assignment
{
    public partial class TeacherAssignment : System.Web.UI.Page
    {
        public class Assignment
        {
            public string Title { get; set; }
            public string Subject { get; set; }
            public string Due { get; set; }
            public int Progress { get; set; }
            public string Icon { get; set; }
            public string AssignedBy { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Only bind on the first load; PostBacks (like Search) handle their own binding
            if (!IsPostBack)
            {
                BindAssignments();
            }
        }

        // Centralized data source
        private List<Assignment> GetMissionsList()
        {
            return new List<Assignment>()
            {
                new Assignment { Title = "The Secrets of Shapes & Angles", Subject = "Geometry", Due = "DUE IN 2 DAYS", Progress = 68, Icon = "architecture", AssignedBy = "Ms. Smith" },
                new Assignment { Title = "Chance, Luck & Statistics", Subject = "Probability", Due = "DUE TOMORROW", Progress = 42, Icon = "casino", AssignedBy = "Ms. Smith" },
                new Assignment { Title = "Solving Linear Equations", Subject = "Algebra", Due = "NEWLY ASSIGNED", Progress = 91, Icon = "functions", AssignedBy = "Mr. Henderson" }
            };
        }

        private void BindAssignments(string query = "")
        {
            var assignments = GetMissionsList();

            if (!string.IsNullOrWhiteSpace(query))
            {
                // Case-insensitive filtering
                assignments = assignments.Where(m =>
                    m.Title.IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0 ||
                    m.Subject.IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0
                ).ToList();
            }

            rptAssignments.DataSource = assignments;
            rptAssignments.DataBind();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindAssignments(txtSearch.Text);
        }

        protected void rptAssignments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // IMPORTANT: Match this CommandName to your .aspx button's CommandName
            if (e.CommandName == "StartMission" || e.CommandName == "Start")
            {
                string missionTitle = e.CommandArgument.ToString();
                Response.Redirect($"MissionPage.aspx?title={Server.UrlEncode(missionTitle)}");
            }
        }

        // This method can be removed if you are using rptAssignments_ItemCommand instead
        protected void btnStartMission_Command(object sender, CommandEventArgs e)
        {
            // Handled by ItemCommand
        }

        
    }
}