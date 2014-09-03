using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;

/// <summary>
///ExcelImport 的摘要说明
/// </summary>
[Serializable]  //使用 Serializable 属性方法 ,标记该类是可序列化的
public class ExcelImport
{

    #region 成员变量

    //导入的excel文件
    private string excelFile = string.Empty;

    //错误信息
    private string messages = string.Empty;

    //导入记录的最大数量
    private int maxRecordQty = 0;

    //成功记录数
    private int successRecordQty = 0;

    //错误记录数
    private int errorRecordQty = 0;

    //提交记录数
    private int submitRecordQty = 0;

    //维护用户
    //private string userid = string.Empty;

    //数据集
    private DataTable dt = null;

    #endregion

    #region 公共属性

    /// <summary>
    /// Excel文件
    /// </summary>
    public string ExcelFile
    {
        set { this.excelFile = value; }
        get { return this.excelFile; }
    }

    /// <summary>
    /// 提示信息
    /// </summary>
    public string Message
    {
        get { return this.messages; }
    }

    /// <summary>
    /// 导入记录的最大数量
    /// </summary>
    public int MaxRecordQty
    {
        set { this.maxRecordQty = value; }
        get { return this.maxRecordQty; }
    }

    /// <summary>
    /// 导入成功的记录数量
    /// </summary>
    public int SuccessRecordQty
    {
        get { return this.successRecordQty; }
    }

    /// <summary>
    /// 导入失败记录的数量
    /// </summary>
    public int ErrorRecordQty
    {
        get { return this.errorRecordQty; }
    }

    /// <summary>
    /// 本次提交的记录数
    /// </summary>
    public int SubmitRecordQty
    {
        get { return this.submitRecordQty; }
    }

    public DataTable ExcelData
    {
        get { return this.dt; }
    }

    /// <summary>
    /// 维护用户
    /// </summary>
    //public string UserID
    //{
    //    set { this.userid = value; }
    //    get { return this.userid; }
    //}

    #endregion

    #region 构造函数

