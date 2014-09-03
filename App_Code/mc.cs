using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;

/// <summary>
///mc 的摘要说明
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
//若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。 
[System.Web.Script.Services.ScriptService]
public class mc : System.Web.Services.WebService
{
    mcDataContext mdc = new mcDataContext();
    public mc()
    {

        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object[] mcquery()
    {
        var q = (from i in mdc.manual_close
                 select i).OrderByDescending(o => o.r_inputdate);
        return q.Take(2000).ToArray();
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void mcinput(mcmodel mcs)
    {
        if (!CheckBatch(mcs.batch_no))
        {
            var mc = new manual_close { batch_no = mcs.batch_no.ToUpper(), r_reason = mcs.r_reason, r_type = mcs.r_type ,r_dept=mcs.r_dept,r_operator=mcs.r_operator};
            mc.r_inputdate = DateTime.Now;
            mc.r_inputer = currentuser.Loginid.ToUpper();
            mdc.manual_close.InsertOnSubmit(mc);
            mdc.SubmitChanges();
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void mcupdate(manual_close mcs)
    {
        //foreach (manual_close mci in mcs)
        //{
            var q = (from i in mdc.manual_close
                     where i.r_id == mcs.r_id
                     select i).First();
            q.r_reason = mcs.r_reason;
            q.r_type = mcs.r_type;
            q.r_dept = mcs.r_dept;
            q.r_operator = mcs.r_operator;
            q.r_updateby = currentuser.Loginid.ToUpper();
            q.r_updated = DateTime.Now;
        //}
        mdc.SubmitChanges();
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public bool CheckBatch(string batchno) {
        var q = (from i in mdc.manual_close
                 where i.batch_no == batchno
                 select i).Count();
        return q != 0;
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object[] ChartDate(DateTime start, DateTime end) {
        var q = (from i in mdc.manual_close
                 where i.r_inputdate>=start.Date&&i.r_inputdate<end.Date
                 group i by new { i.r_dept, i.r_type } into g                 
                 select new { num = g.Count(), g.Key.r_dept,g.Key.r_type });
        return q.ToArray();
    }
}
