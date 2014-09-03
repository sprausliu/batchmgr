using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
///bcmodel 的摘要说明
/// </summary>
public class bcmodel
{
	public bcmodel()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}
}
public class bcmodelimport {
    public int? r_id;
    public string batch_no;
    public string item_code;
    public decimal? qty;
    public DateTime? shipping_date;
    public int? recipe_ver;
    public int? history;
    public string planner_comment;
    public string assign_lab;
    public string ul_status;
}
public class bcmodelop {
    public int? r_id;
    public string batch_no;
    public string item_code;
    public decimal? qty;
    public DateTime? shipping_date;
    public int? recipe_ver;
    public int? history;
    public string planner_comment;
    public string assign_lab;
    //public string lab_comment;
    //public int r_status;
    //public DateTime? add_date;
    //public string add_by;
    //public string modify_by;
   // public DateTime? modify_date;
    //public int check_time;
    //public string current_officer;
}
public class bcmodellab {
    public int r_id;
    public string batch_no;
    //public string item_code;
    //public decimal qty;
    //public DateTime? shipping_date;
    //public int recipe_ver;
    //public int history;
    public string planner_comment;
    //public string assign_lab;
    public string lab_comment;
    public string adj_lab;
    //public int r_status;
    //public DateTime? add_date;
    //public string add_by;
    //public string modify_by;
    //public DateTime? modify_date;
    //public int mail_time;
    //public string cancel_comment;
    //public string cancel_by;
}