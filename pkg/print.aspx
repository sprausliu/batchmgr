<%@ Page Title="" Language="C#" MasterPageFile="~/pkg/pkgmast.master" AutoEventWireup="true" CodeFile="print.aspx.cs" Inherits="pkg_print" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <title>包装桶需求</title>
    <script src="../js/rui.js"></script>
    <script>
        var bw;
        $(function () {
            bw=$("#bw").kendoWindow({
                visible: false,
                title: "需求清单",
                position: {
                    top: 90,
                    left: 400
                },
                width: 1000,
                height: 600,
                resizable: false,
                actions: ["Close"],
                modal: true,
                draggable:false
            }).data("kendoWindow");
            $(".building").bind("click",bwopen)
        })
        function bwopen(e) {
            var b = $(e.target).closest(".building").data("building");
            var g = $("#wg").kendoGrid({
                dataSource: baseDS(b),
                editable: false,
                columns: [
                    {
                        field: "u_id",
                        title: "行号",
                        width: 90
                    }, {
                        field: "u_batch",
                        title: "批次",
                        width: 100
                    }, {
                        field: "cell_name",
                        title: "CELL",
                        width:100
                    }, {
                        field: "u_pkg_category",
                        title: "桶型",
                        width:100
                    }, {
                        field: "u_num",
                        title: "数量",
                        aggregates: ["sum"]

                    }
                ]
            })
            //var c = $("<div>").append(g);
            $(".wab-print").unbind().click(function () {
                window.open("st.aspx?building=" + b, "_blank", ",toolbar=no,menubar=no,location=no, status=no,height=450,width=600").print();
            })
            bw.title(b+"需求清单").open();
        }
        
        function baseDS(b) {
            return new kendo.data.DataSource({
                transport: {
                    read: kendoDSTransportBody("package.asmx/pkglistByBuilding"),
                    parameterMap: function (data, operation) {
                        return JSON.stringify({ building: b });
                    }
                },
                group: {
                    field: "u_pkg_category",
                    aggregates: [{ field: "u_num", aggregate: "sum" }]
                },
                error: ShowErr,
                batch: true,
                pageSize: 10,
                schema: {
                    data: "d",
                    total: function (data) {
                        return data.d.length;
                    },
                    model: {
                        id: "u_id",
                        fields: {
                            u_id: {},
                            u_batch: {},
                            cell_name: {},
                            u_pkg_category: {},
                            u_num: {}
                        }
                    }
                }
            });
        }
    </script>
    <style >        
    .building {
float: left;
height: 200px;
margin: 10px 0 0 20px;
position: relative;
width: 350px;
background: url("building.png") no-repeat;
border-radius: 14px;
box-shadow: #333 1px 1px 8px -2px;
cursor:pointer;
}
        .building:hover {
            background-position:0 -200px;
        }
.b-name {
display: block;
font-size: 3em;
text-align: center;
height: 47px;
line-height:47px;
width: auto;
color: white;
}
.b-total {
    /*font-size: 0.5em;*/
}.cnts {
    height: 130px;
    overflow: hidden;
    padding: 10px 30px 0 10px;
}
        .cntu {
        white-space: nowrap;
text-overflow: ellipsis;
        }
 .cnti {
width: 140px;
float: left;
}.cnti strong {
    display: inline-block;
    text-align: right;
    width: 100px;
}
        .clear {
        clear:both;
        }.window-actionbar {
padding: 10px 0;
text-align: center;
}
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div id="m">
        <div id="buildings">
            <div id="b-auto" class="building" data-building="Auto">
                <a class="b-name">AUTO<asp:Label ID="autototal" runat="server"  CssClass="b-total"></asp:Label></a>                
                <div class="cnts">                    
                    <asp:Repeater runat="server" ID="autocntu">
                        <HeaderTemplate>
                            <ul class="cntu">
                        </HeaderTemplate>
                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                        <ItemTemplate>
                            <li class="cnti"><strong><%#Eval("cate") %>:</strong><%#Eval("tt") %></li>
                        </ItemTemplate>
                    </asp:Repeater>                               
                    <div class="clear"></div>
                </div>
            </div>
            <div id="b-ic" class="building" data-building="IC">
                <a class="b-name">CE/IF<asp:Label ID="ictotal" runat="server"  CssClass="b-total"></asp:Label></a>
                
                <div class="cnts">
                    <asp:Repeater runat="server" ID="iccntu">
                        <HeaderTemplate>
                            <ul class="cntu">
                        </HeaderTemplate>
                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                        <ItemTemplate>
                            <li class="cnti"><strong><%#Eval("cate") %>:</strong><%#Eval("tt") %></li>
                        </ItemTemplate>
                    </asp:Repeater>                               
                    <div class="clear"></div>
                </div>
            </div>
            <div id="b-ED" class="building" data-building="ED">
                <a class="b-name">E-COAT<asp:Label ID="edtotal" runat="server"  CssClass="b-total"></asp:Label></a>
                
                <div class="cnts">
                    <asp:Repeater runat="server" ID="edcntu">
                        <HeaderTemplate>
                            <ul class="cntu">
                        </HeaderTemplate>
                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                        <ItemTemplate>
                            <li class="cnti"><strong><%#Eval("cate") %>:</strong><%#Eval("tt") %></li>
                        </ItemTemplate>
                    </asp:Repeater>                               
                    <div class="clear"></div>
                </div>
            </div>
            <div id="b-hde" class="building" data-building="HDE">
                <a class="b-name">HDE<asp:Label ID="hdetotal" runat="server"  CssClass="b-total"></asp:Label></a>
                
                <div class="cnts">
                    <asp:Repeater runat="server" ID="hdecntu">
                        <HeaderTemplate>
                            <ul class="cntu">
                        </HeaderTemplate>
                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                        <ItemTemplate>
                            <li class="cnti"><strong><%#Eval("cate") %>:</strong><%#Eval("tt") %></li>
                        </ItemTemplate>
                    </asp:Repeater>                               
                    <div class="clear"></div>
                </div>
            </div>
            <div id="b-wb" class="building" data-building="WB">
                <a class="b-name">WATER<asp:Label ID="wbtotal" runat="server"  CssClass="b-total"></asp:Label></a>
                
                <div class="cnts">
                    <asp:Repeater runat="server" ID="wbcntu">
                        <HeaderTemplate>
                            <ul class="cntu">
                        </HeaderTemplate>
                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                        <ItemTemplate>
                            <li class="cnti"><strong><%#Eval("cate") %>:</strong><%#Eval("tt") %></li>
                        </ItemTemplate>
                    </asp:Repeater>                               
                    <div class="clear"></div>
                </div>
            </div>
            <div id="b-wd" class="building" data-building="WOOD">
                <a class="b-name">WOOD<asp:Label ID="wdtotal" runat="server"  CssClass="b-total"></asp:Label></a>
                
                <div class="cnts">
                    <asp:Repeater runat="server" ID="wdcntu">
                        <HeaderTemplate>
                            <ul class="cntu">
                        </HeaderTemplate>
                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                        <ItemTemplate>
                            <li class="cnti"><strong><%#Eval("cate") %>:</strong><%#Eval("tt") %></li>
                        </ItemTemplate>
                    </asp:Repeater>                               
                    <div class="clear"></div>
                </div>
            </div>
            <div class="clear"></div>
        </div>
    </div>
    <div id="bw">
        <div id="wh">
        </div>
        <div id="wg"></div>
        <div id="wf" class="window-actionbar">
            <button class="wab-print">打印</button>
        </div>
    </div>
</asp:Content>

