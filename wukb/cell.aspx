<%@ Page Language="C#" AutoEventWireup="true" CodeFile="cell.aspx.cs" Inherits="background_wipcount" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Cell Information</title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.web.js" type="text/javascript"></script>
    <link href="../css/background.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.moonlight.min.css" rel="stylesheet" type="text/css" />
    <script>
        $(function () {
            dataSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "kbmgr.asmx/Get_WIP_Limit",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        type: "POST"
                    },
                    update: {
                        url: "kbmgr.asmx/Update_wip_limit",
                        contentType: "application/json;charset=utf-8",
                        //dataType: "json",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        if (operation != "read") {
                            return JSON.stringify({ cells: data.models });
                        } else {
                            data = $.extend({ sort: null, filter: null }, data)
                            return JSON.stringify(data);
                        }
                    }
                },
                batch: true,
                pageSize: 40,
                schema: {
                    data: "d",
                    model: {
                        id: "cellid",
                        fields: {
                            cellid: { editable: false },
                            cellname: { type: "string", editable: false },
                            cellwiplimit: { type: "number", format: "{0:n0}", validation: { min: 0} },
                            cellct: { type: "number", format: "{0:n0}", validation: { min: 0} }
                        }
                    }
                }
            });
            $("#celllist").kendoGrid({
                dataSource: dataSource,
                navigatable: true,
                pageable: false,
                height: 400,
                toolbar: ["save", "cancel"],
                columns: [
                //{ field: "cellid", title: "ID" },
                {field: "cellname", title: "CELL" },
                { field: "cellwiplimit", title: "WIP Limit(Num)" },
                { field: "cellct", title: "CT Target" }
                ],
                editable: true
            })
        })
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <div id="celllist"></div>
    </div>
    </form>
</body>
</html>
