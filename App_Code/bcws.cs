using System;
using System.Linq;
using System.Web.Script.Services;
using System.Web.Services;
using System.Collections.Generic;
using System.Net.Mail;
using System.Configuration;
using System.Net;
using System.Resources;
using System.Reflection;
using System.Text;
using System.IO;
using System.Data;
using ITMAN;

/// <summary>
///bcws 的摘要说明
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
//若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。 
[System.Web.Script.Services.ScriptService]
public class bcws : System.Web.Services.WebService {
    bcDataContext bcdc = new bcDataContext();
    string orgn = currentuser.Bcorgn;
    string login = currentuser.Loginid;
    string[] role = currentuser.Bclab;
    bool islab = currentuser.Bclab.Count(i => i.ToString() != "OP") > 0;
    bool isop = currentuser.Bclab.Contains("OP");
    public bcws () {
        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 
    }
    void sc_SendCompleted(object sender, System.ComponentModel.AsyncCompletedEventArgs e)
    {
        string token = e.UserState.ToString();
        string path = System.Web.HttpContext.Current.Server.MapPath("");
        using (StreamWriter sw = new StreamWriter(System.Web.HttpContext.Current.Server.MapPath("")+"\\mail.log",true))
        {
            sw.Write(DateTime.Now.ToString() + ":");
            if (e.Cancelled)
            {
                sw.WriteLine("[{0}] Send canceled.", token);
            }
            if (e.Error != null)
            {
                sw.WriteLine("[{0}]{1}", token, e.Error.Message);
            }
            else
            {
                sw.WriteLine("[{0}] Send successful.", token);
            }
            sw.Close();
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string[] LabList() {
        LabDataContext ldc = new LabDataContext();
        var q = from i in ldc.Lab
                select new { i.lab_name };
        List<string> ll = new List<string>();
        foreach (var li in q) {
            ll.Add(li.lab_name);
        }
        return ll.ToArray();
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public bool SendBatchMail(bcmodelop bmo) {
        var itman = new query();
        itman.Credentials = System.Net.CredentialCache.DefaultCredentials;
        var q = (from i in bcdc.batch_confirmation
                where i.r_id == bmo.r_id
                select i).Single();
        roleDataContext rdc=new roleDataContext();
        var r=(from o in rdc.mgr_user_role
               where o.dept==q.assign_lab
               select new {o.userid}).ToArray();
        if (r.Length > 0)
        {
            SmtpClient sc = new SmtpClient(ConfigurationManager.AppSettings["smtpserver"]);
            sc.UseDefaultCredentials = false;
            sc.EnableSsl = false;

            sc.Credentials = new NetworkCredential(ConfigurationManager.AppSettings["LoginId"], ConfigurationManager.AppSettings["password"], ConfigurationManager.AppSettings["maildomain"]);
            sc.DeliveryMethod = SmtpDeliveryMethod.Network;
            MailMessage mm = new MailMessage();
            mm.Priority = MailPriority.Normal;
            mm.From = new MailAddress(ConfigurationManager.AppSettings["mailfrom"]);
            foreach (var ri in r)
            {
                mm.To.Add(ri.userid + "@ppg.com");
            }
            mm.CC.Add(q.add_by + "@ppg.com");
            mm.SubjectEncoding = Encoding.GetEncoding(936);
            mm.BodyEncoding = mm.SubjectEncoding;
            mm.IsBodyHtml = true;
            var mailbody = Resources.bc.mailbody;
            mailbody = mailbody.Replace("$r_id", q.r_id.ToString());
            mailbody = mailbody.Replace("$batch", q.batch_no);
            mailbody = mailbody.Replace("$item", q.item_code);
            mailbody = mailbody.Replace("$qty", q.qty.ToString());
            mailbody = mailbody.Replace("$shippingdate", q.shipping_date.ToString());
            mailbody = mailbody.Replace("$recipever", q.recipe_ver.ToString());
            mailbody = mailbody.Replace("$history", q.history.ToString());
            mailbody = mailbody.Replace("$opcomment", q.planner_comment);
            mailbody = mailbody.Replace("$creator",itman.L2C(q.add_by));
            mm.Body = mailbody;
            mm.Subject = Resources.bc.singlebatchsub.Replace("$batch", q.batch_no);
            try
            {
                //sc.Send(mm);
                sc.SendCompleted += sc_SendCompleted;
                sc.SendAsync(mm, q.r_id);
                q.mail_times++;
                bcdc.SubmitChanges();
                return true;
            }
            catch
            {
                throw;
            }
        }
        else {
            throw new Exception("此实验室无人可以授权");
        }
    }
    public static bool ResponsMail(int batchid) {
        try
        {
            bcDataContext bcdc = new bcDataContext();
            var q = (from i in bcdc.batch_confirmation
                     where i.r_id == batchid
                     select new
                     {
                         i.r_id,
                         i.batch_no,
                         i.lab_comment,
                         i.r_status,
                         i.add_by,
                         i.adj_lab
                     }).Single();            
            SmtpClient sc = BuildSMTP();
            MailMessage mm = MMBase();
            mm.To.Add(q.add_by + "@ppg.com");
            if (q.r_status == 3) {
                var mailbody = Resources.bc.approvemail;
                mailbody = mailbody.Replace("$approvedby", currentuser.Chinesename);
                mailbody = mailbody.Replace("$adjlab", q.adj_lab);
                mailbody = mailbody.Replace("$labcomment", q.lab_comment);
                mm.Body = mailbody;
                mm.Subject = Resources.bc.approvebatch.Replace("$batch", q.batch_no);
            }
            else if (q.r_status == 4) {
                var mailbody = Resources.bc.rejectmail;
                mailbody = mailbody.Replace("$rejectby", currentuser.Chinesename);
                mailbody = mailbody.Replace("$labcomment", q.lab_comment);
                mm.Body = mailbody;
                mm.Subject = Resources.bc.rejectbatch.Replace("$batch", q.batch_no);
            }
            if (mm.Body != "" && mm.Subject != "")
            {
                try
                {
                    sc.SendAsync(mm, q.r_id);
                    return true;
                }
                catch
                {
                    throw;
                }
            }
            else
            {
                return false;
            }
        }
        catch {
            throw;
        }         

    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public bool SendMultipleMail(int[] Is)
    {
        var q = from i in bcdc.batch_confirmation
                where Is.Contains(i.r_id)
                select i;
        roleDataContext rdc = new roleDataContext();
        var itman = new query();
        itman.Credentials = System.Net.CredentialCache.DefaultCredentials;
        if (q.Count() > 0)
        {
            foreach (batch_confirmation bc in q)
            {
                var r = (from o in rdc.mgr_user_role
                         where o.dept == bc.assign_lab
                         select new { o.userid }).ToArray();
                if (r.Length > 0)
                {
                    SmtpClient sc = new SmtpClient(ConfigurationManager.AppSettings["smtpserver"]);
                    sc.UseDefaultCredentials = false;
                    sc.EnableSsl = false;

                    sc.Credentials = new NetworkCredential(ConfigurationManager.AppSettings["LoginId"], ConfigurationManager.AppSettings["password"], ConfigurationManager.AppSettings["maildomain"]);
                    sc.DeliveryMethod = SmtpDeliveryMethod.Network;
                    MailMessage mm = new MailMessage();
                    mm.Priority = MailPriority.Normal;
                    mm.From = new MailAddress(ConfigurationManager.AppSettings["mailfrom"]);
                    foreach (var ri in r)
                    {
                        mm.To.Add(ri.userid + "@ppg.com");
                    }
                    mm.CC.Add(bc.add_by + "@ppg.com");
                    mm.SubjectEncoding = Encoding.GetEncoding(936);
                    mm.BodyEncoding = mm.SubjectEncoding;
                    mm.IsBodyHtml = true;
                    var mailbody = Resources.bc.mailbody;
                    mailbody = mailbody.Replace("$r_id", bc.r_id.ToString());
                    mailbody = mailbody.Replace("$batch", bc.batch_no);
                    mailbody = mailbody.Replace("$item", bc.item_code);
                    mailbody = mailbody.Replace("$qty", bc.qty.ToString());
                    mailbody = mailbody.Replace("$shippingdate", bc.shipping_date.ToString());
                    mailbody = mailbody.Replace("$recipever", bc.recipe_ver.ToString());
                    mailbody = mailbody.Replace("$history", bc.history.ToString());
                    mailbody = mailbody.Replace("$opcomment", bc.planner_comment);
                    mailbody = mailbody.Replace("$creator", itman.L2C(bc.add_by));
                    mm.Body = mailbody;
                    mm.Subject = Resources.bc.singlebatchsub.Replace("$batch", bc.batch_no);
                    try
                    {
                        //sc.Send(mm);
                        sc.SendCompleted += sc_SendCompleted;
                        sc.SendAsync(mm, bc.r_id);
                        bc.mail_times++;
                        bcdc.SubmitChanges();
                    }
                    catch
                    {
                        throw;
                    }
                }
                else
                {
                    throw new Exception("此实验室无人可以授权");
                }
            }
            return true;
        }
        else
        {
            throw new Exception("");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public bool SendMail(string batchno)
    {
        var itman = new query();
        itman.Credentials = System.Net.CredentialCache.DefaultCredentials;
        var q = (from i in bcdc.batch_confirmation
                 where i.batch_no == batchno
                 select i).Single();
        roleDataContext rdc = new roleDataContext();
        var r = (from o in rdc.mgr_user_role
                 where o.dept == q.assign_lab
                 select new { o.userid }).ToArray();
        SmtpClient sc = BuildSMTP();
        MailMessage mm = MMBase();
        foreach (var ri in r)
        {
            mm.To.Add(ri.userid + "@ppg.com");
        }
        mm.CC.Add(q.add_by + "@ppg.com");
        var mailbody = Resources.bc.mailbody;
        mailbody = mailbody.Replace("$r_id", q.r_id.ToString());
        mailbody = mailbody.Replace("$batch", q.batch_no);
        mailbody = mailbody.Replace("$item", q.item_code);
        mailbody = mailbody.Replace("$qty", q.qty.ToString());
        mailbody = mailbody.Replace("$shippingdate", q.shipping_date.ToString());
        mailbody = mailbody.Replace("$recipever", q.recipe_ver.ToString());
        mailbody = mailbody.Replace("$history", q.history.ToString());
        mailbody = mailbody.Replace("$opcomment", q.planner_comment);
        mailbody = mailbody.Replace("$creator",itman.L2C(q.add_by));
        mm.Body = mailbody;
        mm.Subject = Resources.bc.singlebatchsub.Replace("$batch", q.batch_no);
        try
        {
           // sc.Send(mm);
            sc.SendCompleted += sc_SendCompleted;
            sc.SendAsync(mm, q.r_id);
            q.mail_times++;
            bcdc.SubmitChanges();
            return true;
        }
        catch
        {
            throw;
        }
    }
    public static MailMessage MMBase() {
        MailMessage mm = new MailMessage();
        mm.Priority = MailPriority.Normal;
        mm.From = new MailAddress(ConfigurationManager.AppSettings["mailfrom"]);
        mm.SubjectEncoding = Encoding.GetEncoding(936);
        mm.BodyEncoding = mm.SubjectEncoding;
        mm.IsBodyHtml = true;
        return mm;
    }
    public static SmtpClient BuildSMTP() {
        SmtpClient sc = new SmtpClient(ConfigurationManager.AppSettings["smtpserver"]);
        sc.UseDefaultCredentials = false;
        sc.EnableSsl = false;
        sc.Credentials = new NetworkCredential(ConfigurationManager.AppSettings["LoginId"], ConfigurationManager.AppSettings["password"], ConfigurationManager.AppSettings["maildomain"]);
        sc.DeliveryMethod = SmtpDeliveryMethod.Network;
        return sc;
    }
    public static string GetResourceByKey(string resourceName,string key){
        ResourceManager rm = new ResourceManager(resourceName, Assembly.GetExecutingAssembly());
        rm.IgnoreCase = true;
        string strvalue = rm.GetString(key);
        rm = null;
        return strvalue;
    }
	    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object[] GetBatchList_View(int type, int take)
    {
            var q = (from i in bcdc.batch_confirmation
                     //where i.add_by == login
                     select
                     new
                     {
                         i.batch_no,
                         i.item_code,
                         i.qty,
                         i.Uom,
                         i.shipping_date,
                         i.recipe_ver,
                         i.history,
                         i.planner_comment,
                         i.assign_lab,
                         i.adj_lab,
                         i.lab_comment,
                         i.r_status,
                         i.add_date,
                         i.add_by,
                         i.modify_by,
                         i.modify_date,
                         i.check_times,
                         i.current_officer,
                         i.r_id,
                         i.r_orgn,
                         i.mail_times,
                         approveby = i.batch_confirmation_action.Where(f => f.action == "Approve").OrderByDescending(o => o.login_time).First().@operator,
                         rejectby = i.batch_confirmation_action.Where(f => f.action == "Reject").OrderByDescending(o => o.login_time).First().@operator
                     }
                     );
            if (type != 0)
            {
                q = q.Where(f => f.r_status == type);
                if (type == 5 || type == -1)
                {
                    q = q.Take(take);
                }
            }
            return q.OrderByDescending(o => o.add_date).ToArray();
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat=ResponseFormat.Json)]
    public object[] GetBatchList_planner(int type,int take){
        if (isop)
        {
            var q = (from i in bcdc.batch_confirmation
                     
                     select
                     new
                     {
                         i.batch_no,
                         i.item_code,
                         i.qty,
                         i.Uom,
                         i.shipping_date,
                         i.recipe_ver,
                         i.history,
                         i.planner_comment,
                         i.assign_lab,
                         i.adj_lab,
                         i.lab_comment,
                         i.r_status,
                         i.add_date,
                         i.add_by,
                         i.modify_by,
                         i.modify_date,
                         i.check_times,
                         i.current_officer,
                         i.r_id,
                         i.r_orgn,
                         i.mail_times,
                         approveby=i.batch_confirmation_action.Where(f=>f.action=="Approve").OrderByDescending(o=>o.login_time).First().@operator,
                         rejectby = i.batch_confirmation_action.Where(f => f.action == "Reject").OrderByDescending(o => o.login_time).First().@operator
                     }
                     );
            if (type != 0) {
                q = q.Where(f => f.r_status == type);
                if (type == 5 || type == -1) {
                    q = q.OrderByDescending(o => o.add_date).Take(take);
                }
            }
            return q.OrderByDescending(o => o.add_date).Take(1000).ToArray();
        }
        else {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void InputNewBatch(bcmodelop bmo) {
        if (isop)
        {
            if (bcdc.batch_confirmation.Where(c => c.batch_no == bmo.batch_no).Count() == 0)
            {
                var bc = new batch_confirmation
                {
                    batch_no = bmo.batch_no.ToUpper(),
                    item_code = bmo.item_code,
                    qty = (decimal)bmo.qty,
                    shipping_date = bmo.shipping_date,
                    recipe_ver = bmo.recipe_ver,
                    history = bmo.history,
                    planner_comment = bmo.planner_comment,
                    assign_lab = bmo.assign_lab,
                    mail_times = 0
                };
                bc.r_status = 1;
                bc.r_orgn = orgn;
                bc.add_by = login;
                bc.add_date = DateTime.Now;
                bcdc.batch_confirmation.InsertOnSubmit(bc);
                bcdc.SubmitChanges();
            }
            else
            {
                throw new Exception("重复的批号");
            }
        }
        else {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void OPUpdateBatch(bcmodelop bmo) {
        if (isop)
        {
            var q = bcdc.batch_confirmation.Single(i => i.r_id == bmo.r_id);
            string updatecomment = "";
            if (q.batch_no != bmo.batch_no) {
                updatecomment += "Batch:\"" + q.batch_no + "\"->\"" + bmo.batch_no + "\";\n";
                q.batch_no = bmo.batch_no;
            }
            if (q.item_code != bmo.item_code)
            {                
                updatecomment += "Item:\"" + q.item_code + "\"->\"" + bmo.item_code + "\";\n";
                q.item_code = bmo.item_code;
            }
            if (q.qty != bmo.qty)
            {                
                updatecomment += "Qty:\"" + q.qty.ToString() + "\"->\"" + bmo.qty.ToString() + "\";\n";
                q.qty = bmo.qty;
            }
            if (q.shipping_date != bmo.shipping_date)
            {
                updatecomment += "Shipping Date:\"" + q.shipping_date.Value.ToShortDateString() + "\"->\"" + bmo.shipping_date.Value.ToShortDateString() + "\";\n";
                q.shipping_date = bmo.shipping_date;
            }
            if (q.recipe_ver != bmo.recipe_ver)
            {
                updatecomment += "Recipe Ver:\"" + q.recipe_ver.ToString() + "\"->\"" + bmo.recipe_ver.ToString() + "\";\n";
                q.recipe_ver = bmo.recipe_ver;
            }
            if (q.history != bmo.history)
            {
                updatecomment += "History:\"" + q.history.ToString() + "\"->\"" + bmo.history.ToString() + "\";\n";
                q.history = bmo.history;
            }
            if (q.planner_comment != bmo.planner_comment)
            {
                updatecomment += "OP Comment:\"" + q.planner_comment + "\"->\"" + bmo.planner_comment + "\";\n";
                q.planner_comment = bmo.planner_comment;
            }
            if (q.assign_lab != bmo.assign_lab)
            {
                updatecomment += "Lab:\"" + q.assign_lab + "\"->\"" + bmo.assign_lab + "\";\n";
                q.assign_lab = bmo.assign_lab;
            }
            if (updatecomment != "")
            {
                q.modify_by = login;
                q.modify_date = DateTime.Now;
                var bca = new batch_confirmation_action
                {
                    r_id = q.r_id,
                    batch_no = bmo.batch_no,
                    action = "Update",
                    comment = updatecomment,
                    @operator = login,
                    login_time = DateTime.Now
                };
                bcdc.batch_confirmation_action.InsertOnSubmit(bca);
                bcdc.SubmitChanges();
            }
        }
        else
        {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void CancelBatch(bcmodelop bmo) {
        if (isop)
        {
            var q = bcdc.batch_confirmation.Single(i => i.batch_no == bmo.batch_no);
            q.r_status = -1;
            var bca = new batch_confirmation_action
            {
                r_id = q.r_id,
                batch_no = bmo.batch_no,
                action = "Cancel",
                @operator = login,
                login_time = DateTime.Now
            };
            bcdc.batch_confirmation_action.InsertOnSubmit(bca);
            bcdc.SubmitChanges();
        }
        else
        {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object[] GetBatchList_lab(int take,int page)
    {
        if (islab)
        {
            var q = from i in bcdc.batch_confirmation
                    where (currentuser.Bclab).Contains(i.assign_lab)
                    select new
                    {
                        i.batch_no,
                        i.item_code,
                        i.qty,
                        i.Uom,
                        i.shipping_date,
                        i.recipe_ver,
                        i.history,
                        i.planner_comment,
                        i.assign_lab,
                        i.adj_lab,
                        i.lab_comment,
                        i.r_status,
                        i.add_date,
                        i.add_by,
                        i.modify_by,
                        i.modify_date,
                        i.check_times,
                        i.current_officer,
                        i.r_id,
                        i.r_orgn
                    };
            if (page == 1)
            {
                q = q.Where(f => f.r_status == 5);
            }
            else {
                q = q.Where(f => f.r_status == 1 || f.r_status == 6||f.r_status==2);
            }
            return q.OrderByDescending(o=>o.add_date).Take(take).ToArray();
        }
        else
        {
            throw new Exception("No enough permission");
        }      
    }
    private void NeedTechSendMail(batch_confirmation bc, string holder, string signature)
    {
        //var itman = new query();
        //itman.Credentials = System.Net.CredentialCache.DefaultCredentials;
        SmtpClient sc = BuildSMTP();
        MailMessage mm = MMBase();
        mm.To.Add(bc.add_by + "@ppg.com");
        mm.CC.Add(holder + "@ppg.com");
        mm.Body = "批次 " + bc.batch_no + " (产品:" + bc.item_code + ") 需要手写改单，请联系 " + signature + "。";
        mm.Subject = Resources.bc.needtechsub.Replace("$batch", bc.batch_no);
        try
        {
            sc.SendCompleted += sc_SendCompleted;
            sc.SendAsync(mm, bc.r_id);
        }
        catch {
            throw;
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void TakeBatch(int r_id, string comment, bool ifbymanual, string signature)
    {
        if (islab)
        {
            var q = bcdc.batch_confirmation.Single(i => i.r_id == r_id);
            if (ifbymanual)
            {
                NeedTechSendMail(q, currentuser.Loginid,signature);
            }
            q.r_status = 2;
            q.current_officer = login;
            q.lab_comment = comment;
            if (q.r_status == 1 || q.r_status == 6)
            {
                q.check_times++;
            }
            var bca = new batch_confirmation_action
            {
                r_id = q.r_id,
                batch_no = q.batch_no,
                action = "Hold",
                comment = "Checking",
                @operator = login,
                login_time = DateTime.Now
            };
            bcdc.batch_confirmation_action.InsertOnSubmit(bca);
            bcdc.SubmitChanges();
        }
        else
        {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void ApproveBatch(int r_id,string adj_lab,string comment, string comment1,string comment2) {
        if (islab)
        {

            var q = bcdc.batch_confirmation.Single(i => i.r_id == r_id);
            if (q.r_status == 3)
            {
                throw new Exception("This batch has been approved.");
            }
            else if (q.r_status == 4) {
                throw new Exception("This batch has been rejected.");
            }
            else
            {
                q.r_status = 3;
                q.adj_lab = adj_lab;
                q.lab_comment = comment;
                q.special_comment_1 = comment1;
                q.special_comment_2 = comment2;
                var bca = new batch_confirmation_action
                {
                    r_id = q.r_id,
                    batch_no = q.batch_no,
                    action = "Approve",
                    comment = q.lab_comment,
                    @operator = login,
                    login_time = DateTime.Now
                };

                if (q.r_status != 2)
                {
                    q.check_times++;
                }
                bcdc.batch_confirmation_action.InsertOnSubmit(bca);
                bcdc.SubmitChanges();
                ResponsMail(q.r_id);
            }
        }
        else
        {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void RejectBatch(int r_id, string comment)
    {
        if (islab)
        {
            var q = bcdc.batch_confirmation.Single(i => i.r_id == r_id);
            if (q.r_status == 3)
            {
                throw new Exception("This batch has been approved.");
            }
            else if (q.r_status == 4)
            {
                throw new Exception("This batch has been rejected.");
            }
            else
            {
                q.r_status = 4;
                q.lab_comment = comment;
                var bca = new batch_confirmation_action
                {
                    r_id = q.r_id,
                    batch_no = q.batch_no,
                    action = "Reject",
                    comment = q.lab_comment,
                    @operator = login,
                    login_time = DateTime.Now
                };
                if (q.r_status != 2)
                {
                    q.check_times++;
                }
                bcdc.batch_confirmation_action.InsertOnSubmit(bca);
                bcdc.SubmitChanges();
                ResponsMail(q.r_id);
            }
        }
        else
        {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void BatchComplete(bcmodelop bmo) {
        if (isop)
        {
            var q = bcdc.batch_confirmation.Single(i => i.r_id == bmo.r_id);
            q.r_status = 5;
            var bca = new batch_confirmation_action
            {
                r_id = q.r_id,
                batch_no = bmo.batch_no,
                action = "Close",
                @operator = login,
                login_time = DateTime.Now
            };
            bcdc.batch_confirmation_action.InsertOnSubmit(bca);
            bcdc.SubmitChanges();
        }
        else
        {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void CompleteAll() {
        if (isop)
        {
            var q = from i in bcdc.batch_confirmation
                    where i.add_by == login && i.r_status == 3
                    select new bcmodelop
                    {
                        r_id = i.r_id,
                        batch_no = i.batch_no,
                    };
            foreach (var qi in q) {
                BatchComplete(qi);
            }
        }
        else {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void ReOpen(int r_id,string comment) {
        if (isop)
        {
            var q = bcdc.batch_confirmation.Single(i => i.r_id == r_id);
            q.r_status = 6;
            string updatecomment = "Old comment:" + q.planner_comment;
            q.planner_comment = comment;
            var bca = new batch_confirmation_action
            {
                r_id = q.r_id,
                batch_no = q.batch_no,
                action = "Reopen",
                comment = "comment:\""+updatecomment+"\"->\""+comment+"\";\n",
                @operator = login,
                login_time = DateTime.Now
            };
            bcdc.batch_confirmation_action.InsertOnSubmit(bca);
            bcdc.SubmitChanges();
        }
        else
        {
            throw new Exception("No enough permission");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat=ResponseFormat.Json)]
    public object[] QueryExcel(string filename){
        //try
        //{
            string folderpath = Server.MapPath("tempexcel\\");
            string filepath = Path.Combine(folderpath, currentuser.Loginid + filename);
            if (File.Exists(filepath))
            {
                var ei = new ExcelImport(filepath);
                ei.MaxRecordQty = 200;
                if (!ei.ExcelToTable())
                {
                    throw new Exception(ei.Message);
                }
                else
                {
                    List<bcmodelimport> bmil = new List<bcmodelimport>();
                    foreach (DataRow eir in ei.ExcelData.Rows)
                    {
                        bmil.Add(new bcmodelimport
                        {
                            batch_no = eir["batch"].ToString(),
                            item_code = eir["item"].ToString(),
                            qty = eir["qty"]!=null?Convert.ToDecimal(eir["qty"]):0,
                            shipping_date = eir["shipping_date"].ToString() != "" ? (DateTime?)eir["shipping_date"] : null,
                            recipe_ver = eir["recipe"].ToString() != "" ? (int?)Convert.ToInt16(eir["recipe"]) :null,
                            history = eir["history"].ToString() != "" ? (int?)Convert.ToInt16(eir["history"]) : null,
                            planner_comment = eir["OP_note"].ToString(),
                            assign_lab = eir["Lab"].ToString(),
                            ul_status = eir["状态"].ToString()
                        });
                    }
                    return bmil.ToArray();
                }
            }
            else
            {
                throw new Exception("文件不存在");
            }
        //}
        //catch {
        //    throw;
        //}
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object[] importToSql(IEnumerable<bcmodelop> data) {
        if (data.Count() > 0)
        {
            var now = DateTime.Now;
            var batchno = data.Select(s => s.batch_no);
            var q = from o in bcdc.batch_confirmation
                    where batchno.Contains(o.batch_no)
                    select new { o.batch_no };
            List<bcmodelimport> re = new List<bcmodelimport>();
            List<string> sbn = new List<string>();
            foreach (bcmodelop i in data)
            {
                if (data.Count(c => c.batch_no == i.batch_no) > 1) {
                    throw new Exception("提交的数据含有重复批号" + i.batch_no);
                }else{
                    if (q.Where(c => c.batch_no == i.batch_no).Count() == 0)
                    {
                        var bc = new batch_confirmation
                        {
                            batch_no = i.batch_no,
                            item_code = i.item_code,
                            qty = (decimal)i.qty,
                            shipping_date = i.shipping_date,
                            recipe_ver = i.recipe_ver,
                            history = i.history,
                            planner_comment = i.planner_comment,
                            assign_lab = i.assign_lab,
                            add_by = login,
                            add_date = now,
                            r_status = 1,
                            mail_times = 0
                        };
                        bcdc.batch_confirmation.InsertOnSubmit(bc);
                        sbn.Add(i.batch_no);
                       // SendMail(i.batch_no);
                    }
                    else
                    {
                        re.Add(new bcmodelimport
                        {
                            batch_no = i.batch_no,
                            item_code = i.item_code,
                            qty = (decimal)i.qty,
                            shipping_date = i.shipping_date,
                            recipe_ver = i.recipe_ver,
                            history = i.history,
                            planner_comment = i.planner_comment,
                            assign_lab = i.assign_lab,
                            ul_status = "批号重复"
                        });
                    }
                }
            }
            bcdc.SubmitChanges();
            foreach (string i in sbn) {
                SendMail(i);
            }
            return re.ToArray();
        }
        else {
            throw new Exception("提交的数据为空");
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string[] GetAdjList(string lab) {
        LabDataContext ldc = new LabDataContext();
        var q = (from i in ldc.Lab
                where i.lab_name == lab
                select new { i.adj_lab_list }).Single();
        return q.adj_lab_list.Split(',');
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string GetLastComment(string item) {
        if (islab)
        {
            var q = from i in bcdc.batch_confirmation
                     where i.item_code == item&&i.lab_comment!=null&i.lab_comment!=""
                     orderby i.add_date descending
                     select new { i.lab_comment };
            try
            {
                return q.First().lab_comment;
            }catch{
                return "";
            }                  
        }
        else {
            throw new Exception("No enough permission");
        }
    }
/// <summary>
    /// 获取指定批次ID的历史操作记录
    /// </summary>
    /// <param name="r_id"></param>
    /// <returns></returns>
    [WebMethod]
    [ScriptMethod(ResponseFormat=ResponseFormat.Json)]
    public object[] GetBatchHistory(int r_id) { 
        var itman = new query();
        itman.Credentials = System.Net.CredentialCache.DefaultCredentials;
        var q=from i in bcdc.batch_confirmation_action
              where i.r_id==r_id
              orderby i.login_time descending
              select new {i.a_id,i.action,people=itman.L2C(i.@operator),i.comment,i.login_time};
        if (q.Count() > 0)
        {
            return q.ToArray();
        }
        else
        {
            return new object[0];
        }
    }
}
