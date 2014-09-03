using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// NewUser 的摘要说明
/// </summary>
public class NewUser
{
    public NewUser()
    {
        _loginID = GetLoginID();
    }
    public NewUser(string app) {
        _loginID = GetLoginID();
        switch (app) { 
            case "pkg":
                using (packageDataContext pkdc = new packageDataContext()) {
                    var q = (from i in pkdc.package_user
                             where i.p_user == _loginID
                             select new { i.cell_info.cell_id, i.cell_info.cell_name }).Single();
                    _cellId = q.cell_id;
                    _cellName = q.cell_name;
                    break;
                }
        }
    }
    private string _loginID;
    public string LoginID
    {
        get { return _loginID; }
    }
    private int _cellId;

    public int CellId
    {
        get { return _cellId; }
    }
    private string _cellName;

    public string CellName
    {
        get { return _cellName; }
    }
    private string GetLoginID() {
        string oname = System.Web.HttpContext.Current.User.Identity.Name;
        return oname.Substring(oname.IndexOf("\\") + 1);
    }
}