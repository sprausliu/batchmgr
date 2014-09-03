using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class pkg_print : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        packageDataContext pkdc = new packageDataContext();
        var nu = new NewUser("pkg");
        var q = from i in pkdc.package_using
                where i.u_status == 1
                select new { i.u_id, i.u_batch, i.u_cell, i.cell_info.cell_pkg_building, i.u_pkg_category, i.u_num };
        var auto = from i in q
                   where i.cell_pkg_building == "Auto"
                   group i by i.u_pkg_category into g
                   select new { cate=g.Key, tt = g.Sum(t => t.u_num) };
        autocntu.DataSource = auto;
        autototal.Text = "(" + auto.Sum(i => i.tt).ToString() + ")";
        autocntu.DataBind();
        var ic = from i in q
                 where i.cell_pkg_building == "IC"
                 group i by i.u_pkg_category into g
                 select new { cate = g.Key, tt = g.Sum(t => t.u_num) };
        iccntu.DataSource = ic;
        ictotal.Text = "(" + ic.Sum(i => i.tt).ToString() + ")";
        iccntu.DataBind();
        var ed = from i in q
                 where i.cell_pkg_building == "ED"
                 group i by i.u_pkg_category into g
                 select new { cate = g.Key, tt = g.Sum(t => t.u_num) };
        edcntu.DataSource = ed;
        edtotal.Text = "(" + ed.Sum(i => i.tt).ToString() + ")";
        edcntu.DataBind();
        var hde = from i in q
                  where i.cell_pkg_building == "HDE"
                 group i by i.u_pkg_category into g
                 select new { cate = g.Key, tt = g.Sum(t => t.u_num) };
        hdecntu.DataSource = hde;
        hdetotal.Text = "(" + hde.Sum(i => i.tt).ToString() + ")";
        hdecntu.DataBind();
        var wb = from i in q
                  where i.cell_pkg_building == "WB"
                  group i by i.u_pkg_category into g
                  select new { cate = g.Key, tt = g.Sum(t => t.u_num) };
        wbcntu.DataSource = wb;
        wbtotal.Text = "(" + wb.Sum(i => i.tt).ToString() + ")";
        wbcntu.DataBind();
        var wd = from i in q
                  where i.cell_pkg_building == "WOOD"
                  group i by i.u_pkg_category into g
                  select new { cate = g.Key, tt = g.Sum(t => t.u_num) };
        wdcntu.DataSource = wd;
        wdtotal.Text = "(" + wd.Sum(i => i.tt).ToString() + ")";
        wdcntu.DataBind();
    }
}