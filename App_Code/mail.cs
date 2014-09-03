using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web;

/// <summary>
/// mail 的摘要说明
/// </summary>
public class mail
{
    private string subject;

    public string Subject
    {
        get { return subject; }
        set { 
            subject = value;
            mm.Subject = value;
        }
    }
    private string body;

    public string Body
    {
        get { return body; }
        set
        {
            body = value;
            mm.Body = value;
        }
    }
    public List<string> recipient;
    private SmtpClient sc;
    private MailMessage mm;
	public mail()
	{
		//
		// TODO: 在此处添加构造函数逻辑
		//
        sc = BuildSMTP();
        mm = MMBase();        
	}
    public static MailMessage MMBase()
    {
        MailMessage mm = new MailMessage();
        mm.Priority = MailPriority.Normal;
        mm.From = new MailAddress(ConfigurationManager.AppSettings["mailfrom"]);
        mm.SubjectEncoding = Encoding.GetEncoding(936);
        mm.BodyEncoding = mm.SubjectEncoding;
        mm.IsBodyHtml = true;
        return mm;
    }
    public static SmtpClient BuildSMTP()
    {
        SmtpClient sc = new SmtpClient(ConfigurationManager.AppSettings["smtpserver"]);
        sc.UseDefaultCredentials = false;
        sc.EnableSsl = false;
        sc.Credentials = new NetworkCredential(ConfigurationManager.AppSettings["LoginId"], ConfigurationManager.AppSettings["password"], ConfigurationManager.AppSettings["maildomain"]);
        sc.DeliveryMethod = SmtpDeliveryMethod.Network;
        return sc;
    }
    public bool send() {
        try
        {
            if (mm.To.Count()==0)
            {
                foreach (string to in recipient) {
                    mm.To.Add(to);
                }
            }
            sc.Send(mm);
            return true;
        }
        catch {
            return false;
        }
    }
}