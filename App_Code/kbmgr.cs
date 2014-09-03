using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;

/// <summary>
/// Summary description for kbmgr
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class kbmgr : System.Web.Services.WebService {

    public kbmgr () {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    public string HelloWorld() {
        return "Hello World";
    }
    [WebMethod]
    public void Update_wip_limit(IEnumerable<Cell> cells)
    {
        foreach (Cell c in cells)
        {
            DBOP db = new DBOP();
            db.update(c.GetValuesDict(), "cell_info", c.GetKeyDict());
        }
    }

    [WebMethod]
    public void Update_Alert(IEnumerable<BatchUrgent> bus)
    {
        foreach (BatchUrgent bu in bus)
        {
            DBOP db = new DBOP();
            UserIdentity user = new UserIdentity();
            bu.Operator = user.Username;
            if (bu.UrgentMark)
            {
                bu.AlertDate = DateTime.Now;
                db.update(bu.SetAlertDict(), "batch_urgent_alert", bu.GetAlertKey());
            }
            else
            {
                bu.AbortDate = DateTime.Now;
                bu.UrgentDesc = "";
                db.update(bu.CancelAlertDict(), "batch_urgent_alert", bu.GetAlertKey());
            }
        }
    }
    [WebMethod]
    public void Update_Quality(IEnumerable<QualityAlert> qas)
    {
        foreach (QualityAlert qa in qas)
        {
            DBOP db = new DBOP();
            UserIdentity user = new UserIdentity();
            qa.Operator = user.Username;
            if (qa.QualityIssue)
            {
                qa.QITime = DateTime.Now;
                db.update(qa.SetQualityDict(), "batch_urgent_alert", qa.GetQualityKey());
            }
            else
            {
                qa.QITime = null;
                qa.Operator = "";
                db.update(qa.SetQualityDict(), "batch_urgent_alert", qa.GetQualityKey());
            }
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public List<QualityAlert> Get_QualityList()
    {
        List<QualityAlert> ql = new List<QualityAlert>();
        DBOP db = new DBOP();
        string sql = @"SELECT a.batch_id,a.batch_if_quality,a.quality_operator,a.quality_responsibleby,a.quality_description,a.quality_date,b.BATCH_NO,b.item_code,i.cell,i.item_inv_type
                      FROM [batch_urgent_alert] a join wip_batch b
                      on a.batch_id=b.BATCH_ID  join item i
                      on b.item_id=i.item_id where b.plant_code='WU'";
        db.GetTable(sql);
        foreach (DataRow dr in db._dt.Rows)
        {
            QualityAlert qa = new QualityAlert();
            qa.batch_id = int.Parse(dr["batch_id"].ToString());
            qa.QualityIssue = bool.Parse(dr["batch_if_quality"].ToString());
            if (dr["quality_date"].ToString() != "")
            {
                qa.QITime = DateTime.Parse(dr["quality_date"].ToString());
            }
            qa.BatchNo = dr["batch_no"].ToString();
            qa.Cell = dr["cell"].ToString();
            qa.ItemName = dr["item_code"].ToString();
            qa.Operator = dr["quality_operator"].ToString();
            qa.QualityResponsibleBy = dr["quality_responsibleby"].ToString();
            qa.QualityDesc = dr["quality_description"].ToString();
            ql.Add(qa);
        }
        db.Close();
        return ql;
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public List<string> Get_cells()
    {
        List<string> cl = new List<string>();
        DBOP db = new DBOP();
        string sql = "select distinct cell from wip_batch where plant_code='WU'";
        db.GetTable(sql);
        foreach (DataRow dr in db._dt.Rows)
        {
            cl.Add(dr[0].ToString());
        }
        return cl;
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public List<Cell> Get_WIP_Limit()
    {
        List<Cell> cl = new List<Cell>();
        DBOP db = new DBOP();
        string sql = "select cell_id,cell_name,isnull(cell_wip_limit,0) cell_wip_limit,cell_CT from cell_info where plant_code='WU'";
        db.GetTable(sql);
        foreach (DataRow dr in db._dt.Rows)
        {
            Cell c = new Cell();
            c.cellid = int.Parse(dr["cell_id"].ToString());
            c.cellname = dr["cell_name"].ToString();
            c.cellwiplimit = int.Parse(dr["cell_wip_limit"].ToString());
            c.cellct = float.Parse(dr["cell_CT"].ToString());
            cl.Add(c);
        }
        return cl;
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public List<BatchUrgent> Get_Batch_Urgent()
    {
        List<BatchUrgent> bul = new List<BatchUrgent>();
        DBOP db = new DBOP();
        string sql = @"SELECT a.*,b.BATCH_NO,b.item_code,b.cell,i.item_inv_type
  FROM [batch_urgent_alert] a join wip_batch b
  on a.batch_id=b.BATCH_ID  join item i
  on b.item_id=i.item_id where b.plant_code='WU'";
        db.GetTable(sql);
        foreach (DataRow dr in db._dt.Rows)
        {
            BatchUrgent bu = new BatchUrgent();
            bu.BatchId = int.Parse(dr["batch_id"].ToString());
            bu.Batchno = dr["batch_no"].ToString();
            bu.Itemcode = dr["item_code"].ToString();
            bu.UrgentMark = bool.Parse(dr["batch_if_urgent"].ToString());
            bu.InvType = dr["item_inv_type"].ToString();
            bu.Cell = dr["cell"].ToString();
            bu.Operator = dr["operator"].ToString();
            bu.UrgentDesc = dr["urgent_description"].ToString();
            if (dr["alert_date"].ToString() != "")
            {
                bu.AlertDate = DateTime.Parse(dr["alert_date"].ToString());
            }
            if (dr["abort_date"].ToString() != "")
            {
                bu.AbortDate = DateTime.Parse(dr["abort_date"].ToString());
            }
            bul.Add(bu);
        }
        return bul;
    }
    public string tojson(object obj)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        return serializer.Serialize(obj);
    }
}

