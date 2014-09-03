using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Services;

/// <summary>
/// e_coa 的摘要说明
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消注释以下行。 
// [System.Web.Script.Services.ScriptService]
public class csv : System.Web.Services.WebService {

    public csv () {

        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 
    }

    [WebMethod]
    public string ECOAVerify(string networkid,string password)
    {
        try
        {
            return GeneralVerify(networkid, password, "ECOA").ToString();
        }
        catch (Exception ex){
            return ex.Message;
        }
    }
    [WebMethod]
    public string DellQR(string networkid) {
        try
        {
            return GeneralVerify(networkid, "DellQR").ToString();
        }
        catch (Exception ex){
            return ex.Message;
        }
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
    private bool GeneralVerify(string loginid, string pwd, string appcode) {
        using (ClientVerifyDataContext cvdc = new ClientVerifyDataContext()) {
            var q = from i in cvdc.Client_Verify
                    where i.AppName == appcode && i.Loginid == loginid
                    select i;
            if (q.Count() > 0)
            {
                if (q.Single().PWD == pwd)
                {
                    return q.Single().available;
                }
                else
                {
                    throw new Exception("Password Wrong");
                }
            }
            else {
                throw new Exception("No Permission");
            }
        }
    }
    [WebMethod]
    public byte[] GetECOASignature(string username) {
        //Image i = Image.FromFile(Server.MapPath("~/ecoasign/") + username + ".jpg");
        //return i;
        System.IO.MemoryStream m = new System.IO.MemoryStream();
        System.Drawing.Bitmap bp = new System.Drawing.Bitmap(Server.MapPath("~/ecoasign/") + username + ".png");
        bp.Save(m, System.Drawing.Imaging.ImageFormat.Png);
        bp.Dispose();
        return m.GetBuffer();
    }
    [WebMethod]
    public void ResetECOAPwdMail(string username) {
        using (ClientVerifyDataContext cvdc = new ClientVerifyDataContext()) {
            Guid gid = Guid.NewGuid();
            ResetPWDRequest rpr = new ResetPWDRequest
            {
                guid = gid,
                loginid = username,
                requestDate = DateTime.Now,
                valid = true
            };
            mail m = new mail();
            string mb = Resources.bc.resetpwd;
            mb = mb.Replace("$link$", "http://stjnapp03/batchmgr/ecoasign/resetpwd.aspx?guid="+gid);
            m.Body = mb;
            m.Subject = Resources.bc.resetECOApwdsub;
            List<string> t = new List<string>();
            t.Add(username + "@ppg.com");
            m.recipient = t;
            m.send();
            cvdc.ResetPWDRequest.InsertOnSubmit(rpr);
            cvdc.SubmitChanges();
            
        }
    }
}
