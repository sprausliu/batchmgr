<%@ Page Language="C#" AutoEventWireup="true" CodeFile="standardct.aspx.cs" Inherits="background_standardct" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.web.js" type="text/javascript"></script>
    <link href="../css/background.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.moonlight.min.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        $(function () {
            AverageCTSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "../kbmgr.asmx/Get_FillAverageCT",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        if (operation != "read") {
                            return JSON.stringif({ items: data.models });
                        } else {
                            data = $.extend({ sort: null, filter: null }, data);
                            return JSON.stringify(data);
                        }
                    }
                },
                batch: true,
                pageSize: 500,                
                schema: {
                    data: "d",
                    model: {
                        id: "ItemId", //ID字段
                        fields: {
                            ItemName:{editable:false},
                            Cell:{editable:false},
                            Hours:{type:"number"}
                        }
                    }
                }
            })
            $("#ctgrid").kendoGrid({
                dataSource:AverageCTSource,
                navigatable:true,
                pageable:true,
                sortable:true,
                height: 500,
                detailInit: InitRangeCTView,
                columns:[
                    {field:"ItemName",title:"Item Code"},
                    {field:"Cell",title:"Cell"},
                    {field:"hours",title:"Standard Hours"}
                ],
                editable:true,
                selectable:"row"
            })
        })
        function InitRangeCTView(e) {
         RangeCTSource=new kendo.data.DataSource({
                    transport: {
                        read: {
                            url: "../kbmgr.asmx/Get_FillRangeCT",
                            contentType: "application/json;charset=utf-8",
                            type: "POST"
                        },
                        parameterMap: function (data, operation) {
                            if (operation != "read") {
                                return JSON.stringif({ rangect: data.models });
                            } else {
                                data = $.extend({ sort: null, filter: null }, data);
                                return JSON.stringify(data);
                            }
                        }
                    },
                    filter: { field: "ItemId", operator: "eq", value: e.data.ItemId },
                    batch: true,
                   // serverPaging: true,
                    serverSorting: true,
                    serverFiltering:true,
                    pageSize:10,
                    schema: {
                        data: "d",
                        model: {
                            id: "RCTUID",
                            fields: {
                                LowLimit: { type: "number" },
                                UpLimit: { type: "number" },
                                Hours: { type: "number" }
                            }
                        }
                    }
                })
                $("<div/>").appendTo(e.detailCell).kendoGrid({
                    dataSource: RangeCTSource,
                    editable: true,
                    sortable: true,
                    pageable: false,
                    selectable: "row",
                    dataBound: function (e) {
                        if (this.items().length <= 0) {
                            this.addRow();
                        }
                    },
                    columns: [
                    { field: "LowLimit", headerAttributes: { style: "display:none"} },
                    { field: "UpLimit", headerAttributes: { style: "display:none"} },
                    { field: "Hours", headerAttributes: { style: "display:none"} }
                ]
                })
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <div id="ctgrid"></div>
    </div>
    </form>
</body>
</html>
