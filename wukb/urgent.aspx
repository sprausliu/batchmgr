<%@ Page Language="C#" AutoEventWireup="true" CodeFile="urgent.aspx.cs" Inherits="background_urgentalert" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Urgent Flag</title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.web.min.js" type="text/javascript"></script>
    <link href="../css/background.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.moonlight.min.css" rel="stylesheet" type="text/css" />
    <style>
    .toolbar
    {
        float:right;
        }
    .inline-icon-false,.inline-icon-true
    {
        width:16px;height:16px;
        }
    .inline-icon-true
    {
        background:url("../css/styles/moonlight/sprite.png") -32px -32px no-repeat
        }
    </style>    
    <script type="text/x-kendo-template" id="search-box">
        <div class="toolbar">
            <label class="search-label" for="searchbox">Search Batch No or Item code:</label>
            <input type="search" id="searchbox" style="width:230px"></input>
        </div> 
    </script>
    <script>
        $(function () {
            dataSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "kbmgr.asmx/Get_Batch_Urgent",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        type: "POST"
                    },
                    update: {
                        url: "kbmgr.asmx/Update_Alert",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        if (operation != "read") {
                            return JSON.stringify({ bus: data.models });
                        } else {
                            data = $.extend({ sort: null, filter: null }, data)
                            return JSON.stringify(data);
                        }
                    }
                },
                batch: true,
                pageSize: 20,
                schema: {
                    data: "d",
                    total: function (data) {
                        return data.d.length;
                    },
                    model: {
                        id: "BatchId",
                        fields: {
                            BatchId: { editable: false },
                            Batchno: { editable: false },
                            Itemcode: { editable: false },
                            UrgentMark: { type: "boolean" },
                            UrgentDesc: { validation: { pattern: ".{0,100}"} },
                            InvType: { type: "string", editable: false },
                            Cell: { type: "string", editable: false },
                            Operator: { type: "string", editable: false },
                            AlertDate: { type: "date", editable: false, format: "{0:yyyy-MM-dd}" },
                            AbortDate: { type: "date", editable: false }
                        }
                    }
                }
            })
            $("#urgentbatchlist").kendoGrid({
                dataSource: dataSource,
                navigatable: true,
                pageable: {
                    refresh: true,
                    pageSize: 20,
                    pageSizes: [10, 20, 30, 50]
                },
                filterable: {
                    extra: false,
                    operators: {
                        string: {
                            contains: "包含"
                        }
                    },
                    messages: {
                        selectValue: "选择",
                        info: "条件",
                        filter: "筛选",
                        clear: "显示全部"
                        // isTrue:"是",
                        // isFalse:"否"
                    }
                },
                scrollable: false,
                sortable: true,
                //height: 800,
                toolbar: ["save","cancel",{ template: kendo.template($("#search-box").html())}],
                columns: [
                    { field: "Cell", title: "Cell", width: 100,
                        filterable: {
                            ui: cityFilter
                        }
                    },
                    { field: "Batchno", title: "Batch No", width: 100 },
                    { field: "Itemcode", title: "Item", width: 200 },
                    { field: "InvType", title: "Inventory Type", width: 90,
                        filterable: {
                            ui: function (element) {
                                element.kendoDropDownList({
                                    dataSource:["01","02","03","04"],
                                    optionLabel:""
                                })
                            }
                        }
                    },
                    { field: "UrgentMark", sortable: false, width: 80, title: "Urgent?", template: "<div class='inline-icon-#=(UrgentMark==true)?true:false#'></div>" },
                    { field: "UrgentDesc", title: "Descritpion", editor: udesc },
                    { field: "Operator", sortable: false, title: "Last Changed by" },
                    { field: "AlertDate", title: "Alert Date", format: "{0:yyyy-MM-dd HH:mm}", filterable: false }
                //{command:["edit"],width:"210px"}
                ],
                editable: "incell"
            })
            $("#searchbox").keyup(function () {
                var keyword = this.value;
                dataSource.filter({
                    logic: "or",
                    filters: [
                        { field: "Batchno", operator: "contains", value: keyword },
                        { field: "Itemcode", operator: "contains", value: keyword }
                    ]
                });
            })
        })
        function udesc(container,option){
            var input=$("<input />");
            input.attr("name",option.field).appendTo(container).kendoDropDownList({
                autoBind:false,
                optionLabel:"",
                dataSource:["","今天包车","明天包车","今天发货","明天发货","后天发货"],
                value:option.field
            })
        }
        function cityFilter(element) {
            element.kendoDropDownList({
                dataSource: {
                    transport: {
                        read: {
                            url: "kbmgr.asmx/Get_cells",
                            contentType: "application/json; charset=utf-8",
                            type: "POST"
                        }
                    },
                    schema: {
                        data: "d"
                    }
                },
                optionLabel: "--选择CELL--"
            });
           // alert("true");
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <div id="urgentbatchlist"></div>
    </div>
    </form>
</body>
</html>
