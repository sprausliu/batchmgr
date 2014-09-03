using System.Web;
using System.Web.UI;
/// <summary>
///UserIdentity 的摘要说明
/// </summary>
public class UserIdentity
{
    private string _username;
    private Page page;
    public string Username
    {
        get { return _username; }
    }
	public UserIdentity()
	{
        string name = HttpContext.Current.User.Identity.Name;
        this._username = name.Substring(name.IndexOf("\\") + 1);        
	}
    public void SetSession(Page p){
        page = p;
        p.Session["USERNAME"] = this._username;
    }
}