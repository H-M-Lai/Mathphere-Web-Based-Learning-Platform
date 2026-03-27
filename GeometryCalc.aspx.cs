using System;
using System.Web.UI;

namespace MathSphere
{
    public partial class GeometryCalc : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string userId = Session["userID"]?.ToString() ?? "";
            bool isGuest = Session["IsGuest"] is bool b && b;

            if (!isGuest && string.IsNullOrWhiteSpace(userId))
            {
                Response.Redirect("~/Login.aspx", true);
            }
        }
    }
}