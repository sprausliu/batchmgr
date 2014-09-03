using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;

/// <summary>
///DBOP 的摘要说明
/// </summary>
public class DBOP
{
    #region 数据库操作
    public SqlConnection _con;
    public DataRow _dr;
    public DataTable _dt;
    public SqlDataAdapter _Ada;
    public DataSet _ds;
    public DataView _dv;
    public string conn = ConfigurationManager.ConnectionStrings["batchConnectionString"].ToString();
    private DbConnection _dbcon;
    private static readonly string providerName = "System.Data.SqlClient";
	public DBOP()    
    {
        //
        // TODO: 在此处添加构造函数逻辑
        //
    }
    /// <summary>
    /// 打开SQL连接
    /// </summary>
    private void open()
    {
        if (_con == null || _con.State == System.Data.ConnectionState.Closed)
        {
            _con = new SqlConnection(conn);
            _con.Open();
        }
    }
    private void buildDBcon() {
        if (_dbcon == null) {
            _dbcon.ConnectionString = conn;
        }
    }
    private  DbConnection GetConnection() {
        DbProviderFactory _factory = DbProviderFactories.GetFactory(providerName);
        DbConnection connection = _factory.CreateConnection();
        connection.ConnectionString = conn;
        return connection;
    }
    private DbCommand GetCommand(string commandtext, CommandType ct, DbConnection dbcon) {
        DbCommand command = dbcon.CreateCommand();
        command.CommandText = commandtext;
        command.CommandType = ct;
        return command;
    }
    private DbParameter GetParameter(string key, object value,DbCommand dbcmd) {
        DbParameter dbp = dbcmd.CreateParameter();
        dbp.ParameterName = key;
        dbp.Value = value;
        return dbp;
    }
    public void Close()
    {
        if (_con != null)
        {
            _con.Close();
        }
    }
    public DataRow GetRow(string str_sql)
    {
        

        _dr = GetTable(str_sql).Rows[0];
        return _dr;

    }
    public DataTable GetTable(string str_sql)
    {
        try
        {
            _dt = GetDs(str_sql).Tables[0];
            return _dt;
        }
        catch
        {
            throw;
        }
    }
    public string DtToJson(DataTable dt) {
        return dt.ToJson();
    }
    /// <summary>
    /// 根据SQL语句得到Dataset
    /// </summary>
    public DataSet GetDs(string str_sql)
    {
        open();
        _Ada = new SqlDataAdapter(str_sql, _con);
        _ds = new DataSet();
        try
        {
            _Ada.Fill(_ds);
            _con.Close();
            return _ds;

        }
        catch
        {
            throw;
        }

    }
    public int ExecuteNonquery(string sql, Dictionary<string, object> p) {
        int resault = 0;
        using (DbConnection connection = GetConnection()) {
            DbCommand command = GetCommand(sql, CommandType.Text, connection);
            foreach (KeyValuePair<string, object> pu in p) { 
                command.Parameters.Add(GetParameter(pu.Key,pu.Value,command));
            }
            connection.Open();
            resault=command.ExecuteNonQuery();
            command.Parameters.Clear();
            connection.Close();
            connection.Dispose();
            return resault;
        }
    }
    
