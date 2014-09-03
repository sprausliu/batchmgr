using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
///BatchUrgent 的摘要说明
/// </summary>
public class BatchUrgent
{
	public BatchUrgent()
	{
	}
    private int _BatchId;

    public int BatchId
    {
        get { return _BatchId; }
        set { _BatchId = value; }
    }
    private string BatchIdName = "batch_id";    
    private string _batchno;
    public string Batchno
    {
        get { return _batchno; }
        set { _batchno = value; }
    }
    private string _itemcode;
    public string Itemcode
    {
        get { return _itemcode; }
        set { _itemcode = value; }
    }
    private bool _UrgentMark;
    public bool UrgentMark
    {
        get { return _UrgentMark; }
        set { _UrgentMark = value; }
    }
    private string UrgentMarkName = "batch_if_urgent";
    private string _InvType;

    public string InvType
    {
        get { return _InvType; }
        set { _InvType = value; }
    }
    private string InvTypeName = "production_inv_type";
    private string _Cell;

    public string Cell
    {
        get { return _Cell; }
        set { _Cell = value; }
    }
    private string CellColumnName = "cell";
    private string _Operator;

    public string Operator
    {
        get { return _Operator; }
        set { _Operator = value; }
    }
    private string OperatorName = "operator";
    private DateTime? _AlertDate=null;

    public DateTime? AlertDate
    {
        get { return _AlertDate; }
        set { _AlertDate = value; }
    }
    private string AlertDateName = "alert_date";
    private DateTime? _AbortDate=null;

    public DateTime? AbortDate
    {
        get { return _AbortDate; }
        set { _AbortDate = value; }
    }
    private string AbortDataName = "abort_date";
    public Dictionary<string, object> GetAlertKey() {
        Dictionary<string, object> k = new Dictionary<string, object>();
        k.Add(BatchIdName, _BatchId);
        return k;
    }
    public Dictionary<string, object> SetAlertDict() {
        Dictionary<string, object> b = new Dictionary<string, object>();
        b.Add(UrgentMarkName, _UrgentMark);        
        b.Add(OperatorName, _Operator);
        b.Add(AlertDateName, _AlertDate);
        if (UrgentDesc != null)
        {
            b.Add("urgent_description", UrgentDesc);
        }
        return b;
    }
    public Dictionary<string, object> CancelAlertDict() {
        Dictionary<string, object> b = new Dictionary<string, object>();
        b.Add(UrgentMarkName, _UrgentMark);
        b.Add(OperatorName, _Operator);
        b.Add(AbortDataName,_AbortDate);
        return b;
    }
    public string UrgentDesc;
}