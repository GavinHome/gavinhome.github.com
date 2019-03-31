---
title: SharePoint 2016：自定义表单认证（Forms Based Authentication）

tags:
- SharePoint
- 身份验证
- FBA

categories:
- SharePoint

date: 2018-09-28
cover: /img/cover/black-and-gray-code-padlock.jpeg
author: 
  nick: gavinhome
  link: https://www.github.com/gavinhome
subtitle: 基于表单的身份验证（FBA）是SharePoint支持的身份验证模式之一，它允许我们实现自己的身份验证机制，并帮助扩展非活动目录（AD）用户的SharePoint站点。SharePoint安装完成后，默认使用Active Directory查询用户配置文件并使用Windows身份验证对用户进行身份验证，但是FBA使用与AD一起托管的自定义数据库来存储用户凭证，在这种情况下，使用数据库查询的方式为自定义的FBA提供用户描述。当我们需要将SharePoint暴露到外部世界时，FBA变得非常重要，例如，与客户和供应商共享文档或其他。
---

由于项目的需要，登录SharePoint Application的用户将从一个统一平台中获取，而不是从Domain中获取，所以需要对SharePoint Application的身份验证（Claims Authentication Types）进行更改，即采用更加灵活的模式登录：Forms Based Authentication（FBA）。

基于表单的身份验证（FBA）是SharePoint支持的身份验证模式之一，它允许我们实现自己的身份验证机制，并帮助扩展非活动目录（AD）用户的SharePoint站点。SharePoint安装完成后，默认使用Active Directory查询用户配置文件并使用Windows身份验证对用户进行身份验证，但是FBA使用与AD一起托管的自定义数据库来存储用户凭证，在这种情况下，使用数据库查询的方式为自定义的FBA提供用户描述。当我们需要将SharePoint暴露到外部世界时，FBA变得非常重要，例如，与客户和供应商共享文档或其他。

在本文中，介绍SharePoint 2016自定义Providers在基于表单的身份验（Forms-Based-Authentication）中的应用。我们将看到使用SharePoint实现FBA所涉及的所有步骤，并且可以根据每一步的过程图描述该过程。


## 使用场景

通常需要为sharepoint打通其他的系统整合到sharepoint认证,ad通常是为内部域用户,外网访问的可以使用membership来登录,那么这个既可以内部用户访问,外部用户也可以访问 ,另外也可以把其他的用户加到membership里面。

## 实现步骤

1. 创建Membership Provider和Role Provider
2. 配置应用程序(application)、管理中心(central administration)、令牌服务程序(secure token service application)
3. 配置Web Application的身份认证
4. 配置配置应用程序的人员和角色
5. 使用人员登录测试

## 创建Membership Provider和Role Provider

启用VS2017， 选择并创建一个Class Library，创建MembershipProvider和Role Provider，分别继承System.Web.Security.MembershipProvider和System.Web.Security.RoleProvider，实现对应的方法。实现MembershipProvider和Role Provider时可采用直接读取数据库的方式，还可以使用REST方式访问公开的API获取数据。

1. 自定义MembershipProvider，主要代码如下：

