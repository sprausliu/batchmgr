<%@ Page Language="C#" AutoEventWireup="true" CodeFile="query.aspx.cs" Inherits="mc_query" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>手工结单批次查询</title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.all.min.js" type="text/javascript"></script>    
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.moonlight.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/background.css" rel="stylesheet" type="text/css" />
    <script>
        $(function () {
            $("#chartwindow").kendoWindow({
                visible: false,
                position: {top:"50px",left:"50px"}
                //pinned: true,
            });
            $("#chartpanel").kendoChart({
                dataSource: {
                    transport: {
                        read: {
                            url: "../mc.asmx/ChartDate",
                            contentType: "application/json;charset=utf-8",
                            type: "POST"
                        },
                        parameterMap: function (data, operation) {
                            var startdate = $("#chartstart").val();
                            var enddate = $("#chartend").val();
                            if (!startdate) {
                                startdate = thisMonday(new Date());
                            }
                            if (!enddate) {
                                enddate = thisSunday(new Date());
                            }
                            return JSON.stringify({ start: startdate, end:enddate })
                        }
                    },
                    group: [
                        { field: "r_type" },
                        { field: "r_dept" },
                    ],
                    schema: {
                        data: "d",
                        model: {
                            fields: {
                                num: { type: "number" },
                                r_dept: { type: "string" },
                                r_type: { type: "string" }
                            }
                        }
                    }
                },
                series: [{
                    type: "bubble",
                    minSize: 0,
                    maxSize: 70,
                    xField: "r_dept",
                    yField: "r_type",
                    sizeField: "num"
                }],
                xAxis: {
                    labels: { format: "{0:N0}" },
                    title: {
                        text:"Dept"
                    }
                },
                yAxis: {
                    labels: { format: "{0:N0}" },
                    title: {
                        text:"Type"
                    }
                },
                tooltip: {
                    visible: true,
                    format:"{3}:Number {2:N0}"
                }
            })
            function startChange() {
                var startDate = start.value(),
                endDate = end.value();

                if (startDate) {
                    startDate = new Date(startDate);
                    startDate.setDate(startDate.getDate());
                    end.min(startDate);
                } else if (endDate) {
                    start.max(new Date(endDate));
                } else {
                    endDate = new Date();
                    start.max(endDate);
                    end.min(endDate);
                }
            }

            function endChange() {
                var endDate = end.value(),
                startDate = start.value();

                if (endDate) {
                    endDate = new Date(endDate);
                    endDate.setDate(endDate.getDate());
                    start.max(endDate);
                } else if (startDate) {
                    end.min(new Date(startDate));
                } else {
                    endDate = new Date();
                    start.max(endDate);
                    end.min(endDate);
                }
            }

            var start = $("#chartstart").kendoDatePicker({
                change: startChange, format: "yyyy-MM-dd"
            }).data("kendoDatePicker");

            var end = $("#chartend").kendoDatePicker({
                change: endChange, format: "yyyy-MM-dd"
            }).data("kendoDatePicker");
            start.value(thisMonday(new Date()));
            end.value(thisSunday(new Date()));
            start.max(end.value());
            end.min(start.value());
            //$("#chartstart,#chartend").kendoDatePicker({ format: "yyyy-MM-dd" });
            $(document).on("click", ".k-grid-chart", OpenChart);
            var dataSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "../mc.asmx/mcquery",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        if (operation == "create") {
                            return JSON.stringify({
                                mcs: data
                            })
                        } else if (operation == "update") {
                            return JSON.stringify({
                                mcs: data
                            })
                        }
                    }
                },
                batch: false,
                pageSize: 30,
                schema: {
                    data: "d",
                    total: function (data) {
                        return data.d.length
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
                            r_reason: {
                                editable: true
                            },
                            r_type: {
                                editable: true,
                                type: "string",
                                validation: {
                                    required: true
                                },
                                defaultValue: ""
                            },
                            r_dept: {
                                editable: true,
                                type: "string",
                                validation: {
                                    customRule1: function (input) {
                                        if (input.is("[name=r_dept]") || input.is("[name=r_type]")) {
                                            return $.trim(input.val()) !== "";
                                        }
                                        return true;
                                    }
                                },
                                defaultValue: ""
                            },
                            r_inputer: {
                                editable: false
                            },
                            r_inputdate: {
                                editable: false,
                                type: "date",
                                nullable: true
                            },
                            r_updateby: {
                                editable: false
                            },
                            r_updated: {
                                editable: false,
                                type: "date",
                                nullable: true
                            }
                        }
                    }
                }
            });
            $("#mcinput").kendoGrid({
                dataSource: dataSource,
                navigateable: true,
                toolbar: [{
                    template: kendo.template($("#search-box").html())
                },
		{
		    template: "<a id='refresh' class='k-button k-button-icontext'>Refresh</a>"
		},
                { name: "chart", text: "Chart", click: function () { alert("aaa")} }],
                editable: false,
				pageable: {
                    pageSize: 30
                },
                columns: [{
                    field: "batch_no",
                    title: "Batch NO",
                    width: "100px"
                },
		{
		    field: "r_type",
		    title: "Type",
		    width: "220px"
		},
        {
            field: "r_dept",
            title: "Department",
            width: "120px"
        },
		{
		    field: "r_inputer",
		    title: "Add by",
		    width: "100px"
		},
		{
		    field: "r_inputdate",
		    title: "Added",
		    width: "140px",
		    format: "{0: yyyy-MM-dd HH:mm}"
		},
        {
            field: "r_updateby",
            title: "Update By",
            width: "100px"
        },
        {
            field: "r_updated",
            title: "Updated",
            width: "140px",
            format: "{0: yyyy-MM-dd HH:mm}"
        },
		{
		    field: "r_reason",
		    title: "Reason"
		}]
            });
            $("#searchbox").keyup(function () {
                var keyword = this.value;
                dataSource.filter({
                    filters: [{
                        field: "batch_no",
                        operator: "contains",
                        value: keyword
                    }]
                })
            });
            $("#refresh").click(function () {
                dataSource.read()
            })
        })
        function OpenChart() {
            $("#chartwindow").data("kendoWindow").open();
        }
        function thisMonday(day) {
            if (day.getDay() == 1) {
                return day;
            } else {
                day.setDate(day.getDate() - day.getDay() + 1);
                return day;
            }
        }
        function thisSunday(day) {
            if (day.getDay() == 0) {
                return day;
            } else {
                day.setDate(day.getDate() - day.getDay() + 7);
                return day;
            }
        }
    </script>
    <script type="text/x-kendo-template" id="search-box">
        <div class="toolbar">
            <label class="search-label" for="searchbox">Search Batch No:</label>
            <input type="search" id="searchbox" style="width:230px"></input>
        </div> 
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <div id="mcinput"></div>
        <div id="chartwindow">
            <div id="chartoptions">
                <input id="chartstart"/>
                <input id="chartend" />
            </div>
            <div id="chartpanel"></div>
        </div>
    </div>
    </form>
</body>
</html>
