using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class pkg_st : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string bu = Request.QueryString["building"];
        string dbu;
        switch (bu) {
            case "Auto":
                dbu = "AUTO";
                break;
            case "IC":
                dbu = "CE/IF";
                break;
            case "ED":
                dbu = "E-COAT";
                break;
            case "HDE":
                dbu = "HDE";
                break;
            case "WB":
                dbu = "WATER";
                break;
            case "WOOD":
                dbu = "WOOD";
                break;
            default:
                dbu = bu;
                break;
        }
        bn.Text = dbu;
        bns.Text = dbu;
        now.Text = DateTime.Now.ToLocalTime().ToString();
        packageDataContext pkdc = new packageDataContext();
        var q = from i in pkdc.package_using
                where i.cell_info.cell_pkg_building == bu
                select new
                {
                    i.u_id,
                    i.u_batch,
                    i.cell_info.cell_name,
                    i.u_user,
                    i.u_pkg_category,
                    i.u_num
                };
        cnttotal.Text = q.Sum(s => s.u_num).ToString();
        ls.DataSource = q;
        ls.DataBind();
        lns.Text = string.Join(",", q.Select(l => l.u_id.ToString()).ToArray());
    }
}
