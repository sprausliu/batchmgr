<%@ Page Language="C#" AutoEventWireup="true" CodeFile="resetpwd.aspx.cs" Inherits="ecoasign_resetpwd" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>ECOA重置密码</title>
    <script>
        function CheckPWD() {
            var p1 = document.getElementById("newpwd").value;
            var p2 = document.getElementById("recheckpwd").value;
            if (p1 == p2) {
                return true;
            } else {
                alert("密码不符");
                return false;
            }
        }
    </script>
    <style>
        * {
            margin: 0;
            padding: 0;
            font-family: "微软雅黑","宋体";
            font-size: 14px;
        }#resetpwd .rowhead{
display: inline-block;
width: 100px;
text-align: right;
margin: 0px 5px 0 0;
font-weight: bold;
}#resetpwd div {
padding: 5px 0;
}#submitreset {
margin: 0 30px;
width: 230px;
height: 30px;
}
#resetpwd {
padding-top: 50px;
padding-bottom: 10px;
box-shadow: black 2px 2px 10px;
width: 300px;
margin: 20px;
background: url("background.png");
color: white;
}
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Panel runat="server" ID="invalid" Visible="false">
            <span>链接已失效。</span>
        </asp:Panel>
        <asp:Panel runat="server" ID="expired" Visible="false">
            <center>
                <span>链接已过期。</span>
            </center>
        </asp:Panel>
        <asp:Panel runat="server" ID="resetpwd" Visible="false">
            <div>
                <span class="rowhead">用户名:</span>
                <asp:Label runat="server" ID="username" ></asp:Label>
            </div>
            <div>
                <span class="rowhead">新密码:</span>
                
                <asp:TextBox runat="server" ID="newpwd" TextMode="Password"></asp:TextBox>
            </div>
            <div>
                <span class="rowhead">验证新密码:</span>
                <asp:TextBox runat="server" ID="recheckpwd" TextMode="Password"></asp:TextBox>
            </div>
            <div>
                <asp:Button runat="server" ID="submitreset" Text="提交" OnClick="submitreset_Click"  OnClientClick="return CheckPWD()" />
            </div>
        </asp:Panel>
    </div>
    </form>
</body>
</html>
