<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="bc_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>生产单审批--查询</title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.web.min.js" type="text/javascript"></script>    
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/bcbackground.css" rel="stylesheet" type="text/css" />
    <script>
        var filterobj = {
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
            }
        };
        $(function() {
            $(document).on("keyup", "#searchbox", function() {
                var keyword = this.value;
                $("#bcinput").data("kendoGrid").dataSource.filter({
                    filters: [{
                        field: "batch_no",
                        operator: "contains",
                        value: keyword
}]
                    });
                }).on("click", "#refresh", RefreshGrid);
                var dataSource = BuildData(0);
                $("#bcinput").kendoGrid({
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
                    detailInit: ShowDetail,
                    filterable: {
                        extra: false,
                        messages: {
                            selectValue: "选择",
                            info: "条件",
                            filter: "筛选",
                            clear: "显示全部"
                            // isTrue:"是",
                            // isFalse:"否"
                        }
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
                    field: "assign_lab",
                    title: "Lab",
                    width: "80px"
                }, {
                    field: "r_status",
                    title: "Status",
                    width: "100px",
                    template: "#=decodeS(r_status)#",
                    filterable: {
                        ui: statusFilter
                    }
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
                    save: function(e) {
                        RefreshGrid();
                    },
                    edit: function(e) {
                        if (!e.model.isNew()) {
                            e.container.find("[name=batch_no]").attr("disabled", "disabled");
                        }
                    }
                });
            })
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
        function statusFilter(element) {
            element.kendoDropDownList({
                dataSource: [
                { text: "Pendding", value: 1 },
                { text: "Lab hold", value: 2 },
                { text: "Approve", value: 3 },
                { text: "Reject", value: 4 },
                { text: "Complete", value: 5 },
                { text: "Reopen", value: 6 },
                { text: "Cancel", value: -1 },
                ],
                dataTextField: "text",
                dataValueField: "value",
                optionLabel: "--选择状态--"
            });
        }
        function RefreshGrid() {
            $("#bcinput").data("kendoGrid").dataSource.read();
        }
        function showerrormsg(e) {
            alert(JSON.parse(e.responseText).Message);
            RefreshGrid();
        }
        function BuildData(type, take) {
            take = 0;
            var dataSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "bcws.asmx/GetBatchList_View",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        if (operation == "read") {
                            var para = { type: type };
                            if (typeof (take) !== "number") {
                                take = 200;
                            }
                            $.extend(para, { take: take });
                            return JSON.stringify(para);
                        } else if (operation == "create" || operation == "update") {
                            return JSON.stringify({ bmo: data });
                        }
                    }
                },
                error: function (e) {
                    alert(JSON.parse(e.xhr.responseText).Message);
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
                                    customRule1: function (input) {
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
                            }
                        }
                    }
                }
            });
            return dataSource;
        }
        function ShowDetail(e) {
            $("<div />").appendTo(e.detailCell).kendoGrid({
                dataSource: {
                    transport: {
                        read: {
                            url: "bcws.asmx/GetBatchHistory",
                            contentType: "application/json;charset=utf-8",
                            type: "POST"
                        },
                        parameterMap: function (data, operation) {
                            return JSON.stringify({r_id:e.data.r_id})
                        }
                    },
                    error: function (e) {
                        alert(JSON.parse(e.xhr.responseText).Message);
                    },
                    pageSize: 5,
                    schema: {
                        data: "d",
                        total: function (data) {
                            return data.d.length;
                        },
                        model: {
                            id: "a_id",
                            fields: {
                                a_id: { type: "number" },
                                action: { type: "string" },
                                people: { type: "string" },
                                comment: { type: "string" },
                                login_time: { type: "date" }
                            }
                        }
                    }
                },
                pageable: true,
                columns: [
                    { field: "login_time", title: "Time", width: "140px", format: "{0:yyyy-MM-dd HH:mm}" },
                    { field: "action", title: "Action", width: "70px" },
                    { field: "people", title: "Operator", width: "100px" },
                    { field: "comment", title: "Comment"}
                ]
            })
        }
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
    <div id="bcinput"></div>
    </div>
    </form>
</body>
</html>
