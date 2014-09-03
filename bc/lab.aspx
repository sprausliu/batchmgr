<%@ Page Language="C#" AutoEventWireup="true" CodeFile="lab.aspx.cs" Inherits="bc_lab" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>生产单审批</title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.web.min.js" type="text/javascript"></script>    
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/bcbackground.css" rel="stylesheet" type="text/css" />
    <style>
        .ex-comment {
            width:400px;
        }
    </style>
    <script type="text/javascript">
        var filterobj = {
            extra: false,
            messages: {
                selectValue: "选择",
                info: "条件",
                filter: "筛选",
                clear: "显示全部"
            },
            operators: {
                string: {
                    //eq:"等于",
                    //neq:"不等于",
                    //startswith:"以..开始",
                    contains:"包含",
                    //doesnotcontain:"不包含",
                    //endswith:"以...结尾"
                }
            }
        };
        $(function () {
            $("#GridSource").kendoDropDownList({
                change: function (e) {
                    switch (e.sender.selectedIndex) {
                        case 0: BindIP(); break;
                        case 1: BindHistory(); break;
                    }
                }
            }).data("kendoDropDownList").trigger("change");
            $(document).on("keyup", "#searchbox", function () {
                var keyword = this.value;
                $("#bcinput").data("kendoGrid").dataSource.filter({
                    logic:"or",
                    filters: [{
                        field: "batch_no",
                        operator: "contains",
                        value: keyword
                    },{
                        field: "item_code",
                        operator: "contains",
                        value: keyword
                    }]
                });
            }).on("click", "#refresh", RefreshGrid)
            
        })
        
        function BindHistory() {
            $("#bcinput").empty().kendoGrid({
                dataSource: BuildData(500, 1),
                navigateable: true,
                resizable: true,
                toolbar: [{
                    template: kendo.template($("#search-box").html())
                },
                {
                    template: "<a id='refresh' class='k-button k-button-icontext'>Refresh</a>"
                }],
                editable: "inline",
filterable: filterobj,
                pageable: {
                    pageSize: 30
                },
                columns: [
                {
                    field: "batch_no",
                    title: "Batch",
                    width: "100px"
                },
                {
                    field: "item_code",
                    title: "Item",
                    width: "150px"
                },
                {
                    field: "qty",
                    title: "Qty",
                    width: "70px"
                },
                {
                    field: "shipping_date",
                    title: "Shipping Date",
                    width: "120px",
                    format: "{0:yyyy-MM-dd}"
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px"
                }, {
                    field: "history",
                    title: "History",
                    width: "70px"
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#",
                    filterable: {
                        ui: statusFilter
                    }
                },
                {
                    field:"add_by",
                    title:"Creator",
                    width:"70px"
                },
                {
                    field: "planner_comment",
                    title: "OP Note",
                    width: "200px"
                }, {
                    field: "adj_lab",
                    title: "Adjust Lab",
                    width: "100px"
                }, {
                    field:"lab_comment",
                    title:"Lab Note"
                }]
            })
        }
        function statusFilter(element) {
            element.kendoDropDownList({
                dataSource: [
                {text:"Pendding",value:1},
                {text:"Lab hold",value:2},
                {text:"Approve",value:3},
                {text:"Reject",value:4},
                {text:"Complete",value:5},
                {text:"Reopen",value:6},
                {text:"Cancel",value:-1},
                ],
                dataTextField: "text",
                        dataValueField: "value",
                optionLabel: "--选择状态--"
            });
        }
        function BindIP() {
            $("#bcinput").empty().kendoGrid({
                dataSource: BuildData(200,0),
                navigateable: true,
                resizable: true,
                toolbar: [{
                    template: kendo.template($("#search-box").html())
                },
                {
                    template: "<a id='refresh' class='k-button k-button-icontext'>Refresh</a>"
                }],
                editable: "inline",
                pageable: {
                    pageSize: 30
                },
                filterable: filterobj,
                columns: [
                {
                    command: [
                        {
                            name:"hold",
                            text:"Hold",
                            click:HoldBatch
                        },
                        {
                            name: "approve",
                            text: "Approve",
                            click: ApproveBatch
                        },
                        {
                            name: "reject",
                            text: "Reject",
                            click: RejectBatch
                        }
                    ],
                    title: "&nbsp",
                    width: "224px"
                },
                {
                    field: "batch_no",
                    title: "Batch",
                    width: "100px"
                },
                {
                    field: "item_code",
                    title: "Item",
                    width: "150px"
                },
                {
                    field: "qty",
                    title: "Qty",
                    width: "70px"
                },
                {
                    field: "shipping_date",
                    title: "Shipping Date",
                    width: "120px",
                    format: "{0:yyyy-MM-dd}"
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px"
                }, {
                    field: "history",
                    title: "History",
                    width: "70px"
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#"
                }, {
                    field: "add_by",
                    title: "Creator",
                    width: "70px"
                }, {
                    field: "planner_comment",
                    title: "OP Note",
                    width: "200px"
                }, {
                    field: "lab_comment",
                    title: "Lab Note"
                }]
            });
        }
        function RefreshGrid() {
            $("#bcinput").data("kendoGrid").dataSource.read();
        }
        function decodeS(a) {
            switch (a) {
                case 1: return "Pending";
                case 2: return "Lab hold";
                case 3: return "Approved";
                case 4: return "Rejected";
                case 5: return "Completed";
                case 6: return "Reopened";
                case -1: return "Cancel";
                default: return "unknown";
            }
        }
