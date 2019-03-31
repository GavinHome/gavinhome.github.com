---
title: 获取Rtx用户状态方法

tags: 
- 技术文章

category: 
- 技术文章

date: 2017-02-23 21:50:00 +0800
cover: /img/cover/person-using-smartphone.jpeg
author: 
  nick: gavinhome
  link: https://www.github.com/gavinhome
subtitle: 企业OA系统需要与Rtx集成，且高权限身份用户需要获取符合某一条下的所有员工rtx状态
---


背景:企业OA系统需要与Rtx集成，且高权限身份用户需要获取符合某一条下的所有员工rtx状态...

<!--more-->
<div id="toc"></div>
<!-- csdn -->

方案:以此背景，基于rtx sdk做二次开发，

1. 后台调用RootObj.QueryUserState(String name);方法，api说明

        语法：int QueryUserState(String UserName)
        功能：查看用户状态
        参数：UserName用户帐号
        调用：QueryUserState(“herolin”)
        说明：返回0 离线、1在线、2离开、-984用户不存在，其他表示调用失败

实际开发测试时候，发现如果大批量的用户不存在，即获取异常，程序执行比较慢，所以我们直接采用第二种方案。

2. 对于大批量获取，可以在后台通过调用getstatus.php来返回所有用户的状态信息以下是官方api说明：

        getstatus.php 获取用户在线状态仅支持GET

        @param string username RTX用户名

        @return int 0不在线 1在线

        @example http://localhost:8012/getstatus.php?username=XXXX

状态返回值有两个，实际使用过程中，发现还有一个返回值是2，即离开状态；rtx用户名是企业分配的员工账号，将批量员工账号（用分割符号分隔开）传入到php，并改写php代码，获取账号列表，循环得到每个账号的状态等（0，1，2，-1表示不存在）四类。

同时将网站ip，添加到rtx server安装目录下的sdkproperty.xml文件中（关于sdk的ip限制），并将访问url中的localhost换成rtx server服务器内网ip。为了不破坏服务器文件，将改写的php文件，重新命名放置于webroot目录下。