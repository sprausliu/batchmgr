using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class mc_input : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!GetRole().Contains("input")) {
           
                Jumpto("query.aspx");
     
        }
    }
    private void Jumpto(string url) {
        Response.Redirect(url);
    }
    private string[] GetRole() {
        List<string> ra = new List<string>();
        roleDataContext rdc = new roleDataContext();
        var q = from i in rdc.mgr_user_role
                 where i.userid == currentuser.Loginid&&i.location=="TJN"
                 select i;
        foreach (var i in q) {
            ra.Add(i.role);
        }
        return ra.ToArray();
    }
}