```CS
    public class CustomMembershipProvider : MembershipProvider
    {
        private static readonly Uri BaseUri = new Uri(SystemConfigConst.ProviderApiBaseUrl);

        #region 重写的方法

        public override MembershipUserCollection FindUsersByName(string usernameToMatch, int pageIndex, int pageSize, out int totalRecords)
        {
            var parameters = new
            {
                PageIndex = pageIndex,
                PageSize = pageSize,
                UserName = usernameToMatch,
            };

            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Users/FindUsersByName"), parameters).ToDataSourcePagedResult<PagedResult<MemberUserInfo>>();
            totalRecords = result.Total;

            return result.ToMembershipUserCollection(this.Name);
        }

        public override MembershipUserCollection GetAllUsers(int pageIndex, int pageSize, out int totalRecords)
        {
            var parameters = new
            {
                PageIndex = pageIndex,
                PageSize = pageSize
            };

            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Users/GetAllUsers"), parameters).ToDataSourcePagedResult<PagedResult<MemberUserInfo>>();
            totalRecords = result.Total;

            return result.ToMembershipUserCollection(this.Name);
        }

        public override MembershipUser GetUser(string username, bool userIsOnline)
        {
            var parameters = new
            {
                UserName = username
            };

            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Users/GetUser"), parameters).ToDataSourcePagedResult<MemberUserInfo>();

            return result != null ? result.ToMembershipUser(this.Name) : null;
        }

        public override MembershipUser GetUser(object providerUserKey, bool userIsOnline)
        {
            var parameters = new
            {
                UserName = providerUserKey
            };

            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Users/GetUser"), parameters).ToDataSourcePagedResult<MemberUserInfo>();

            return result != null ? result.ToMembershipUser(this.Name) : null;
        }

        public override string GetUserNameByEmail(string email)
        {
            var parameters = new
            {
                Email = email
            };

            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Users/GetUserNameByEmail"), parameters).ToDataSourcePagedResult<string>();

            return result;
        }

        public override MembershipUserCollection FindUsersByEmail(string emailToMatch, int pageIndex, int pageSize, out int totalRecords)
        {
            var parameters = new
            {
                PageIndex = pageIndex,
                PageSize = pageSize,
                Email = emailToMatch,
            };

            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Users/FindUsersByEmail"), parameters).ToDataSourcePagedResult<PagedResult<MemberUserInfo>>();
            totalRecords = result.Total;

            return result.ToMembershipUserCollection(this.Name);

        }

        public override bool ValidateUser(string username, string password)
        {
            var user = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Users/GetUser"), new { UserName = username }).ToDataSourcePagedResult<MemberUserInfo>();
            ////简单实现验证用户，不验证密码，用户只存在就可以
            if (user != null)
            {
                return true;
            }

            return false;
        }

        #endregion

        #region 暂时不需要重写的方法

        public override bool ChangePassword(string username, string oldPassword, string newPassword)
        {
            throw new NotImplementedException();
        }

        public override string ApplicationName
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public override bool ChangePasswordQuestionAndAnswer(string username, string password, string newPasswordQuestion, string newPasswordAnswer)
        {
            throw new NotImplementedException();
        }

        public override MembershipUser CreateUser(string username, string password, string email, string passwordQuestion, string passwordAnswer, bool isApproved, object providerUserKey,
            out MembershipCreateStatus status)
        {
            throw new NotImplementedException();
        }

        public override bool DeleteUser(string username, bool deleteAllRelatedData)
        {
            throw new NotImplementedException();
        }

        public override bool EnablePasswordReset
        {
            get { throw new NotImplementedException(); }
        }

        public override bool EnablePasswordRetrieval
        {
            get { throw new NotImplementedException(); }
        }

        public override int GetNumberOfUsersOnline()
        {
            throw new NotImplementedException();
        }

        public override string GetPassword(string username, string answer)
        {
            throw new NotImplementedException();
        }

        public override int MaxInvalidPasswordAttempts
        {
            get { throw new NotImplementedException(); }
        }

        public override int MinRequiredNonAlphanumericCharacters
        {
            get { throw new NotImplementedException(); }
        }

        public override int MinRequiredPasswordLength
        {
            get { throw new NotImplementedException(); }
        }

        public override int PasswordAttemptWindow
        {
            get { throw new NotImplementedException(); }
        }

        public override MembershipPasswordFormat PasswordFormat
        {
            get { throw new NotImplementedException(); }
        }

        public override string PasswordStrengthRegularExpression
        {
            get { throw new NotImplementedException(); }
        }

        public override bool RequiresQuestionAndAnswer
        {
            get { throw new NotImplementedException(); }
        }

        public override bool RequiresUniqueEmail
        {
            get { throw new NotImplementedException(); }
        }

        public override string ResetPassword(string username, string answer)
        {
            throw new NotImplementedException();
        }

        public override bool UnlockUser(string userName)
        {
            throw new NotImplementedException();
        }

        public override void UpdateUser(MembershipUser user)
        {
            throw new NotImplementedException();
        }

        #endregion
    }

```

