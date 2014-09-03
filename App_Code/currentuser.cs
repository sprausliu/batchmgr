using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
///currentuser 的摘要说明
/// </summary>
public class currentuser
{
	public currentuser()
	{
	}
    private static readonly string _loginid;

    public static string Loginid
    {
        get {
            string oname = System.Web.HttpContext.Current.User.Identity.Name;
            return oname.Substring(oname.IndexOf("\\")+1);
        }
    }
    public static string Chinesename {
        get
        {
            string ename = Loginid;
            var itman = new ITMAN.query();
            itman.Credentials = System.Net.CredentialCache.DefaultCredentials;
            return itman.L2C(ename);
        }
    }
    private static readonly string[] _bclab;
    public static string[] Bclab
    {
        get {
            roleDataContext rdc = new roleDataContext();
            var q = from i in rdc.mgr_user_role
                    where i.userid == Loginid&&i.role=="batchconfirm"
                    select new { i.dept };
            List<string> a = new List<string>();
            foreach (var qi in q) {
                a.Add(qi.dept);
            }
            return a.ToArray();
        }
    }
    private static readonly string _bcorgn;

    public static string Bcorgn
    {
        get {
            roleDataContext rdc = new roleDataContext();
            try
            {
                var q = (from i in rdc.mgr_user_role
                         where i.userid == Loginid && i.role == "batchconfirm"
                         select new { i.location }).First();
                return q.location;
            }
            catch {
                return "";
            }
        }
    }


    public static bool CheckRole(string role, string location)
    {
        roleDataContext rdc = new roleDataContext();
        var q = (from i in rdc.mgr_user_role
                 where i.userid == Loginid && i.role == role && i.location == location
                 select i).Count();
        return q > 0;
    }
    private static string _cell;

    public static string Cell
    {
        get {
            using (roleDataContext rdc = new roleDataContext()) {
                var q = (from i in rdc.mgr_user_role
                         where i.userid == Loginid && i.role == "pkg"
                         select i).First();
                return q.dept;
            }
        }
    }
}