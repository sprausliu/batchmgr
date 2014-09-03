using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class bc_upload : System.Web.UI.Page
{
    bool isop = currentuser.Bclab.Contains("OP");
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!isop) {
            Response.Write("<script>alert('You have no permission!')</script>");
            Response.Redirect("denie.html");
        }
    }
}