2. 自定义Role Provider，如下所示：

```CS
    public class CustomRoleProvider : RoleProvider
    {
        private static readonly Uri BaseUri = new Uri(SystemConfigConst.ProviderApiBaseUrl);

        public override string ApplicationName { get; set; }

        /// <summary>
        /// 获取全部角色
        /// </summary>
        /// <returns></returns>
        public override string[] GetAllRoles()
        {
            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Role/GetAllRoles"), null).ToDataSourcePagedResult<string[]>();

            return result;
        }

        /// <summary>
        /// 根据User得到其相关的角色
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public override string[] GetRolesForUser(string username)
        {
            var parameters = new
            {
                UserName = username,
            };

            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Role/GetRolesForUser"), parameters).ToDataSourcePagedResult<string[]>();

            return result;
        }

        /// <summary>
        /// 根据角色获取其绑定的用户
        /// </summary>
        /// <param name="rolename"></param>
        /// <returns></returns>
        public override string[] GetUsersInRole(string rolename)
        {
            var parameters = new
            {
                RoleName = rolename,
            };

            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Role/GetUsersInRole"), parameters).ToDataSourcePagedResult<string[]>();

            return result;
        }

        public override bool IsUserInRole(string username, string rolename)
        {
            var usersForRole = GetUsersInRole(rolename).ToList();
            return usersForRole.Where(userName => userName == username).Count() > 0;
        }

        public override bool RoleExists(string rolename)
        {
            var parameters = new
            {
                RoleName = rolename,
            };

            var result = RestUtil.Post<ResponseInfo>(new Uri(BaseUri, "Api/Role/RoleExists"), parameters).ToDataSourcePagedResult<bool>();

            return result;
        }

        public override string[] FindUsersInRole(string rolename, string usernameToMatch)
        {
            List<string> users = GetUsersInRole(rolename).ToList<string>();
            List<string> foundUsers = users.Where(userName => userName.ToLowerInvariant().Contains(usernameToMatch.ToLowerInvariant())).ToList<string>();
            return foundUsers.ToArray();
        }

        #region 没有实现的方法

        public override void AddUsersToRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        public override void CreateRole(string roleName)
        {
            throw new NotImplementedException();
        }

        public override bool DeleteRole(string roleName, bool throwOnPopulatedRole)
        {
            throw new NotImplementedException();
        }

        public override void RemoveUsersFromRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        #endregion
    }
```

## 配置Web Config

自定义的Provider成功安装到GAC之后，接着修改web.config。注意需要修改3个地方，Web Application Config、SharePoint Central Administration Config、SecurityTokenServiceApplication，其路径如果记不住的话，打开IIS，浏览即可，即如下所示：
![Image text](/img/static/2018-09-28/sp001.jpg)

1. 首先修改Web Application的Web Config，找到其Membership节点，将以下代码复制进：

```XML
    <membership defaultProvider="i">
      <providers>
        <add name="i" type="Microsoft.SharePoint.Administration.Claims.SPClaimsAuthMembershipProvider, Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" />
        <add name="CustomMembershipProvider" type="TZIWB.CustomProvider.CustomMembershipProvider,TZIWB.CustomProvider" />
      </providers>
    </membership>
    <roleManager cacheRolesInCookie="false" defaultProvider="c" enabled="true">
      <providers>
        <add name="c" type="Microsoft.SharePoint.Administration.Claims.SPClaimsAuthRoleProvider, Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" />
        <add name="CustomRoleProvider" type="TZIWB.CustomProvider.CustomRoleProvider,TZIWB.CustomProvider" />
      </providers>
    </roleManager>
```
找到其PeoplePickerWildcards节点，将以下代码复制进：

