using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Reflection;

/// <summary>
/// package 的摘要说明
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消注释以下行。 
[System.Web.Script.Services.ScriptService]
public class package : System.Web.Services.WebService {

    public package () {
        NewUser nu = new NewUser("pkg");
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat=ResponseFormat.Json)]
    public object[] GetUsingRC(int take) {
        packageDataContext pkdc = new packageDataContext();
        pkdc.DeferredLoadingEnabled = false;
        var q = (from i in pkdc.package_using
                 where i.u_status==1||i.u_status==2
                 select i).OrderByDescending(o => o.u_added).Take(take).ToArray();
        return q;
        
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object[] GetPkgCategory() {
        packageDataContext pkdc = new packageDataContext();
        pkdc.DeferredLoadingEnabled = false;
        return (from i in pkdc.package_category
                select i).ToArray();
        
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object[] GetCellInfo() {
        using (packageDataContext pkdc = new packageDataContext()) {
            return (from i in pkdc.cell_info
                    select new { value=i.cell_id,text=i.cell_name}).ToArray();
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void AddNewRC(package_using pu) {
        using (packageDataContext pkdc = new packageDataContext()) {
            NewUser nu = new NewUser("pkg");
            pu.u_batch = pu.u_batch.ToUpper();
            pu.u_added = DateTime.Now;
            pu.u_user = nu.LoginID;
            pu.u_status = 1;
            pu.u_mailtimes = 0;
            pu.u_cell = nu.CellId;
            pkdc.package_using.InsertOnSubmit(pu);
            pkdc.SubmitChanges();
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void DelRC(IEnumerable<package_using> pus)
    {
        using (packageDataContext pkdc = new packageDataContext()) {
            var ids=from a in pus
                    select a.u_id;
            var q = from i in pkdc.package_using
                    where ids.Contains(i.u_id)                     
                     select i;
            foreach (package_using pu in q) {
                pu.u_status = -1;
            }
            pkdc.SubmitChanges();
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void UpdateRC(IEnumerable<package_using> pus)
    {
        using (packageDataContext pkdc = new packageDataContext())
        {
            foreach (package_using pu in pus)
            {
                var q = (from i in pkdc.package_using
                         where i.u_id == pu.u_id
                         select i).Single();
                q.u_reason = pu.u_reason;
                q.u_pkg_category = pu.u_pkg_category;
                q.u_batch = pu.u_batch;
                q.u_num = pu.u_num;
                q.u_modified = DateTime.Now;                
            }
            pkdc.SubmitChanges();
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public void Blank() { 
    
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object[] pkglistByBuilding(string building) {
        packageDataContext pkdc = new packageDataContext();
        var q = from i in pkdc.package_using
                where i.u_status == 1 && i.cell_info.cell_pkg_building == building
                select new { i.u_id, i.u_batch, i.cell_info.cell_name, i.u_pkg_category, i.u_num };
        return q.OrderBy(o => o.u_id).ToArray();        
    }
}
