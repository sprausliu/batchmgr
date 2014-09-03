using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// lpi 的摘要说明
/// </summary>
[WebService(Namespace = "TJITCV")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消注释以下行。 
// [System.Web.Script.Services.ScriptService]
public class lpi : System.Web.Services.WebService {

    public lpi () {

        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 
    }
    [WebMethod]
    public bool DrumNoVerify(string networkid)
    {
        return GeneralVerify(networkid, "DrumNo");
    }
    private bool GeneralVerify(string networkid, string appcode)
    {
        using (ClientVerifyDataContext cvdc = new ClientVerifyDataContext())
        {
            var q = from i in cvdc.Client_Verify
                    where i.AppName == appcode && i.Loginid == networkid
                    select i;
            if (q.Count() > 0)
            {
                return q.Single().available;
            }
            else
            {
                return false;
            }
        }
    }
    
}
