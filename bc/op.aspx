<%@ Page Language="C#" AutoEventWireup="true" CodeFile="op.aspx.cs" Inherits="bc_op" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>生产单审批</title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.web.js" type="text/javascript"></script>    
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/bcbackgroundop.css" rel="stylesheet" type="text/css" />
    <script>
        var labs;
		var filterobj={
                    extra: false,
                    messages: {
                        selectValue: "选择",
                        info: "条件",
                        filter: "筛选",
                        clear: "显示全部"
                    }
                };
		var checkedIds = {};
        $(function () {
            $.ajax({
                url: "bcws.asmx/LabList",
                contentType: "application/json;charset=utf-8",
                type: "POST",
                success: function (data) {
                    labs = data.d;
                    labs.unshift("");
                }
            });
            $("#GridSource").kendoDropDownList({
                change: function (e) {
                    switch (e.sender.selectedIndex) {
                        case 0: SelectAll(); break;
                        case 1: SelectPending(); break;
                        case 2: SelectLabHold(); break;
                        case 3: SelectApproved(); break;
                        case 4: SelectRejected(); break;
                        case 5: SelectCompleted(); break;
                        case 6: SelectReOpen(); break;
                        case 7: SelectCancel(); break;
                    }
                }
            }).data("kendoDropDownList").trigger("change");
            $(document).on("keyup", "#searchbox", function () {
                var keyword = this.value;
                $("#bcinput").data("kendoGrid").dataSource.filter({
                    filters: [{
                        field: "batch_no",
                        operator: "contains",
                        value: keyword
                    }]
                });
            }).on("click", "#refresh", RefreshGrid).on("click", ".k-grid-completeall", CompleteAll)
            .on("click", "#cw .k-cw-reopen", function () {

            }).on("click", "#cw .k-cw-cancel", function () {

            }).on("click","#bm",multipleSendMail)
            if (GetQueryString("status")) {
                var s = parseInt(GetQueryString("status"));
                if (typeof (s) === "number") {
                    $("#GridSource").data("kendoDropDownList").select(s)
                    $("#GridSource").data("kendoDropDownList").trigger("change");
                }
            }
        })
        function GetQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
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
        function BuildData(type,take) {
            var dataSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "bcws.asmx/GetBatchList_planner",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    create: {
                        url: "bcws.asmx/InputNewBatch",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    update: {
                        url: "bcws.asmx/OPUpdateBatch",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    parameterMap: function(data, operation) {
                        if (operation == "read") {
                            var para = { type: type };
                            if (typeof (take) !== "number") {
                                take = 500;
                            }
                            $.extend(para, { take: take });
                            return JSON.stringify(para);
                        } else if (operation == "create" || operation == "update") {
                            return JSON.stringify({ bmo: data });
                        }
                    }
                },
                error: function(e) {
                    alert(JSON.parse(e.xhr.responseText).Message);
                },
                batch: false,
                pageSize: 30,
                schema: {
                    data: "d",
                    total: function(data) {
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
                                },
                                defaultValue: ""
                            },
                            Uom: {
                                editable: false
                            },
                            shipping_date: {
                                type: "date"
                            },
                            recipe_ver: {
                                type: "number",
                                defaultValue: ""
                            },
                            history: {
                                type: "number",
                                defaultValue: ""
                            },
                            planner_comment: {
                                type: "string"
                            },
                            assign_lab: {
                                type: "string",
                                validation: {
                                    customRule1: function(input) {
                                        if (input.is("[name=assign_lab]")) {
                                            return $.trim(input.val()) !== "";
                                        }
                                        return true;
                                    }
                                },
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
                            },
                            approveby: {
                                editable: false
                            },
                            rejectby: {
                                editable: false
                            },
                            mail_times: {
                                editable: false
                            }
                        }
                    }
                }
            });
            return dataSource;
        }
        function SelectLabHold() {
            var dataSource = BuildData(2);
            $("#bcinput").empty().kendoGrid({
                dataSource: dataSource,
                navigateable: true,
                resizable: true,
                toolbar: [ {
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
                    format: "{0:yyyy-MM-dd}",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDatePicker({
                            format: "yyyy-MM-dd",
                            value: new Date(option.value)
                        })
                    }
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "history",
                    title: "History",
                    width: "70px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "assign_lab",
                    title: "Lab",
                    width: "80px",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDropDownList({
                            optionLabal: "",
                            autoBind: true,
                            dataSource: labs,
                            value: option.field
                        })
                    }
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#"
                }, {
                    field: "add_by",
                    title: "AddBy",
                    width: "100px"
                }, {
                    field: "planner_comment",
                    title: "OP Note"
                }],
                save: function (e) {
                    RefreshGrid();
                },
                edit: function (e) {
                    if (!e.model.isNew()) {
                        e.container.find("[name=batch_no]").attr("disabled", "disabled");
                    }
                }
            });
        }
        function SelectApproved() {
            var dataSource = BuildData(3);
            $("#bcinput").empty().kendoGrid({
                dataSource: dataSource,
                navigateable: true,
                resizable: true,
				height:700,
                toolbar: [{
                    template: kendo.template($("#search-box").html())
                },
                {
                    template: "<a id='refresh' class='k-button k-button-icontext'>Refresh</a>"
                }, {name:"completeall",text:"Complete All"}],
                editable: "inline",
                pageable: {
                    pageSize: 30
                },
				filterable: filterobj,
                columns: [{
                    command: [{
                        name: "complete",
                        text: "Complete",
                        click: CompleteBatch
                    }, {
                        name: "reopen",
                        text: "Re-open",
                        click: ReopenBatch
                    }],
                    title: "&nbsp;",
                    width: "175px"
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
                    format: "{0:yyyy-MM-dd}",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDatePicker({
                            format: "yyyy-MM-dd",
                            value: new Date(option.value)
                        })
                    }
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "history",
                    title: "History",
                    width: "70px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "assign_lab",
                    title: "Lab",
                    width: "80px",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDropDownList({
                            optionLabal: "",
                            autoBind: true,
                            dataSource: labs,
                            value: option.field
                        })
                    }
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#"
                }, {
                    field: "approveby",
                    title: "Approve by",
                    width: "100px"
                }, {
                    field: "add_by",
                    title: "AddBy",
                    width: "100px"
                },
                {
                    field:"adj_lab",
                    title:"Adjust Lab",
                    width:"70px"
                },
                {
                    field:"lab_comment",
                    title:"Lab Note", 
					width:"300px"
                }],
                save: function (e) {
                    RefreshGrid();
                },
                edit: function (e) {
                    if (!e.model.isNew()) {
                        e.container.find("[name=batch_no]").attr("disabled", "disabled");
                    }
                }
            });
        }
        function SelectRejected() {
            var dataSource = BuildData(4);
            $("#bcinput").empty().kendoGrid({
                dataSource: dataSource,
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
                    columns: [{
                        command: [{
                            name: "db",
                            text: "Delete",
                            click: CancelBatch
                        }, {
                            name: "reopen",
                            text: "Re-open",
                            click: ReopenBatch
}],
                            title: "&nbsp;",
                            width: "175px"
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
                    format: "{0:yyyy-MM-dd}",
                    editor: function(container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDatePicker({
                            format: "yyyy-MM-dd",
                            value: new Date(option.value)
                        })
                    }
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px",
                    editor: function(container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "history",
                    title: "History",
                    width: "70px",
                    editor: function(container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "assign_lab",
                    title: "Lab",
                    width: "80px",
                    editor: function(container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDropDownList({
                            optionLabal: "",
                            autoBind: true,
                            dataSource: labs,
                            value: option.field
                        })
                    }
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#"
                }, {
                    field: "rejectby",
                    title: "Reject by",
                    width: "100px"
                }, {
                    field: "add_by",
                    title: "AddBy",
                    width: "100px"
                }, {
                    field: "planner_comment",
                    title: "OP Note"
}],
                        save: function(e) {
                            RefreshGrid();
                        },
                        edit: function(e) {
                            if (!e.model.isNew()) {
                                e.container.find("[name=batch_no]").attr("disabled", "disabled");
                            }
                        }
                    });
        }
        function SelectCompleted() {
            var dataSource = BuildData(5);
            $("#bcinput").empty().kendoGrid({
                dataSource: dataSource,
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
				height:600,
				filterable: filterobj,
                columns: [{
                    command: [{
                        name: "reopen",
                        text: "Re-open",
                        click: ReopenBatch
                    }],
                    title: "&nbsp;",
                    width: "175px"
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
                    format: "{0:yyyy-MM-dd}",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDatePicker({
                            format: "yyyy-MM-dd",
                            value: new Date(option.value)
                        })
                    }
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "history",
                    title: "History",
                    width: "70px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "assign_lab",
                    title: "Lab",
                    width: "80px",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDropDownList({
                            optionLabal: "",
                            autoBind: true,
                            dataSource: labs,
                            value: option.field
                        })
                    }
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#"
                }, {
                    field: "approveby",
                    title: "Approve by",
                    width: "100px"
                }, {
                    field: "add_by",
                    title: "AddBy",
                    width: "100px"
                }, {
                    field: "planner_comment",
                    title: "OP Note",
                    width: "200px"
                }, {
                    field: "adj_lab",
                    title: "Adjust Lab",
                    width: "100px"
                },
                {
                    field: "lab_comment",
                    title: "Lab Note",
					width:"200px"
                }],
                save: function (e) {
                    RefreshGrid();
                },
                edit: function (e) {
                    if (!e.model.isNew()) {
                        e.container.find("[name=batch_no]").attr("disabled", "disabled");
                    }
                }
            });
        }
        function SelectReOpen() {
            var dataSource = BuildData(6);
            $("#bcinput").empty().kendoGrid({
                dataSource: dataSource,
                navigateable: true,
                resizable: true,
                toolbar: ["save", {
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
                columns: [{
                    command: ["edit", {
                        name: "send",
                        text: "Send",
                        click: SendBatch
                    }],
                    title: "&nbsp;",
                    width: "175px"
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
                    format: "{0:yyyy-MM-dd}",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDatePicker({
                            format: "yyyy-MM-dd",
                            value: new Date(option.value)
                        })
                    }
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "history",
                    title: "History",
                    width: "70px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "assign_lab",
                    title: "Lab",
                    width: "80px",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDropDownList({
                            optionLabal: "",
                            autoBind: true,
                            dataSource: labs,
                            value: option.field
                        })
                    }
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#"
                }, {
                    field: "add_by",
                    title: "AddBy",
                    width: "100px"
                }, {
                    field: "planner_comment",
                    title: "OP Note",
                    width: "200px"
                }, {
                    field: "adj_lab",
                    title: "Adjust Lab",
                    width: "100px"
                },
                {
                    field: "lab_comment",
                    title: "Lab Note"
                }],
                save: function (e) {
                    RefreshGrid();
                },
                edit: function (e) {
                    if (!e.model.isNew()) {
                        e.container.find("[name=batch_no]").attr("disabled", "disabled");
                    }
                }
            });
        }
        function SelectCancel() {
            var dataSource = BuildData(-1);
            $("#bcinput").empty().kendoGrid({
                dataSource: dataSource,
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
                columns: [{
                    command: [{
                        name: "reopen",
                        text: "Re-open",
                        click: ReopenBatch
                    }],
                    title: "&nbsp;",
                    width: "175px"
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
                    format: "{0:yyyy-MM-dd}",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDatePicker({
                            format: "yyyy-MM-dd",
                            value: new Date(option.value)
                        })
                    }
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "history",
                    title: "History",
                    width: "70px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "assign_lab",
                    title: "Lab",
                    width: "80px",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDropDownList({
                            optionLabal: "",
                            autoBind: true,
                            dataSource: labs,
                            value: option.field
                        })
                    }
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#"
                }, {
                    field: "rejectby",
                    title: "Reject by",
                    width: "100px"
                }, {
                    field: "add_by",
                    title: "AddBy",
                    width: "100px"
                }, {
                    field: "planner_comment",
                    title: "OP Note"
                }],
                save: function (e) {
                    RefreshGrid();
                },
                edit: function (e) {
                    if (!e.model.isNew()) {
                        e.container.find("[name=batch_no]").attr("disabled", "disabled");
                    }
                }
            });
        }
        function SelectPending() {
            var dataSource = BuildData(1);
            var grid=$("#bcinput").empty().kendoGrid({
                dataSource: dataSource,
                navigateable: true,
                resizable: true,
                toolbar: ["create", "save", {
                    template: kendo.template($("#search-box").html())
                },
                {
                    template: "<a id='refresh' class='k-button k-button-icontext'>Refresh</a>"
				},
				{
                        template: "<a id='bo' class='k-button k-button-bo' data-switch='off'>Batch-Operation</a>"
                    },
                    {
                        template: "<a id='bm' class='k-button k-button-bm' style='display:none'>Batch-SendMail</a>"
                    }],
                    editable: "inline",
                    pageable: {
                        pageSize: 30
                    },
                    filterable: filterobj,
                    columns: [
                {
                    command: ["edit", {
                        name: "Send",
                        click: SendBatch
}, {
                        name: "Delete",
                        click: CancelBatch
                    }],
                        title: "&nbsp;",
                        width: "224px"
                    },
					 {
                    template: "<input type='checkbox' class='checkbox' />",
                    width: "2.5em",
                    hidden:true
					},
                    {
                        field: "mail_times",
                        title: "Mail Times",
                        width: "2.5em",
                        headerTemplate: '<span class="k-icon k-mail"></span>',
                        filterable:false
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
                    format: "{0:yyyy-MM-dd}",
                    editor: function(container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDatePicker({
                            format: "yyyy-MM-dd",
                            value: new Date(option.value)
                        })
                    }
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px",
                    editor: function(container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "history",
                    title: "History",
                    width: "70px",
                    editor: function(container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "assign_lab",
                    title: "Lab",
                    width: "80px",
                    editor: function(container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDropDownList({
                            optionLabal: "",
                            autoBind: true,
                            dataSource: labs,
                            value: option.field
                        })
                    }
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#"
                }, {
                    field: "add_by",
                    title: "AddBy",
                    width: "100px"
                }, {
                    field: "planner_comment",
                    title: "OP Note"
}],
                    save: function(e) {
                        RefreshGrid();
                    },
					dataBound: function(e) {
                        var view = this.dataSource.view();
                        for (var i = 0; i < view.length; i++) {
                            if (checkedIds[view[i].id]) {
                                this.tbody.find("tr[data-uid='" + view[i].uid + "']")
                                    .addClass("k-state-selected")
                                    .find(".checkbox")
                                    .attr("checked", "checked");
                            }
                        }
                        $("#bo").bind("click", function () {
                            var g = $("#bcinput").data("kendoGrid");
                            self = $(this);
                            if ($(this).data("switch") == "off") {
                                g.hideColumn(0);
                                g.showColumn(1);
                                $(this).text("Single-Operation").data("switch", "on");
                                $("#bm").show();
                            } else {
                                g.hideColumn(1);
                                g.showColumn(0);
                                $(this).text("Batch-Operation").data("switch", "off");
                                $("#bm").hide();
                            }
                        })
					
                    },
                    edit: function(e) {
                        if (!e.model.isNew()) {
                            e.container.find("[name=batch_no]").attr("disabled", "disabled");
                        }
                    }
                }).data("kendoGrid");
            grid.table.on("click", ".checkbox", selectRow);
        }
		function selectRow(e) {
            var checked = this.checked,
                row = $(this).closest("tr"),
                grid = $("#bcinput").data("kendoGrid"),
                dataItem = grid.dataItem(row);
            checkedIds[dataItem.id] = checked;
            if (checked) {
                //-select the row
                row.addClass("k-state-selected");
            } else {
                //-remove selection
                row.removeClass("k-state-selected");
            }
        }
		function onDataBound(e) {
            var view = this.dataSource.view();
            for (var i = 0; i < view.length; i++) {
                if (checkedIds[view[i].id]) {
                    this.tbody.find("tr[data-uid='" + view[i].uid + "']")
                        .addClass("k-state-selected")
                        .find(".checkbox")
                        .attr("checked", "checked");
                }
            }
        }
        function SelectAll() {
            var dataSource = BuildData(0);
            $("#bcinput").empty().kendoGrid({
                dataSource: dataSource,
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
                    format: "{0:yyyy-MM-dd}",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDatePicker({
                            format: "yyyy-MM-dd",
                            value: new Date(option.value)
                        })
                    }
                }, {
                    field: "recipe_ver",
                    title: "Recipe Ver",
                    width: "85px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "history",
                    title: "History",
                    width: "70px",
                    editor: function (container, option) {
                        $("<input />").attr("name", option.field).appendTo(container).kendoNumericTextBox({ format: "n", decimals: 0 })
                    }
                }, {
                    field: "assign_lab",
                    title: "Lab",
                    width: "80px",
                    editor: function (container, option) {
                        var input = $("<input />");
                        input.attr("name", option.field).appendTo(container).kendoDropDownList({
                            optionLabal: "",
                            autoBind: true,
                            dataSource: labs,
                            value: option.field
                        })
                    }
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#"
                }, {
                    field: "approveby",
                    title: "Approve by",
                    width: "100px"
                }, {
                    field: "add_by",
                    title: "AddBy",
                    width: "100px"
                }, {
                    field: "planner_comment",
                    title: "OP Note"
                }],
                save: function (e) {
                    RefreshGrid();
                },
                edit: function (e) {
                    if (!e.model.isNew()) {
                        e.container.find("[name=batch_no]").attr("disabled", "disabled");
                    }
                }
            });
        }
        function RefreshGrid() {
            $("#bcinput").data("kendoGrid").dataSource.read();
        }
        function CompleteBatch(e) {
            e.preventDefault();
            var di = this.dataItem($(e.currentTarget).closest("tr"));
            if (di) {
                $.ajax({
                    async: false,
                    url: "bcws.asmx/BatchComplete",
                    contentType: "application/json;charset=utf-8",
                    type: "POST",
                    data: JSON.stringify({ bmo: di }),
                    success: function (data) {
                        RefreshGrid();
                    }
                })
            }
        }
        function CompleteAll() {
            $.ajax({
                url: "bcws.asmx/CompleteAll",
                contentType: "application/json;charset=utf-8",
                type: "POST",
                success: function (data) {
                    RefreshGrid();
                },
                error: showerrormsg
            })
        }
        function CancelBatch(e) {
            e.preventDefault();
            var di = this.dataItem($(e.currentTarget).closest("tr"));
            if (di) {
                $.ajax({
                    async: false,
                    url: "bcws.asmx/CancelBatch",
                    contentType: "application/json;charset=utf-8",
                    type: "POST",
                    data: JSON.stringify({ bmo: di }),
                    success: function (data) {
                        RefreshGrid();
                    }
                })
            }
        }
        function SendBatch(e) {
            e.preventDefault();
            var di = this.dataItem($(e.currentTarget).closest("tr"));
            SendMail(di);
        }
        function SendMail(di) {
            if (di) {
                $.ajax({
                    //async: false,
                    url: "bcws.asmx/SendBatchMail",
                    contentType: "application/json;charset=utf-8",
                    type: "POST",
                    data: JSON.stringify({ bmo: di }),
                    success: function(data) {
                        if (data.d == true) {
                            alert("Mail send success!");
                            RefreshGrid();
                        } else {
                            alert("Something wrong.....Please contact IT");
                        }
                    },
                    error: showerrormsg
                })
            }
        }
		function multipleSendMail() {
            var a = new Array();
            for (var i in checkedIds) {
                if (checkedIds[i]) {
                    a.push(i);
                }
            }
            $.ajax({
                url: "bcws.asmx/SendMultipleMail",
                contentType: "application/json;charset=utf-8",
                type: "POST",
                data: JSON.stringify({ Is: a }),
                success: function (data) {
                    if (data.d == true) {
                        alert("Mail send success!");
                        RefreshGrid();
                    } else {
                        alert("Something wrong.....Please contact IT");
                    }
                },
                error: showerrormsg
            })
        }
        function showerrormsg(e) {
            alert(JSON.parse(e.responseText).Message);
            RefreshGrid();
        }
        function ReopenBatch(e) {
            e.preventDefault();
            var di = this.dataItem($(e.currentTarget).closest("tr"));   
            if (di) {
                CommentPopup(function () {
                    $.ajax({
                        url: "bcws.asmx/ReOpen",
                        contentType: "application/json;charset=utf-8",
                        type: "POST",
                        data: JSON.stringify({ r_id: di.r_id, comment: $("#comment-inputer").val() }),
                        success: function () {
                        if (confirm("Send mail now?")) {
                                SendMail(di);
                            }
                            RefreshGrid();
                        }
                    })
                }).open();
            }
        }
        function CommentPopup(submit,cancel,eclose) {
            var d = $("#cw").kendoWindow({
                title: "Comment",
                width: 300,
                height: 200,
                resizable: false,
                modal: true,
                close: eclose,
                content: {
                    template: $("#inputComment").html()
                },
                position: {
                    top: 100, left: 200
                }
            });
            var w = d.data("kendoWindow").center();
            d.find(".k-cw-reopen").bind("click", submit).bind("click", function () { w.close(); });
            d.find(".k-cw-cancel").bind("click", cancel).bind("click", function () { w.close(); });
            return w;
        }
    </script>
    <script type="text/x-kendo-template" id="inputComment">
        <div class="">
            <textarea id="comment-inputer" class="k-input k-textbox" style="width:288px;height:150px"></textarea>            
        </div>
        <div style="text-align:center;padding-top:6px">
            <a class="k-button k-button-icontext k-cw-reopen">
                <span class="k-icon k-si-tick"></span>
                Re-Open
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
    <div>
        <div class="commandbar">
            <label>Select Batch Status:</label>
            <select id="GridSource">
                <option value="0">All(Without action)</option>
                <option value="1">Pending</option>
                <option value="2">Lab hold</option>
                <option value="3">Approved</option>
                <option value="4">Rejected</option>
                <option value="5">Completed</option>
                <option value="6">Reopened</option>
                <option value="-1">Deleted</option>
            </select>
            <a class="k-button k-button-icontext" href="upload.aspx">Excel批量上传</a>
        </div>
        <div id="bcinput"></div>
    </div>
    </form>
    <div id="cw"></div>
</body>
</html>
