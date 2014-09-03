<%@ WebHandler Language="C#" Class="remove" %>

using System;
using System.IO;
using System.Web;

public class remove : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        context.Response.Charset = "utf-8";

        string filename = context.Request.Form["fileNames"];
        if (filename!=null&&filename!="")
        {
            string uploadPath = HttpContext.Current.Server.MapPath(@context.Request["folder"]) + "\\tempexcel\\";
            string strfilepath = Path.Combine(uploadPath,currentuser.Loginid+filename);
            if (File.Exists(strfilepath)) {
                File.Delete(strfilepath);
            }
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}