    /// <summary>
    /// 使用参数化查询获取DataTable
    /// </summary>
    /// <param name="str_sql">sql命令</param>
    /// <param name="type">命令类型text或者StoredProcedure</param>
    /// <param name="parm">参数</param>
    /// <returns></returns>
    public DataTable GetDt(string str_sql,CommandType type, Dictionary<string, object> parm) {
        try
        {
            using (DbConnection connection = GetConnection()) {
                DbProviderFactory _factory=DbProviderFactories.GetFactory(providerName);
                DbCommand command = GetCommand(str_sql, type, connection);
                foreach (KeyValuePair<string, object> p in parm) { 
                    command.Parameters.Add(GetParameter(p.Key,p.Value,command));
                }
                connection.Open();
                DbDataAdapter dda=_factory.CreateDataAdapter();
                dda.SelectCommand=command;
                DataTable dt = new DataTable();
                dda.Fill(dt);
                return dt;
            }
        }
        catch {
            throw;
        }
    }
    /// <summary>
    /// 使用参数化查询获取DataTable，不指定类型默认使用Text
    /// </summary>
    /// <param name="str_sql"></param>
    /// <param name="parm"></param>
    /// <returns></returns>
    public DataTable GetDt(string str_sql, Dictionary<string, object> parm) {
        _dt= GetDt(str_sql, CommandType.Text, parm);
        return _dt;
    }
    public DataRow GetRow(string str_sql, CommandType type, Dictionary<string, object> parm) {
        _dt = GetDt(str_sql, type, parm);
        _dr = _dt.Rows[0];
        return _dr;
    }
    public DataRow GetRow(string str_sql, Dictionary<string, object> parm) {
        _dt=GetDt(str_sql, parm);
        _dr = _dt.Rows[0];
        return _dr;
    }
    public int disquery(string sql)
    {
        _con = new SqlConnection(conn);
        _con.Open();
        SqlCommand cmd = new SqlCommand(sql, _con);
        int i;
        i=cmd.ExecuteNonQuery();
        _con.Close();
        return i;
    }
    public void noquery(string sql)
    {
        _con = new SqlConnection(conn);
        _con.Open();

        try
        {
            SqlCommand cmd = new SqlCommand(sql, _con);
            cmd.ExecuteNonQuery();
        }
        catch(Exception e)
        {
            throw e;
        }
    }
    public void insert(string[] field, string[] value,string Table)
    {
        string fieldstr = "";
        for (int i = 0; i < field.Length; i++)
        {
            fieldstr += field[i] + ",";
        }
        fieldstr = fieldstr.Remove(fieldstr.Length - 1);
        string valuestr = "";
        for (int i = 0; i < value.Length; i++)
        {
            valuestr +="'"+ value[i] + "',";
        }
        valuestr = valuestr.Remove(valuestr.Length - 1);
        string sql = "INSERT INTO " + Table + " (" + fieldstr + ") VALUES (" + valuestr + ")";
        noquery(sql);
        return;
    }
    public void insert(Dictionary<string, string> cvs,string table){

        if (cvs.Count > 0)
        {        
            string columns = "";
            string values = "";
            foreach (KeyValuePair<string, string> cv in cvs)
            {
                columns += cv.Key + ",";
                if (cv.Value == "NULL"||cv.Value=="")
                {
                    values += "NULL,";
                }
                else
                {
                    values += "N'" + cv.Value + "',";
                }
            }
            columns = columns.Remove(columns.Length - 1);
            values = values.Remove(values.Length - 1);
            string sql = "insert into " + table + " (" + columns + ") values (" + values + ")";
            DBOP db = new DBOP();
            try
            {
                db.noquery(sql);
            }
            catch (Exception e)
            {
                throw e;
            }
        }

    }
    public void insert(Dictionary<string, object> cvs, string table)
    {

        if (cvs.Count > 0)
        {
            string columns = "";
            string values = "";
            foreach (KeyValuePair<string, object> cv in cvs)
            {
                columns += cv.Key + ",";
                if (cv.Value.ToString() == "NULL"||cv.Value.ToString()=="")
                {
                    values += "NULL,";
                }
                else
                {
                    values += "N'" + cv.Value.ToString() + "',";
                }
            }
            columns = columns.Remove(columns.Length - 1);
            values = values.Remove(values.Length - 1);
            string sql = "insert into " + table + " (" + columns + ") values (" + values + ")";
            DBOP db = new DBOP();
            try
            {
                db.noquery(sql);
            }
            catch (Exception e)
            {
                throw e;
            }
        }

    }
    public void update(Dictionary<string, object> cvs, string table, Dictionary<string,object> key) {
        string sql = "update " + table;
        if (cvs.Count > 0) {
            string cvstr = "";
            foreach (KeyValuePair<string, object> cv in cvs)
            {
                if (cv.Value==null||cv.Value.ToString() == "NULL" || cv.Value.ToString() == "")
                {
                    cvstr += cv.Key + "=NULL,";
                }
                else
                {
                    cvstr+=cv.Key + "=N'" + cv.Value.ToString() + "',";
                }
            }
            cvstr = cvstr.Remove(cvstr.Length-1);
            sql += " set " + cvstr;
        }
        if (key.Count > 0) {
            string filterstr = "";
            foreach (KeyValuePair<string, object> kv in key) {
                if (filterstr != "") {
                    filterstr += " and ";
                }
                filterstr += kv.Key + "='"+kv.Value.ToString()+"'";
            }
            sql += " where " + filterstr;
        }
        DBOP db = new DBOP();
        try
        {
            db.noquery(sql);
        }
        catch
        {
            throw;
        }

    }
    #endregion
}
