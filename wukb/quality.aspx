<%@ Page Language="C#" AutoEventWireup="true" CodeFile="quality.aspx.cs" Inherits="background_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
    <script type="text/javascript">
        
        $(function () {
            dataSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "kbmgr.asmx/Get_QualityList",
                        contentType: "application/json;charset=utf-8",
                        dataType: "json",
                        type: "POST"
                    },
                    update: {
                        url: "kbmgr.asmx/Update_Quality",
                        contentType: "application/json;charset=utf-8",
                        dataType: "json",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        if (operation != "read") {
                            return JSON.stringify({ qas: data.models });
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
                        id: "batch_id",
                        fields: {
                            //batch_id: { editable: false },
                            QualityIssue: { type: "boolean" },
                            QITime: { type: "date", editable: false },
                            Operator: { editable: false },
                            BatchNo: { editable: false },
                            Cell: { editable: false },
                            ItemName: { editable: false },
                            QualityResponsibleBy: { validation: {pattern :".{0,20}"} },
                            QualityDesc: { validation: { pattern: ".{0,100}"} }
                        }
                    }
                }
            });
            $("#qualitylist").kendoGrid({
                dataSource: dataSource,
                //navigatable: true,
                pageable: {
                    refresh: true,
                    pageSize: 20,
                    pageSizes: [10, 20, 30, 50]
                },
                //toolbar: kendo.template($("#search-box").html()),
                filterable: {
                    extra: false,
                    operators: {
                        string: {
                            //                            startswith: "Starts with",
                            //                            eq: "Is equal to",
                            //                            neq: "Is not equal to"
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
                //                filterable: {
                //                    extra: false,
                //                    operators: {
                //                        string: {
                //                            startswith: "Starts with",
                //                            eq: "Is equal to",
                //                            neq: "Is not equal to"
                //                        }
                //                    }
                //                },
                sortable: true,
                pageable: {
                    refresh: true,
                    pageSize: true
                },
                toolbar: [ { template: kendo.template($("#search-box").html())}],
                columns: [
                    {
                        field: "BatchNo",
                        title: "Batch No",
                        width: 90
                        // filterable:false
                    },
                    {
                        field: "ItemName",
                        title: "Item",
                        width: 200
                        //  filterable:false
                    },
                    {
                        field: "Cell",
                        title: "Cell",
                        filterable: {
                            ui: cellFilter
                        },
                        width:110
                    },
                    {
                        field: "QualityIssue",
                        sortable: false,
                        title: "Highlight",
                        filterable: false,
                        width:80,
                        template:"<div class='inline-icon-#=(QualityIssue==true)?true:false#'></div>"
                        //template: "<input type='checkbox' #= (QualityIssue==true)?checked='checked':''# disabled />"
                    },
                    {
                        field:"QualityResponsibleBy",
                        title:"Responsible By",
                        width:120,
                        editor: DeptInput
                        //values: responsible
                    },
                    {
                        field:"QualityDesc",
                        title:"Description",
                        width: 230,
                        editor:Reasons
                        //values:reasons
                    },
                    {
                        field: "Operator",
                        sortable: false,
                        width:130,
                        title: "Last Modify by"
                        //filterable:false
                        
                    },
//                    {
//                        field: "QITime",
//                        title: "Last Modified",
//                        //width:120,
//                        format: "{0:yyyy-MM-dd HH:mm}"
//                        // filterable:false,
//                        
//                    },
                    { command: ["edit"] }
                ],
                editable: "inline"
            })
            $("#searchbox").keyup(function () {
                var keyword = this.value;
                dataSource.filter({
                    logic: "or",
                    filters: [
                        { field: "BatchNo", operator: "contains", value: keyword },
                        { field: "ItemName", operator: "contains", value: keyword }
                    ]
                });
            })
        })
        function DeptInput(container,option){
            var input=$("<input />");
            input.attr("name",option.field).appendTo(container).kendoDropDownList({
                autoBind: false,
                encoded:false,
                optionLabel: " ",
                dataSource:["技术部","QC","生产部","工艺部","供应链"],
                value:option.field
            })
        }
        function Reasons(container, option) {
            var input = $("<input />");
            input.attr("name", option.field).appendTo(container).kendoDropDownList({
                autoBind:false,
                optionLabel: " ",
                dataSource:["细度","色差","清洁度","缩孔","粘度","电阻率","备料问题","生产单问题"],
                value:option.field
            })
        }
        function cellFilter(element) {
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
    <title>Quality Flag</title>
</head>
<body>
<div id="qualitylist"></div>
    <form id="form1" runat="server">
    <div>
        
    </div>
    </form>
</body>
</html>
