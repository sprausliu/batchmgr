using System;
using System.Configuration;

public partial class background_wipcount : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ConfigurationManager.AppSettings["wuauthswitch"] == "1" && !currentuser.CheckRole("cell", "wu"))
        {
            Response.Redirect("denie.html");
        }
    }
}