```XML
    <PeoplePickerWildcards>
      <clear />
      <add key="CustomMembershipProvider" value="%" />
    </PeoplePickerWildcards>
```

2. 接着修改SharePoint Central Administration的Web Config：

```XML
    <membership defaultProvider="i">
      <providers>
        <add name="i" type="Microsoft.SharePoint.Administration.Claims.SPClaimsAuthMembershipProvider, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" />
        <add name="CustomMembershipProvider" type="TZIWB.CustomProvider.CustomMembershipProvider,TZIWB.CustomProvider" />
      </providers>
    </membership>
    <roleManager>
      <providers>
        <add name="c" type="Microsoft.SharePoint.Administration.Claims.SPClaimsAuthRoleProvider, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" />
        <add name="CustomRoleProvider" type="TZIWB.CustomProvider.CustomRoleProvider,TZIWB.CustomProvider" />
      </providers>
    </roleManager>
```

3. 然后修改SecurityTokenSeriveApplication的Web Config，将一下配置添加到configurations节点下：

```XML
   <system.web>
        <roleManager>
            <providers>
                <add name="CustomRoleProvider" type="TZIWB.CustomProvider.CustomRoleProvider,TZIWB.CustomProvider" />
            </providers>
        </roleManager>
        <membership>
            <providers>
                <add name="CustomMembershipProvider" type="TZIWB.CustomProvider.CustomMembershipProvider,TZIWB.CustomProvider" />
            </providers>
        </membership>
    </system.web>
```

## 配置Web Application的身份验证

进入SharePoint 2016 Central Administration-Application Management-Manage Web Applications-Authentication Providers，即如下所示：
![Image text](/img/static/2018-09-28/sp002.jpg)

点击默认，勾选FBA，并配置自定义Menbership Provider和Role Provider的名称，如下图所示：

![Image text](/img/static/2018-09-28/sp003.jpg)

最后将自定义提供程序生成的dll全部拷贝到Web Application Config、SharePoint Central Administration Config、SecurityTokenServiceApplication的bin目录下。

## 配置人员、角色权限

成功为Web Application创建了自定义的Provider之后，接着就是测试是否成功。如添加访问用户，可以如下图操作所示：

以管理员登录，选择设置-网站设置：
![Image text](/img/static/2018-09-28/sp004.jpg)

点击新建，输入员工登录名或角色名，系统自动调用上面创建的提供程序，并筛选出符合条件的用户或角色，添加后，则在列表上可以查看：
![Image text](/img/static/2018-09-28/sp005.jpg)


## 测试

浏览器中打开Web Application站点，选择FORMS认证方式，输入用户名和密码，点击登录后进入Web Application站点的主页，如下图所示：
![Image text](/img/static/2018-09-28/sp006.jpg)

## 其他配置

如果采用REST访问其他服务器来获取数据，Sharepoint可能会报一个错误：Dynamic operations can only be performed in homogenous AppDomain，一般会在日志目录下看到，Sharepoint 2016的日志在目录"Program Files\Common Files\microsoft shared\Web Server Extensions\16\LOGS"下。

若要解决以上错误，候需要修改配置文件：

将配置文件中的

```XML
<trust level=”Full” originUrl=”” legacyCasModel=”true” />
```

替换为：

```XML
<trust level=”Full”  />
```

在节点configuration->runtime下添加以下配置：

```XML
<NetFx40_LegacySecurityPolicy enabled=”false”/>
```

如果能在三个站点（应用程序、管理中心、、令牌服务程序）找到以上配置，请修改。

## 参考资料

1. 微软的官方文档： 
https://docs.microsoft.com/zh-cn/previous-versions/office/developer/sharepoint-2010/gg317440(v=office.14)
2. 使用自定义数据库访问人员或角色的例子：
https://social.technet.microsoft.com/wiki/contents/articles/38459.sharepoint-2016-forms-based-authentication-part-1.aspx
