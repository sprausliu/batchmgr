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