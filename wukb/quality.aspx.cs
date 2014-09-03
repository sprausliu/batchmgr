using System;
using System.Configuration;

public partial class background_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ConfigurationManager.AppSettings["wuauthswitch"] == "1" && !currentuser.CheckRole("quality", "wu"))
        {
            Response.Redirect("denie.html");
        }
    }
}