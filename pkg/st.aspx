<%@ Page Title="" Language="C#" MasterPageFile="~/pkg/pkgmast.master" AutoEventWireup="true" CodeFile="st.aspx.cs" Inherits="pkg_st" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <title>打印包装桶送货单</title>
    <style media="all">
        table {
            border-collapse: collapse;
            border: 1px solid #aaa;
            width: 100%;
        }
        th {
            vertical-align: baseline;
            padding: 5px 15px 5px 5px;
            background-color: #d5d5d5;
            border: 1px solid #aaa;
            text-align: left;
        }
        td {
            vertical-align: text-top;
            padding: 5px 15px 5px 5px;
            background-color: #ffffff;
            border: 1px solid #aaa;
        }
        #h {
            margin-bottom:20px;
        }
        #lns {
            display:none;
        }
        #lsqr{
            position:absolute;
        }
        .h1 {
            font-size:2em;
        }
        .v-h {
            text-align:center;
        }
    </style>
    <style media="print">
        .printbtn{display:none}
    </style>
    <script>
        $(function () {
            $("#lsqr").kendoQRCode({
                value: $(".lns").text(),
                size: 100,
                background: "transparent"
            })
        })
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="v-h"><input class="printbtn" name="" type="button" value="打印" onclick="javascript: window.print();" /></div>

    <table id="h">
        <asp:Label ID="lns"  Style="display:none" CssClass="lns" runat="server" Text="Label"></asp:Label>
        <tbody>
            <tr>
                <th colspan="2"><span class="h1">包装桶送货单-<asp:Label ID="bn" runat="server" Text="Label"></asp:Label></span></th>
                <td rowspan="3" style=" width: 2.4cm; height: 2.7cm; "><div id="lsqr"></div></td>
            </tr>
            <tr>
                <td><span>Building：<asp:Label ID="bns" runat="server" Text="Label"></asp:Label></span></td>
                <td><span>数量总计：<asp:Label ID="cnttotal" runat="server" Text="Label"></asp:Label></span></td>
            </tr>
            <tr>
                <td><span>打印日期：<asp:Label ID="now" runat="server" Text="Label"></asp:Label></span></td>
                <td></td>
            </tr>
        </tbody>
    </table>
    <table id="b">
        <tbody>
            <tr>
                <th><span>行号</span></th>
                <th><span>批号</span></th>
                <th><span>Cell</span></th>
                <th><span>申请人</span></th>
                <th><span>包装桶类型</span></th>
                <th><span>数量</span></th>
                <th><span>确认</span></th>
            </tr>
            <asp:Repeater runat="server" ID="ls">
                <ItemTemplate>
                    <tr>
                        <td><span><%#Eval("u_id") %></span></td>
                        <td><span><%#Eval("u_batch") %></span></td>
                        <td><span><%#Eval("cell_name") %></span></td>
                        <td><span><%#Eval("u_user") %></span></td>
                        <td><span><%#Eval("u_pkg_category") %></span></td>
                        <td><span><%#Eval("u_num") %></span></td>
                        <td><span></span></td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>
</asp:Content>

