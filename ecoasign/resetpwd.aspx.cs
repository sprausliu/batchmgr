using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ecoasign_resetpwd : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string gid = Request.QueryString["guid"];
        try
        {
            ResetPWDRequest rpr = CheckReq(gid);
            
            if (rpr.valid == false)
            {
                invalid.Visible = true;
            }
            else if ((DateTime.Now - rpr.requestDate).TotalMinutes > 120)
            {
                expired.Visible = true;
            }
            else
            {
                resetpwd.Visible = true;
                username.Text = rpr.loginid;
            }
        }
        catch (ArgumentNullException an)
        {
            Response.Write("参数不全");
        }
        catch {
            throw;
        }
    }
    private ResetPWDRequest CheckReq(string gid) {
        Guid g = new Guid(gid);
        using (ClientVerifyDataContext cvdc = new ClientVerifyDataContext()) {
            var q = from i in cvdc.ResetPWDRequest
                    where i.guid == g
                    select i;
            if (q.Count() == 1)
            {
                return q.Single();
            }
            else {
                throw new Exception("无效的ID");
            }
        }
    }
    protected void submitreset_Click(object sender, EventArgs e)
    {
        try
        {
            if (newpwd.Text != "")
            {
                using (ClientVerifyDataContext cvdc = new ClientVerifyDataContext())
                {
                    var qi = (from i in cvdc.ResetPWDRequest
                              where i.guid == new Guid(Request.QueryString["guid"])
                              select i).Single();
                    var q = (from i in cvdc.Client_Verify
                             where i.AppName == "ECOA" && i.Loginid == username.Text
                             select i).Single();
                    q.PWD = newpwd.Text;
                    qi.valid = false;
                    cvdc.SubmitChanges();
                    Response.Write("<script>alert('密码已更改');window.close();</script>");
                    Page.Load();
                }
            }
        }
        catch (InvalidOperationException ex) {
            Response.Write("<script>alert('账户不存在')</script>");
        }
    }
}