//        function HoldBatch(e) {
//            e.preventDefault();
//            var di = this.dataItem($(e.currentTarget).closest("tr"));
//            $.ajax({
//                url: "bcws.asmx/TakeBatch",
//                contentType: "application/json;charset=utf-8",
//                type: "POST",
//                data: JSON.stringify({ bml: di }),
//                success: RefreshGrid
//            });
        //        }
        function HoldBatch(e) {
            e.preventDefault();
            var di = $("#bcinput").data("kendoGrid").dataItem($(e.currentTarget).closest("tr"));
            CommentPopup({
                action: "Hold"
                , onSubmit: function(w) {
                    var validator=$("#opw").kendoValidator().data("kendoValidator");
                    if(validator.validate()){
                        $.ajax({
                            url: "bcws.asmx/TakeBatch",
                            contentType: "application/json;charset=utf-8",
                            type: "POST",
                            data: JSON.stringify({ r_id: di.r_id, comment: $("#comment-inputer").val() + "\n Signature:" + $("#Signature").val()  ,ifbymanual:$("#ifneedtech").is(":checked"),signature:$("#Signature").val()}),
                            success: RefreshGrid
                        });
                    }else{
                        w.stopImmediatePropagation()
                    }
                }
                , onOpen: function() {
                    $("#comment-inputer").val(di.lab_comment);
                }
                , title: "Hold " + di.batch_no
                , item: di
            }).open();
        }
        function AdjBy(lab) {
            var a = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "bcws.asmx/GetAdjList",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        return JSON.stringify({ lab: lab });
                    }
                },
                schema: {
                    data: "d",
                    model: {
                        fields: {
                            adj_lab_list: { type: "string" }
                        }
                    }
                }
            });
            return a;    
        }
        function ApproveBatch(e) {
            e.preventDefault();
            var di = $("#bcinput").data("kendoGrid").dataItem($(e.currentTarget).closest("tr"));
            CommentPopup({ action: "Approve", onSubmit: function () {
                var validator=$("#opw").kendoValidator().data("kendoValidator");
                    if(validator.validate()){
                $.ajax({
                    url: "bcws.asmx/ApproveBatch",
                    contentType: "application/json;charset=utf-8",
                    type: "POST",
                    data: JSON.stringify({ r_id: di.r_id, adj_lab: $("#adjlab").val(), comment: $("#comment-inputer").val() + "\n Signature:" + $("#Signature").val(), comment1: $("#comment1").val(), comment2: $("#comment2").val() }),
                    success: RefreshGrid
                });}else{
                        w.stopImmediatePropagation()
                    }
            }, onOpen: function () {
                $("#adjlab").kendoDropDownList({
                    dataSource: AdjBy(di.assign_lab)
                });
                $.ajax({
                    url: "bcws.asmx/GetLastComment",
                    contentType: "application/json;charset=utf-8",
                    type: "POST",
                    data: JSON.stringify({ item: di.item_code }),
                    success: function (data) {
                        var c = data.d;
                        if (c != "") {
                            c = c + " (Following the previous batch)";
                        }
                        $("#comment-inputer").val(c);
                    },
                    error: function (e) {
                        alert(JSON.parse(e.responseText).Message);
                        RefreshGrid();
                    }
                })

            }, title: di.batch_no + " approve"
                , item: di
            }).open();
        }
        function RejectBatch(e) {
            e.preventDefault();
            var di = $("#bcinput").data("kendoGrid").dataItem($(e.currentTarget).closest("tr"));
            CommentPopup({ action: "Reject", onSubmit: function () {
            var validator=$("#opw").kendoValidator().data("kendoValidator");
                    if(validator.validate()){
                $.ajax({
                    url: "bcws.asmx/RejectBatch",
                    contentType: "application/json;charset=utf-8",
                    type: "POST",
                    data: JSON.stringify({ r_id: di.r_id, comment: $("#comment-inputer").val() + "\n Signature:" + $("#Signature").val() }),
                    success: RefreshGrid
                });}else{
                        w.stopImmediatePropagation()
                    }
            }, title: di.batch_no + " reject", item: di
            }).open();
        }
        function CommentPopup(option) {
            var options = {
                action: ""
            , onSubmit: function () { }
            , onCancel: function () { }
            , onEclose: function () { }
            , onOpen: function () { }
                , title: "Comment"
                , item: {}
            };
            options = $.extend(options, option);
            var ct = kendo.template($("#inputComment").html());
            var windowopts = {
                title: options.title,
                width: 600,
                height: options.action == "Approve" ? 340 : 320,
                resizable: false,
                modal: true,
                open: options.onOpen,
                close: options.onEclose,
                activate: options.onActivate,
                position: {
                    top: 100, left: 200
                }
            };
            var d = $("#cw").kendoWindow(windowopts)
            if ($("#cw").data("kendoWindow")) {
                $("#cw").data("kendoWindow").setOptions(windowopts);
            } 
            var w = d.data("kendoWindow").content(ct($.extend(options.item,{ action: options.action }))).center();
            d.find(".k-cw-action").bind("click", options.onSubmit).bind("click", function () { w.close(); });
            d.find(".k-cw-cancel").bind("click", options.onCancel).bind("click", function () { w.close(); });
            return w;
        }
        function BuildData(take,page) {
            var dataSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "bcws.asmx/GetBatchList_lab",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        if (operation == "read") {
                            if (typeof (take) !== "number") {
                                take = 200;
                            }
                            var para = { take: take,page:page };
                            return JSON.stringify(para);
                        } else if (operation == "create" || operation == "update") {
                            return JSON.stringify({ bml: data });
                        }
                    }
                },
                batch: false,
                pageSize: 30,
                schema: {
                    data: "d",
                    total: function (data) {
                        return data.d.length;
                    },
                    model: {
                        id: "r_id",
                        fields: {
                            r_id: {
                                editable: false
                            },
                            batch_no: {
                                type: "string",
                                validation: {
                                    required: true
                                }
                            },
                            item_code: {
                                type: "string",
                                validation: {
                                    required: true
                                }
                            },
                            qty: {
                                type: "number",
                                validation: {
                                    required: true
                                }
                            },
                            Uom: {
                                editable: false
                            },
                            shipping_date: {
                                type: "date"
                            },
                            recipe_ver: {
                                type: "number"
                            },
                            history: {
                                type: "number"
                            },
                            planner_comment: {
                                type: "string"
                            },
                            assign_lab: {
                                type: "string",
                                defaultValue: ""
                            },
                            adj_lab: {
                                editable: false
                            },
                            lab_comment: {
                                editable: false
                            },
                            r_status: {
                                editable: false,
                                type:"number"
                            },
                            add_date: {
                                editable: false
                            },
                            add_by: {
                                editable: false
                            },
                            modify_date: {
                                editable: false
                            },
                            modify_by: {
                                editable: false
                            },
                            check_times: {
                                editable: false
                            },
                            current_officer: {
                                editable: false
                            },
                            r_orgn: {
                                editable: false
                            }
                        }
                    }
                }
            });
            return dataSource;
        }
    </script>
    <script id="inputComment" type="text/x-k需求endo-template">
        <div id="opw" class="">
            # if(action=="Approve"){ 
            #<label for="adjlab">Adjust Lab:</label>
            <select id="adjlab"></select>#
        }#
        <div>
            <table>
                <tbody>
                    <tr>
                        <td><strong>Batch NO:</strong>${batch_no}</td>
                        <td><strong>Item Code:</strong>${item_code}</td>
                        <td style="display:#if(action!="Hold"){#none#}#"><input id="ifneedtech" type="checkbox" /><label for="ifneedtech">需实验室手改单</label></td>
                    </tr>
                </tbody>
            </table>
        </div>
            <textarea id="comment-inputer" class="k-input k-textbox" style="width:500px;height:150px"></textarea>            
            <table>
                <tbody>
                    <tr><td><strong>Comment1:</strong><input id="comment1" class="ex-comment"/></tr>
        <tr><td><strong>Comment2:</strong><input id="comment2" class="ex-comment"/></tr>
                    <tr>
                        <td><strong>Signature:</strong><input id="Signature" required data-required-msg="请签名!"/></td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div style="text-align:center;padding-top:6px">
            <a class="k-button k-button-icontext k-cw-action">
                <span class="k-icon k-si-tick"></span>
                #= action #
            </a>
            <a class="k-button k-button-icontext k-cw-cancel">
                <span class="k-icon k-si-cancel"></span>
                Cancel
            </a>
        </div>
    </script>
    <script type="text/x-kendo-template" id="search-box">
        <div class="toolbar">
            <label class="search-label" for="searchbox">Search:</label>
            <input type="search" id="searchbox" style="width:230px"></input>
        </div> 
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="commandbar">
        <label>Select Page:</label>
            <select id="GridSource">
                <option value="0">In process</option>
                <option value="1">History</option>
            </select>
    </div>
    <div>
        <div id="bcinput"></div>
    </div>
    </form>
    <div id="cw"></div>
</body>
</html>
