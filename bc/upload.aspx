<%@ Page Language="C#" AutoEventWireup="true" CodeFile="upload.aspx.cs" Inherits="bc_upload" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>批量上传生产单</title>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/kendo.web.min.js" type="text/javascript"></script>    
    <link href="../css/styles/kendo.common.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/styles/kendo.bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../css/bcbackground.css" rel="stylesheet" type="text/css" />
    <script>
        $(function () {
            $("#ClearGrid").bind("click", ClearGrid).hide();
            $("#SubmitToSQL").bind("click", SubmitData).hide();
            $("#files").kendoUpload({
                async: {
                    saveUrl: "save.ashx",
                    removeUrl: "remove.ashx",
                    autoUpload: true
                },
                multiple: false,
                showFileList: false,
                error: UploadError,
                success: onUploadSuccess
            });
        })
        function uploaddom() {
            return $("#files").data("kendoUpload");
        }
        function DisableUpload() {
            uploaddom().disable();
        }
        function EnableUpload() {
            uploaddom().enable();
        }
        function ClearGrid() {
            location.href = location.href;
        }
        function SubmitData() {
            $("#SubmitToSQL").hide();
            $("#uploading").show();
            var g = $("#importGrid").data("kendoGrid");
            var dc = g._data;
            if (g) {
                $.ajax({
                    url: "bcws.asmx/importToSql",
                    contentType: "application/json;charset=utf-8",
                    type: "POST",
                    data: JSON.stringify({ data: g._data }),
                    error: showerrormsg,
                    success: function(data) {
                        if (data.d.length > 0) {
                            $("#importGrid").empty().kendoGrid({
                                dataSource: {
                                    data: data.d,
                                    schema: {
                                        model: {
                                            fields: {
                                                batch_no: { type: "string" },
                                                item_code: { type: "string" },
                                                qty: { type: "number" },
                                                shipping_date: { type: "date" },
                                                recipe_ver: { type: "number" },
                                                history: { type: "number" },
                                                planner_comment: { type: "string" },
                                                assign_lab: { type: "string" },
                                                ul_status: { type: "string" }
                                            }
                                        }
                                    }
                                },
                                navigateable: true,
                                resizable: true,
                                editable: false,
                                columns: [
                                {
                                    field: "ul_status",
                                    title: "&nbsp;",
                                    width: "80px"
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
                                    format: "{0:yyyy-MM-dd}",
                                    width: "120px"
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
                                    field: "planner_comment",
                                    title: "OP Note"
}],
                                    dataBound: function() {
                                        $("#ClearGrid").show();
                                        $("#SubmitToSQL").hide();
                                        DisableUpload();
                                    }
                                })
                            } else {
//                                if (confirm("上传成功，是否立刻发送邮件？")) {
//                                    var dc = $("#importGrid").data("kendoGrid")._data;
//                                    for (var i in dc) {
//                                        $.ajax({
//                                            //async: false,
//                                            url: "bcws.asmx/SendMail",
//                                            contentType: "application/json;charset=utf-8",
//                                            type: "POST",
//                                            data: JSON.stringify({ batchno: dc[i].batch_no }),
//                                            success: function(data) {
//                                                if (data.d == true) {
//                                                    alert("Mail send success!");
//                                                    RefreshGrid();
//                                                } else {
//                                                    alert("Something wrong.....Please contact IT");
//                                                }
//                                            }
//                                        })
//                                    }
//                                }
                                if (confirm("是否跳转到生产单列表？")) {
                                    location.href = "op.aspx";
                                } else {
                                    window.close();
                                }
                            }
                        }
                    })
            }
        }
        function onUploadSuccess(e) {
            e.preventDefault();
            var filename = e.files[0].name;
            $("#importGrid").kendoGrid({
                dataSource: BuildData(filename),
                navigateable: true,
                resizable: true,
                editable: false,
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
                    format: "{0:yyyy-MM-dd}",
                    width: "120px"
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
                    field: "planner_comment",
                    title: "OP Note"
                }],
                dataBound: function () {
                    $("#ClearGrid").show();
                    $("#SubmitToSQL").show();
                    DisableUpload();
                }
            })
        }
        function BuildData(filename) {
            var dataSource = new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "bcws.asmx/QueryExcel",
                        contentType: "application/json;charset=utf-8",
                        type: "POST"
                    },
                    parameterMap: function (data, operation) {
                        if (operation == "read") {
                            return JSON.stringify({ filename: filename });
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
                                type: "string"
                            },
                            item_code: {
                                type: "string"
                            },
                            qty: {
                                type: "number"
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
                                type: "string"
                            }
                        }
                    }
                }
            });
            return dataSource;
        }
        function onUploadSelect(e){
            var ext=e.files[0].extension;
            if (ext != ".xls" && ext != ".xlsx") {
                alert("只能上传Excel文件");
                e.files.splice(0, 1);
            }
        }
        function UploadError(e) {
            var files = e.files;

            if (e.operation == "upload") {
                alert("Failed to upload " + files[0].name);
            }
        }
        function showerrormsg(e) {
            alert(JSON.parse(e.responseText).Message);
            RefreshGrid();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="commandbar">
        <div style="width:200px;float:left">
            <input name="files" id="files" type="file"  autocomplete="off" multiple="multiple" data-role="upload"/>
        </div>
        <a href="batch-template.xls">下载模板</a>  
        <a id="ClearGrid" class="k-button">Clear</a>
        <a id="SubmitToSQL" class="k-button">Submit</a>
        <span id="uploading" style="display:none">上传中...</span>
    </div>
    <div id="importGrid"></div>
    </form>
</body>
</html>
