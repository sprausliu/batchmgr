<%@ WebHandler Language="C#" Class="hold" %>

using System;
using System.Web;
using System.Linq;

public class hold : IHttpHandler {
    string orgn = currentuser.Bcorgn;
    string login = currentuser.Loginid;
    string[] role = currentuser.Bclab;
    bool islab = currentuser.Bclab.Count(i => i.ToString() != "OP") > 0;
    bcDataContext bcdc = new bcDataContext();
    public void ProcessRequest(HttpContext context)
    {
        string batch = context.Request.QueryString["batchid"];
        if (islab)
        {
            if (batch != null)
            {
                try
                {
                    int bi = int.Parse(batch);
                    var q = (from i in bcdc.batch_confirmation
                             where i.r_id == bi
                             select i).Single();
                    if (q.r_status == 3)
                    {
                        context.Response.Write(q.batch_no + "已经批准过了");
                    }
                    else if (q.r_status == 4)
                    {
                        context.Response.Write(q.batch_no + "已经拒绝过了");
                    }
                    else
                    {
                        if (role.Contains(q.assign_lab))
                        {
                            q.r_status = 2;
                            q.lab_comment = "";
                            var bca = new batch_confirmation_action
                            {
                                r_id = q.r_id,
                                batch_no = q.batch_no,
                                action = "Hold",
                                comment = q.lab_comment,
                                @operator = login,
                                login_time = DateTime.Now
                            };
                            bcdc.batch_confirmation_action.InsertOnSubmit(bca);
                            bcdc.SubmitChanges();
                            context.Response.Write("<script>alert('你已经HOLD住" + q.batch_no + "!');window.close()</script>");
                        }
                        else
                        {
                            context.Response.Write("权限不足！");
                        }
                    }
                }
                catch
                {
                    context.Response.Write("参数错误。");
                }
            }
            else
            {
                context.Response.Write("缺少参数。");
            }
        }
        else
        {
            context.Response.Write("权限不足！");
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}