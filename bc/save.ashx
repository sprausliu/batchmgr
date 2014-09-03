<%@ WebHandler Language="C#" Class="save" %>

using System;
using System.IO;
using System.Web;

public class save : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        context.Response.Charset = "utf-8";

        HttpPostedFile file = context.Request.Files["files"];
        if (Path.GetExtension(file.FileName).ToLower().Equals(".xls") || Path.GetExtension(file.FileName).ToLower().Equals(".xlsx"))
        {
            string uploadPath = HttpContext.Current.Server.MapPath(@context.Request["folder"]) + "\\tempexcel\\";
            if (file != null)
            {

                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }
                file.SaveAs(uploadPath + currentuser.Loginid + Path.GetFileName(file.FileName));
            }
        }
        else {
            throw new Exception("wrong file format!");
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}