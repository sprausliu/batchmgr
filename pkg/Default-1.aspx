<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default-1.aspx.cs" Inherits="pkg_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>包材领用登记</title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.web.min.js" type="text/javascript"></script>    
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/bcbackgroundop.css" rel="stylesheet" type="text/css" />
    <style>
        .k-window {
            background:#f5f5f5
        }
        .k-content {
            background-color:transparent;
        }
        #IW h3 {
            font-size: 2.5em;
            color: #787878;
            border-bottom: 1px solid #ccc;
        }

        #IW {
            float: left;
            clear: left;
            width: 390px;
            margin: 30px 0 30px 30px;
            padding: 60px 0 30px 30px;            
        }

        #IW ul {
        	list-style: none;
            margin: 0;
            padding: 0;
        }

        #IW li {
        	height: 28px;
        	vertical-align: middle;
        	color: #000;
        }

        #IW ul label {
        	display: inline-block;
        	width: 50px;
        	text-align: right;
        	padding-right: 5px;
        	color: #000;
        }

        #IW label {
        	color: #000;
        }

        #IW ul input {
        	border: 1px solid #ddd;
        }

        #IW button {
        	float: right;
        	margin-right: 85px;
        }
    </style>
    <script>
        var filterobj = {
            extra: false,
            messages: {
                selectValue: "选择",
                info: "条件",
                filter: "筛选",
                clear: "显示全部"
            }
        };
        var page = {nrws:false};
        var ss = [{ value: -1, text: "取消" }, { value: 1, text: "已提交" }, { value: 2, text: "等待送货" }, { value: 3, text: "已确认" }];
        //var categorys = [{value:0,text:" "},{ value: 1, text: "桶1" }, { value: 2, text: "桶2" }, { value: 3, text: "桶3" }, { value: 4, text: "桶4" }];
        var reasons = [{value:0,text:" "},{ value: 1, text: "1.原因1" }, { value: 2, text: "2.原因2" }, { value: 3, text: "3.原因3" }, { value: 4, text: "4.原因4" }];
        var nr = kendo.observable({
            u_batch: "",
            u_reason: "",
            reasons: ["","原因1", "原因2", "原因3"],
            categories: ["","桶型1", "桶型2", "桶型3"],
            u_pkg_category: "",
            u_num: "",
            validated: false,
            va: function (e) {
                this.set("validated", e);
            },
            init: function () {
                this.set("u_batch","");
                this.set("u_reason","");
                this.set("u_pkg_category","");
                this.set("u_num", "");
            }
        })
        $(function () {
            $(document).keydown(function (event) {
                //console.log(event.keyCode);
                //添加全局快捷键
                if (event.keyCode == 120) { //F9
                    //pkg.addRow();
                    OpenInputDialog();
                } else if (event.keyCode == 27) { //ESC
                    w = $("#IW").data("kendoWindow").close();
                } else if (event.ctrlKey && event.keyCode == 83) { //ctrl+s
                    //event.preventDefault();
                    //pkg.saveChanges();
                } else if (event.ctrlKey && event.keyCode == 90) { //ctrl+z
                    //event.preventDefault();
                    //pkg.cancelChanges();
                } else if (event.ctrlKey==false && event.keyCode == 116) { //仅F5，不包括组合键
                    event.preventDefault();
                    pkg.dataSource.read();
                } else if (event.keyCode == 13) { //Enter                    
                    if (page.nrws) {
                        event.preventDefault();
                        $("#IW input").trigger("change");
                        $("#IB").trigger("click");
                    }
                }
            });
            InitIW();
            InitValidator();
            kendo.bind("#IW", nr);
            var pkg = $("#pkg").kendoGrid({
                dataSource: pkgds(),
                navigatable: false,
                resizable: true,
                toolbar: [{ name: "Input" }, { name: "Refresh" }],
                editable: "inline",
                pageable: {
                    pageSize: 30
                },
                //selectable:"cell",
                width: 800,
                filterable: filterobj,
                save: function (e) {
                    e.sender.dataSource.read();
                },
                columns: [
                    {
                        field: "u_id",
                        title: "Line NO",
                        width: 90
                    }, {
                        field: "u_cell",
                        title: "Cell",
                        width:100
                    }, {
                        field: "u_batch",
                        title: "Batch",
                        width: 100
                    }, {
                        field: "u_reason",
                        title: "Reason",
                        values:nr.reasons,
                        width: 100
                    }, {
                        field: "u_pkg_category",
                        title: "Category",
                        values:nr.categories,
                        width: 100
                    }, {
                        field: "u_num",
                        title: "Num",
                        width: 60
                    }, {
                        field: "u_user",
                        title: "Add By",
                        width:120
                    }, {
                        field: "u_added",
                        title: "Date Add",
                        format: "{0:yyyy-MM-dd HH:mm}",
                        width: 160
                    }, {
                        field: "u_status",
                        title: "Status",
                        values: ss,
                        width: 100
                    }, {
                        command: ["destroy","edit"]
                    }
                ]
            }).data("kendoGrid");
            function AddRow(e) {
                //console.log("dataBound");
                pkg.addRow();
            }
            $(document).on("blur", "#IG [name='u_batch']", function (e) {
                e.target.value = e.target.value.toUpperCase()
            }).on("keydown", "#IG [name='u_num']", function (e) {
                if (e.keyCode == 9) {
                    e.preventDefault();
                    $(e.target).trigger("blur");
                    $("#IG").data("kendoGrid")
                }
            }).on("click", "#IB", function (e) {
                if ($("#IW").data("kendoValidator").validate()) {
                    $.ajax({
                        url: "package.asmx/AddNewRC",
                        dataType: "JSON",
                        contentType: "application/json;charset=utf-8",
                        data: JSON.stringify({ pu: nr }),
                        error: jqaShowErr,
                        type:"POST",
                        success: function (data) {
                            if (confirm("提交成功，是否继续添加？")) {
                                nr.init();
                                RefreshGrid();
                                $("#nb").focus();
                            } else {
                                $("#IW").data("kendoWindow").close();
                            }
                        }
                    })
                }
            }).on("click", ".k-grid-Input", function () {
                OpenInputDialog();
            }).on("click", ".k-grid-Refresh", function () {
                RefreshGrid();
            })
        })
        function dataBound() {
            console.log("dataBound");
        }
        function RefreshGrid() {
            $("#pkg").data("kendoGrid").dataSource.read();
        }
        function pkgds() {
            return new kendo.data.DataSource({
                transport: {
                    read: kendoDSTransportBody("package.asmx/GetUsingRC"),
                    //create: kendoDSTransportBody("package.asmx/AddNewRC"),
                    update: kendoDSTransportBody("package.asmx/UpdateRC"),
                    destroy: kendoDSTransportBody("package.asmx/DelRC"),
                    parameterMap: function (data, operation) {
                        if (operation == "read") {
                            return JSON.stringify({ take: 500 })
                        } else {
                            return JSON.stringify({ pus: data.models })
                        }
                    }
                },
                //requestEnd: function (e) {
                //    e.sender.read();
                //},
                error: ShowErr,
                batch: true,
                pageSize: 30,
                schema: {
                    data: "d",
                    total: function (data) {
                        return data.d.length;
                    },
                    model: {
                        id: "u_id",
                        fields: {
                            u_id: { editable: false, defaultValue: 0 },
                            u_cell: { type: "string", editable: false },
                            u_reason: {
                                type: "string",
                                validation: {
                                    bor: function (input) {
                                        if (input.is("[name='u_reason']") || input.is("[name='u_batch']")) {
                                            input.attr("data-bor-msg", "批号/原因 二选一必填");
                                            return $("[name='u_reason']").val() != "" || $("[name='u_batch']").val() != "";
                                        }
                                        return true;
                                    }
                                }
                            },
                            u_batch: { type: "string" },
                            u_pkg_category: {
                                type: "string",
                                validation: {
                                    categoryvalidation: function (input) {
                                        if (input.is("[name='u_pkg_category']")) {
                                            input.attr("data-categoryvalidation-msg", "请选择桶型");
                                            return input.val() != 0;
                                        }
                                        return true;
                                    }
                                }
                            },
                            u_num: {
                                validation: {
                                    required:true,
                                    numvalidation: function (input) {
                                        if (input.is("[name='u_num']") && input.val() != "") {
                                            input.attr("data-numvalidation-msg", "桶数量必须为正整数");
                                            return /^[0-9]*[1-9][0-9]*$/.test(input.val());
                                        }
                                        return true;
                                    }
                                }
                            },                                
                            u_user: { type: "string", editable: false },
                            u_added: { type: "date",editable:false },
                            u_modifyby: { type: "string" },
                            u_modified: { type: "date" },
                            u_status: { type: "number", editable: false, defaultValue: 1 },
                            u_mailtimes: {type:"number",defaultValue:0}
                        }
                    }
                }
            })
        }
        function InitIW() {
            var wo = {
                width: "420px",
                height: "270px",
                title: "申请包装桶",
                visible: false,
                modal: true,
                open: open,
                animation: false,
                close: close,
                activate: active
            };
            function open(e) {
                page.nrws = true;
                //BuildIG();
            }
            function close() {
                page.nrws = false;
                RefreshGrid();
            }
            function active() {
                $("#nb").focus();                
            }
            return $("#IW").kendoWindow(wo).css("padding", 0).data("kendoWindow").center()
        }
        function OpenInputDialog(rebuild) {
            var w = $("#IW").data("kendoWindow");
            if (!w || rebuild) {           
                w = InitIW();
            }
            if (page.nrws==true) {
                w.close();
            } else {
                w.open();
            };
        }
        function InitValidator() {
            $("#IW").kendoValidator({
                messages: {
                    //bor: "批号/原因 二选一必填",
                    required: function (input) {
                        return input.data("lang-name") + "为必填项";
                    }
                    //int:"数量必须为正整数"
                },
                rules: {
                    bor: function (input) {
                        if (input.is("#nb") || input.is("#ncau")) {
                            return $("#nb").val()!=""||$("#ncau").val()!=""
                        }
                        return true;
                    },
                    int: function (input) {
                        if (input.is("#nn")) {
                            return /^[0-9]*[1-9][0-9]*$/.test(input.val());
                        }
                        return true;
                    }
                },
                validate: function (e) {
                    nr.va(e.valid);
                }
            })
        }
        ///可复用函数///
        //取Url参数
        function GetQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }
        //构建kendo DataSource中的Transport元素
        function kendoDSTransportBody(url) {
            return { url: url, contentType: "application/json;charset=utf-8", type: "POST" };
        }
        function ShowErr(e) {
            alert(JSON.parse(e.xhr.responseText).Message);
        }
        function jqaShowErr(e) {
            alert(JSON.parse(e.responseText).Message)
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div id="pkg">
    
    </div>
    <div id="IW">
        <ul>
            <li><label for="nb">批次：</label><input id="nb" data-bind="value: u_batch" data-bor-msg="批号/原因 二选一必填" /></li>
            <li><label for="ncau">原因：</label><select id="ncau" data-bind="source: reasons, value: u_reason "  data-bor-msg="批号/原因 二选一必填"></select></li>
            <li><label for="ncat">类型：</label><select id="ncat" data-lang-name="包装桶类型" data-bind="source: categories, value: u_pkg_category " required="required" ></select></li>
            <li><label for="nn">数量：</label><input id="nn" data-lang-name="数量" data-bind="value:u_num" required="required" data-int-msg="数量必须为正整数"/></li>
        </ul>
        <br /><br />
        <button id="IB" style="display: block">保存</button>
    </div>
    </form>
</body>
</html>
