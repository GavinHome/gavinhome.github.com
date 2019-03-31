---
title: SharePoint基于表单身份验证的自定义登录页

tags:
- SharePoint
- 身份验证
- 自定义登录

categories:
- SharePoint

date: 2018-09-28
cover: /img/cover/turned-on-MacBook-Pro.jpeg
author: 
  nick: gavinhome
  link: https://www.github.com/gavinhome
subtitle: 许多应用需要基于表单身份的认证，而不是经典模式认证。基于表单的身份验证（FBA）是一种基于声明的身份验证。SharePoint 2016中的FBA默认登录页面非常简单，只提供了用户名、密码和记住ME选项的简单登录控件。但是许多开发人员希望根据业务需求实现一个定制的登录页面以获得更好的体验或更多的选择。本文仅演示如何创建自定义登录页，并部署到Sharepoint服务器场中运行起来。
---

## 使用场景

许多应用需要基于表单身份的认证，而不是经典模式认证。基于表单的身份验证（FBA）是一种基于声明的身份验证。SharePoint 2016中的FBA默认登录页面非常简单，只提供了用户名、密码和记住ME选项的简单登录控件。但是许多开发人员希望根据业务需求实现一个定制的登录页面以获得更好的体验或更多的选择。本文仅演示如何创建自定义登录页，并部署到Sharepoint服务器场中运行起来。


## 实现步骤

1. 创建Sharepoint项目
2. 创建自定义登录页
3. 修改自定义登录页
4. 修改登录逻辑
5. 生成并部署自定义登录
5. 配置应用程序的登录页

## 创建Sharepoint项目

若未安装sharepoint开发环境，请重新安装VS并添加Sharepoint开发包。在VS2017中创建类型为"Empty SharePoint Project"的解决方案，如下图所示：
![Image text](/img/static/2018-09-28/sp007.png)

输入项目名称并按“OK”，将提示使用向导来指定要部署自定义登录页的SharePoint站点，如下图所示：

![Image text](/img/static/2018-09-28/sp008.png)

需要输入web 站点URL进行验证，同时必须选择Deploy as Server Farm解决方案而不是部署为沙箱解决方案（默认选择）。否则，在部署解决方案时会出错，如下图所示：

![Image text](/img/static/2018-09-28/sp009.png)


最后，在验证站点URL之后，点击完成。

## 创建自定义登录页

右键项目，添加新项，选择如下图所示：
![Image text](/img/static/2018-09-28/sp010.png)

输入登录页面名称后，会自动生成代码。

## 修改自定义登录页

修改登录页，添加用户名和密码的文本框，以及登录按钮，并添加登录方法btnLogin_Click，参考代码如下：

```XML
    <SharePoint:EncodedLiteral runat="server" text="" EncodeMethod='HtmlEncode'/>
 <asp:login id="loginFormsUser" FailureText="" runat="server" width="100%">
        <table class="ms-input">
          <colgroup>
          <col width="25%" />
          <col width="75%" />
          </colgroup>
        <tr>
            <td nowrap="nowrap"><SharePoint:EncodedLiteral runat="server" text="" EncodeMethod='HtmlEncode'/></td>
            <td></td>
        </tr>
        <tr>
            <td nowrap="nowrap"><SharePoint:EncodedLiteral runat="server" text="" EncodeMethod='HtmlEncode'/></td>
            <td></td>
        </tr>
        <tr>
            <td colspan="2" align="right"><asp:button id="login" OnClick="btnLogin_Click" class="loginClass" text="" runat="server" /></td>
        </tr>
        </table>
```

修改后运行，结果如下图：
![Image text](/img/static/2018-09-28/sp011.png)

## 修改登录

1. 修改默认继承类（LayoutsPageBase）为System.Web.UI.Page
2. 实现登录方法btnLogin_Click，登录方法中调用SetFBACookie，将由FBA提供程序自动验证用户身份，并设置Session Token，代码如下：

```CS
    protected void btnLogin_Click(object sender, EventArgs e)
    {
        var username = this.loginFormsUser.FindControl("UserName") as TextBox;
        var password = this.loginFormsUser.FindControl("password") as TextBox;

        if (string.IsNullOrEmpty(username.Text))
        {
            var error = this.loginFormsUser.FindControl("FailureText") as Label;
            error.Text = "请输入用户名";
            return;
        }
        else
        {
            if (string.IsNullOrEmpty(password.Text))
            {
                var error = this.loginFormsUser.FindControl("FailureText") as Label;
                error.Text = "请输入密码";
                return;
            }
        }

        try
        {
            SetFBACookie(HttpContext.Current.Request, username.Text, password.Text);
            var returnUrl = Request["ReturnUrl"];
            Response.Redirect(returnUrl);
        }
        catch (Exception ex)
        {
            var label = this.loginFormsUser.FindControl("FailureText") as Label;
            label.Text = ex.ToString();
        }
    }

    private static void SetFBACookie(HttpRequest r, string username, string cookieValue)
    {
        using (SPSite s = new SPSite(r.Url.AbsoluteUri))
        {
            SPIisSettings iis = s.WebApplication.IisSettings[SPUrlZone.Default];
            SPFormsAuthenticationProvider fap = iis.FormsClaimsAuthenticationProvider;
            SecurityToken token = SPSecurityContext.SecurityTokenForFormsAuthentication(new Uri(r.Url.GetComponents(UriComponents.Scheme | UriComponents.HostAndPort, UriFormat.Unescaped), UriKind.Absolute), fap.MembershipProvider, fap.RoleProvider, username, cookieValue, SPFormsAuthenticationOption.PersistentSignInRequest);
            SPFederationAuthenticationModule fam = SPFederationAuthenticationModule.Current;
            fam.SetPrincipalAndWriteSessionToken(token);
        }
    }
```

验证成功后，将自动跳转到首页。

## 生成并部署

右键项目生成dll, 然后点击部署，将自定义登录部署到相应目录下。在sharepoint 2016 中，登录页将会被部署到目录“Program Files\Common Files\microsoft shared\Web Server Extensions\16\TEMPLATE\LAYOUTS”下：
![Image text](/img/static/2018-09-28/sp012.png)

## 配置应用程序的登录页

在管理中心处修改应用程序的身份验证，将登录页由默认修改为自定义登录页：
![Image text](/img/static/2018-09-28/sp013.png)

文件的具体目录参考上一步部署的相对路径。

## 测试

浏览器中打开Web Application站点，输入用户名和密码，如下图所示：
![Image text](/img/static/2018-09-28/sp014.png)

点击登录后进入Web Application站点的主页，如下图所示：
![Image text](/img/static/2018-09-28/sp006.jpg)

## 参考资料

https://www.mssqltips.com/sqlservertip/3873/creating-and-deploying-a-custom-login-page-for-sharepoint-2010-forms-based-authentication/
