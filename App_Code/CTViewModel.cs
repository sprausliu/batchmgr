using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
///CTViewModel 的摘要说明
/// </summary>
public class CTViewModel
{
    public int ItemId;
    public string ItemName;
    public string Cell;
    public string ItemInvType;
    public string Creator;
    public DateTime? Created;
    public string ModifyBy;
    public DateTime? Modified;
    public Int16 Hours;
	public CTViewModel()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}
}
public class RCTViewModel
{
    public string RCTUID;
    public int ItemId;
    public int LowLimit;
    public int UpLimit;
    public int Hours;
    public string Creator;
    public string ModifyBy;
    public DateTime? Created;
    public DateTime? Modified;
    public RCTViewModel() { }
}
public class QualityAlert
{
    public int batch_id;
    public string BatchNo;
    public string ItemName;
    public string Cell;
    public bool QualityIssue;
    public DateTime? QITime;
    public string Operator;
    public string QualityResponsibleBy;
    public string QualityDesc;
    public QualityAlert() { }
    public Dictionary<string, object> GetQualityKey() {
        Dictionary<string, object> k = new Dictionary<string, object>();
        k.Add("batch_id", batch_id);
        return k;
    }
    public Dictionary<string, object> SetQualityDict() {
        Dictionary<string, object> d = new Dictionary<string, object>();
        d.Add("batch_if_quality", QualityIssue);
        d.Add("quality_operator", Operator);
        d.Add("quality_date", QITime);
        if (QualityResponsibleBy!=null)
        {
            d.Add("quality_responsibleby", QualityResponsibleBy);
        }
        if (QualityDesc != null)
        {
            d.Add("quality_description", QualityDesc);
        }
        return d;
    }
}
public class BellAlert {
    public decimal batch_id;
    public string batch_no;
    public string item_code;
    public bool bell_if;
    public string item_inv_type;
    public string cell;    
    public string bell_operator;
    public DateTime? bell_date;
    //public string bell_description;
}