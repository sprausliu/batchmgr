using System.Collections.Generic;
/// <summary>
///Cell 的摘要说明
/// </summary>
public class Cell
{
    private string cidcolumnname = "cell_id";

    private string cellnamecolumnname = "cell_name";

    private string cellwiplimitcolumnname = "cell_wip_limit";
    private string cellwiptolerancecolumnname = "cell_wip_tolerance";
	public Cell()
	{
	}
    private int _cid;
    private string _cellname;
    private int _cellwiplimit;
    public string cellname
    {
        get { return _cellname; }
        set { _cellname = value; }
    }
    public int cellwiplimit
    {
        get { return _cellwiplimit; }
        set { _cellwiplimit = value; }
    }
    public int cellid
    {
        get { return _cid; }
        set { _cid = value; }
    }
    public int cellwiptolerance;
    public Dictionary<string, object> GetKeyDict() {
        Dictionary<string,object> key= new Dictionary<string, object>();
        key.Add("cell_id", _cid);
        return key;
    }
    public Dictionary<string, object> GetValuesDict() {
        Dictionary<string, object> values = new Dictionary<string, object>();
       // values.Add(cellnamecolumnname, _cellname);
        values.Add(cellwiplimitcolumnname, _cellwiplimit);
        values.Add("cell_CT", cellct);
        return values;
    }
    public float cellct;
}