    public ExcelImport()
    {
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="excel">Excel文件</param>
    public ExcelImport(string excel)
    {
        this.excelFile = excel;
    }

    #endregion

    #region 公共方法

    /// <summary>
    /// 读取Excel文档 
    /// </summary>
    public bool ExcelToTable()
    {
        try
        {
            //创建Excel数据源
            string dataConn = "Provider=Microsoft.Jet.OLEDB.4.0;" + "Data Source=" + this.excelFile + ";" + "Extended Properties=\"Excel 8.0\"";
            if (Path.GetExtension(this.excelFile).ToLower().Equals(".xlsx"))
            {
                dataConn = "Provider=Microsoft.Ace.OleDb.12.0;" + "data source=" + this.excelFile + ";Extended Properties=\"Excel 12.0\"";
            }
            //查询SQL
            string query = "SELECT " + " TOP " + this.maxRecordQty.ToString() + " batch,item,qty,shipping_date,recipe,history,OP_note,Lab, ''as 状态 FROM [Batch$] where batch<>''";

            //创建Dt实例
            try
            {
                dt = new DataTable();
            }
            catch
            {
            }

            #region 连接数据源获取数据
            OleDbConnection conn = null;
            using (conn = new OleDbConnection(dataConn))
            {
                try
                {
                    OleDbCommand command = new OleDbCommand(query, conn);
                    conn.Open();
                    OleDbDataReader reader = command.ExecuteReader();
                    DataColumn col = null;
                    DataRow row = null;
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        col = new DataColumn();
                        col.ColumnName = reader.GetName(i);
                        col.DataType = reader.GetFieldType(i);
                        dt.Columns.Add(col);
                    }
                    while (reader.Read())
                    {
                        row = dt.NewRow();
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            row[i] = reader[i];
                        }
                        dt.Rows.Add(row);
                    }
                    reader.Close();
                }
                catch (OleDbException e)
                {
                    throw new Exception(e.Message);
                }
                catch (Exception e)
                {
                    throw new Exception(e.Message);
                }
                finally
                {
                    try
                    {
                        conn.Close();
                    }
                    catch
                    {
                    }
                    conn = null;
                }

            }
            #endregion

            #region 补充数据

            //if ((dt != null) && (dt.Rows.Count > 0))
            //{
            //    for (int i = 0; i < dt.Rows.Count; i++)
            //    {
            //        try
            //        {
            //            if ((dt.Rows[i]["不含税价"] == DBNull.Value) || (dt.Rows[i]["不含税价"].ToString().Length == 0))
            //                dt.Rows[i]["不含税价"] = 0;
            //        }
            //        catch
            //        {
            //        }
            //        try
            //        {
            //            if ((dt.Rows[i]["含税价"] == DBNull.Value) || (dt.Rows[i]["含税价"].ToString().Length == 0))
            //                dt.Rows[i]["含税价"] = 0;
            //        }
            //        catch
            //        {
            //        }
            //        try
            //        {
            //            if ((dt.Rows[i]["税率"] == DBNull.Value) || (dt.Rows[i]["税率"].ToString().Length == 0))
            //                dt.Rows[i]["税率"] = 0;
            //        }
            //        catch
            //        {
            //        }
            //        try
            //        {
            //            if ((dt.Rows[i]["运费"] == DBNull.Value) || (dt.Rows[i]["运费"].ToString().Length == 0))
            //                dt.Rows[i]["运费"] = 0;
            //        }
            //        catch
            //        {
            //        }
            //        try
            //        {
            //            if ((dt.Rows[i]["启动日期"] == DBNull.Value) || (dt.Rows[i]["启动日期"].ToString().Length == 0))
            //                dt.Rows[i]["启动日期"] = DateTime.Now;
            //        }
            //        catch
            //        {
            //        }
            //    }
            //}

            #endregion

            try
            {
                this.submitRecordQty = this.dt.Rows.Count;
            }
            catch
            {
                this.submitRecordQty = 0;
            }

            return true;
        }
        catch (Exception e)
        {
            this.messages = e.Message;
            return false;
        }
    }

    /// <summary>
    /// 提交数据到SqlServer
    /// </summary>
    public bool TableToSql(string dataConn)
    {
        try
        {
            //string dataConn1 = "Data Source=Jeremy-PC\\SQL2008;Initial Catalog=test;Persist Security Info=True;User ID=sa;Password=Bian988625";

            if ((this.dt == null) || (dt.Rows.Count == 0))
                throw new Exception("空数据集！");

            SqlConnection conn = null;
            SqlCommand comm = null;

            using (conn = new SqlConnection(dataConn))
            {
                try
                {
                    //打开数据连接
                    conn.Open();
                    comm = new SqlCommand();
                    comm.Connection = conn;
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        try
                        {
                            comm.CommandText = "UPDATE [test].[dbo].[t_computer] SET [ServiceTag] = '" + dt.Rows[i]["ServiceTag"].ToString() + "',"
                                             + "[PO] = '" + dt.Rows[i]["PO"].ToString() + "',"
                                             + "[Model] = '" + dt.Rows[i]["Model"].ToString() + "',"
                                             + "[Type] = '" + dt.Rows[i]["Type"].ToString() + "',"
                                             + "[Currentuser] = '" + dt.Rows[i]["Currentuser"].ToString() + "',"
                                             + "[UseDate] = '" + dt.Rows[i]["UseDate"].ToString() + "',"
                                             + "[DeliveryDate] = '" + dt.Rows[i]["DeliveryDate"].ToString() + "',"
                                             + "[MK] = '" + dt.Rows[i]["MK"].ToString() + "',"
                                             + "[Battery] = '" + dt.Rows[i]["Battery"].ToString() + "',"
                                             + "[ACAdapter] = '" + dt.Rows[i]["ACAdapter"].ToString() + "',"
                                             + "[Remark] = N'" + dt.Rows[i]["Remark"].ToString() + "',"
                                             + "[Checker] = '" + dt.Rows[i]["Checker"].ToString() + "'"
                                             + " WHERE [ComputerName] = '" + dt.Rows[i]["ComputerName"].ToString() + "'";

                            comm.ExecuteNonQuery();

                            dt.Rows[i]["状态"] = "成功";
                            this.successRecordQty++;

                        }
                        catch (Exception e)
                        {
                            this.messages = e.Message;
                            dt.Rows[i]["状态"] = "失败";
                            this.errorRecordQty++;
                        }
                    }
                }
                catch (OleDbException e)
                {
                    throw new Exception(e.Message);
                }
                catch (Exception e)
                {
                    throw new Exception(e.Message);
                }
                finally
                {
                    try
                    {
                        conn.Close();
                    }
                    catch
                    {
                    }
                    conn = null;
                }
            }
            return true;
        }
        catch (Exception e)
        {
            this.messages = e.Message;
            return false;
        }
    }

    /// <summary>
    /// 删除错误的记录
    /// </summary>
    public void DeleteError()
    {
        try
        {
            DataRow[] drc = dt.Select("状态 = '失败'");
            foreach (DataRow dr in drc)
                dt.Rows.Remove(dr);
        }
        catch
        {
        }
    }

    /// <summary>
    /// 删除成功的记录
    /// </summary>
    public void DeleteSuccess()
    {
        try
        {
            DataRow[] drc = dt.Select("状态 = '成功'");
            foreach (DataRow dr in drc)
                dt.Rows.Remove(dr);
        }
        catch
        {
        }
    }

    #endregion

}//end class