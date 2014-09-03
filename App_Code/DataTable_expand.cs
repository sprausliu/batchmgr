using System.Data;
using System.Collections.Generic;
using System.Text;
public static class DataTableExpand {
    public static string ToJson(this DataTable dt) {
        string columnFirst = "";
        List<string> result = new List<string>();
        StringBuilder Json = new StringBuilder();
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (columnFirst != dt.Rows[i][0].ToString())
                {
                    if (i != 0)
                    {
                        AddNewJson(Json, result, dt);
                    }
                    columnFirst = dt.Rows[i][0].ToString();
                    result = new List<string>();
                    for (int k = 0; k < dt.Columns.Count; k++)
                    {
                        result.Add("\"" + dt.Rows[i][k].ToString() + "\"");
                    }
                }
                else
                {
                    for (int k = 0; k < dt.Columns.Count; k++)
                    {
                        if (!result[k].Contains(dt.Rows[i][k].ToString()))
                        {
                            result[k] += ",\"" + dt.Rows[i][k].ToString() + "\"";
                        }
                    }
                }
                if (i == dt.Rows.Count - 1)
                {
                    AddNewJson(Json, result, dt);
                }
            }
        }
        var str = Json.ToString();
        return str;
        //return str.Remove(str.Length-1);
    }
    private static void AddNewJson(StringBuilder Json, List<string> result, DataTable dt)
    {
        Json.Append("{");
        for (int i = 0; i < dt.Columns.Count; i++)
        {
            Json.Append("\"");
            Json.Append(dt.Columns[i].ColumnName);
            Json.Append("\":");
            //Json.Append(":");
            if (result[i].Contains(","))
            {
                Json.Append("[");
                Json.Append(result[i]);
                if (i == dt.Columns.Count - 1)
                {
                    Json.Append("]");
                }
                else
                {
                    Json.Append("],");
                }
            }
            else
            {
                Json.Append(result[i]);
                if (i != dt.Columns.Count - 1)
                {
                    Json.Append(",");
                }
            }
        }
        Json.Append("}");
    }
    public static string CreateJsonParameters(this DataTable dt)
        {
            /* /****************************************************************************
             * Without goingin to the depth of the functioning of this Method, i will try to give an overview
             * As soon as this method gets a DataTable it starts to convert it into JSON String,
             * it takes each row and in each row it grabs the cell name and its data.
             * This kind of JSON is very usefull when developer have to have Column name of the .
             * Values Can be Access on clien in this way. OBJ.HEAD[0].<ColumnName>
             * NOTE: One negative point. by this method user will not be able to call any cell by its index.
             * *************************************************************************/
            StringBuilder JsonString = new StringBuilder();
            //Exception Handling        
            if (dt != null && dt.Rows.Count > 0)
            {
                //JsonString.Append("{ ");
                JsonString.Append("[");
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    JsonString.Append("{");
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        if (j < dt.Columns.Count - 1)
                        {
                            JsonString.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":" + "\"" + dt.Rows[i][j].ToString() + "\",");
                        }
                        else if (j == dt.Columns.Count - 1)
                        {
                            JsonString.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":" + "\"" + dt.Rows[i][j].ToString() + "\"");
                        }
                    }
                    /*end Of String*/
                    if (i == dt.Rows.Count - 1)
                    {
                        JsonString.Append("} ");
                    }
                    else
                    {
                        JsonString.Append("}, ");
                    }
                }
                //JsonString.Append("]}");
                JsonString.Append("]");
                return JsonString.ToString();
            }
            else
            {
                return null;
            }
       }
    public static string CreateJsonParametersWithoutBracket(this DataTable dt)
    {
        /* /****************************************************************************
         * Without goingin to the depth of the functioning of this Method, i will try to give an overview
         * As soon as this method gets a DataTable it starts to convert it into JSON String,
         * it takes each row and in each row it grabs the cell name and its data.
         * This kind of JSON is very usefull when developer have to have Column name of the .
         * Values Can be Access on clien in this way. OBJ.HEAD[0].<ColumnName>
         * NOTE: One negative point. by this method user will not be able to call any cell by its index.
         * *************************************************************************/
        StringBuilder JsonString = new StringBuilder();
        //Exception Handling        
        if (dt != null && dt.Rows.Count > 0)
        {
            //JsonString.Append("{ ");
            //JsonString.Append("[ ");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                JsonString.Append("{ ");
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    if (j < dt.Columns.Count - 1)
                    {
                        JsonString.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":" + "\"" + dt.Rows[i][j].ToString() + "\",");
                    }
                    else if (j == dt.Columns.Count - 1)
                    {
                        JsonString.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":" + "\"" + dt.Rows[i][j].ToString() + "\"");
                    }
                }
                /*end Of String*/
                if (i == dt.Rows.Count - 1)
                {
                    JsonString.Append("} ");
                }
                else
                {
                    JsonString.Append("}, ");
                }
            }
            //JsonString.Append("]}");
            //JsonString.Append("]");
            return JsonString.ToString();
        }
        else
        {
            return null;
        }
    }

}