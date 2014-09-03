<%@ Page Language="C#" AutoEventWireup="true" CodeFile="input.aspx.cs" Inherits="mc_input" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>手工结单批次录入</title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.web.min.js" type="text/javascript"></script>    
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.moonlight.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/background.css" rel="stylesheet" type="text/css" />
    <script>
        $(function () {
            var dataSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "../mc.asmx/mcquery",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    create: {
                        url: "../mc.asmx/mcinput",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    update: {
                        url: "../mc.asmx/mcupdate",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        if (operation == "create") {
                            return JSON.stringify({
                                mcs: data
                            });
                        } else if (operation == "update") {
                            return JSON.stringify({
                                mcs: data
                            });
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
                            r_operator: {
                                editable: true,
                                type: "string",
                                nullable:true
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
                toolbar: ["create", {
                    template: kendo.template($("#search-box").html())
                },
		{
		    template: "<a id='refresh' class='k-button k-button-icontext'>Refresh</a>"
		}],
                editable: "popup",
                edit: function (e) {
                    e.container.find(".k-edit-form-container>div").filter(function (index) { return index >= 8 && index <= 15 }).hide();
                    if (e.model.isNew()) {
                        e.container.find("input[name=batch_no]").bind("blur", function () {
                            var bn = $(this).val();
                            if (checkbn(bn)) {
                                alert("批号已存在");
                                e.container.find("a.k-grid-cancel").click();
                                $("#searchbox").val(bn).keyup();
                            }
                        })
                    } else {
                        e.container.find("input[name=batch_no]").attr("disabled", "disabled");
                    }
                    e.container.data("kendoWindow").bind("close",
			function () { })
                },
                pageable: {
                    pageSize: 30
                },
                columns: [
        { command: ["edit"], title: "&nbsp;", width: "100px" }, {
            field: "batch_no",
            title: "Batch NO",
            width: "100px"
        },
		{
		    field: "r_type",
		    title: "Type",
		    width: "220px",
		    editor: function (container, option) {
		        var input = $("<input />");
		        input.attr("name", option.field).css("width","21em").appendTo(container).kendoDropDownList({
		            optionLable: "",
		            autoBind: true,
		            dataSource: ["", "扫完500但系统显示未完成", "产率异常", "生产单变更信息未在Oracle及时录入", "无效配方", "BV物料item信息与实物不一致", "BV物料批号信息与实物不一致", "物料库位转移不及时BV中断", "系统变更未及时关闭系统导致BV中断", "非计划系统维护BV中断", "计划内系统维护BV中断", "生产中途短料导致BV中断", "其它"],
		            value: option.field
		        })
		    }
		},
        {
            field: "r_dept",
            title: "Department",
            width: "120px",
            editor: function (container, option) {
                var input = $("<input />");
                input.attr("name", option.field).appendTo(container).kendoDropDownList({
                    optionLabel: "",
                    autoBind: true,
                    dataSource: ["", "Auto PD", "ED PD", "HDE PD", "IC PD", "IT", "WB PD", "Wood PD", "仓库", "工业漆- QC ", "技术-APA", "技术-CE", "技术-CV", "技术-GI", "技术-GIT", "技术-HDE", "技术-IF", "技术-OEM", "技术-Wheel", "技术-Wood", "汽车漆-QC", "水漆-QC"],
                    value: option.field
                })
            }
        },
        {
            field: "r_operator",
            title: "登记员工",
            width: "100px"
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
		    title: "Reason",
		    //width:"700px",
		    editor: function (container, option) {
		        var textbox = $("<textarea></textarea>").addClass("k-input").addClass("k-textbox").css({
		            height: "150px",
		            width: "250px"
		        });
		        textbox.attr("name", option.field);
		        textbox.appendTo(container);
		    }
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
                });
            });
            $("#refresh").click(function () {
                dataSource.read();
            })
        })
        function checkbn(batchno) {
            if (batchno != "") {
                var a;
                $.ajax({
                    type: "POST",
                    url: "../mc.asmx/CheckBatch",
                    async: false,
                    contentType: "application/json;charset=utf-8", data: "{batchno:'" + batchno + "'}",
                    success: function (data) {
                        a = data.d
                    }
                });
                return a;
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
    </div>
    </form>
</body>
</html>
