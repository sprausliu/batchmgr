using System;
using System.Collections;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Linq;
using System.Web.Script.Services;

/// <summary>
/// Summary description for ReportData
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class ReportData : System.Web.Services.WebService {

    public ReportData () {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat=ResponseFormat.Json)]
    public object[] Over15kgLess2minCount() {
        BVReportDataContext bvr = new BVReportDataContext();
        var q = from i in bvr.BVReportDataWithWeeks
                group i by new {i.weekdate,i.CELL} into j
                select new {j.Key.CELL,j.Key.weekdate,num=j.Count()};
        return q.ToArray();
                
    }
    private DateTime GetLastDayOfLastWeek(DateTime? d) {
        return d.Value.AddDays(-7);
    }
}

