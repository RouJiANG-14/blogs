# 局域网内的邮件收发
# 实现功能
  局域网内邮件服务器的搭建，局域网内不同用户之间的邮件收发。

# 准备
 首先准备一台 装有`windows server`系统的服务器。
  启用`DNS`,`DHCP`功能 。
  `DHCP`就是动态分配IP的没有什么可说的，很简单。
  `DNS`这里说一下吧，我配置的域名`jointown.com`,一般我喜欢正向和反向同时配，添加一条A记录解析到你的邮件服务器所在的地址去。比如我添加的的是`mail.jointown.com`,解析到`172.16.22.22/16`。其实这个域名可以随便起的，看自己的心情吧。
   接下来需要下载一个软件，这个软件集成了`SMTP`和`IMAP`和`POP3`省了很多事，关键还是免费的。[地址](https://www.hmailserver.com/download),[备份地址](https://files.cnblogs.com/files/qulianqing/hMailServer-5.6.7-B2425.zip)
# 安装软件
   这个软件安装时会监听`25`号端口，如果有冲突，安装之前就会有警告。消除警告后在进行下一步安装。
   这个软件在安装过程中会要求配置管理员密码，也就是你每次点开这个软件的时候都需要输入管理员密码。
# 软件配置
  启动完成之后会让你添加Domail
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520174320167-279346792.png)

由于我提前已经准备好了Domail，这里输入`jointown.com`
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520174804421-83548417.png)
这么做就可以了。还有一些其他的高级配置，我没有去研究。
接下来配置SMTP
点开`settings`>>`Protocols`>>`SMTP` 之后点击右侧的选项卡`Delivery of Email`

设置`localhost name`为`jointown`, `Stmp Relayer`设置为`172.16.22.22`也就是本机的IP，
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520175713901-2056974217.png)
## 接下来就是配置账户了
点开`Domains`>>`jointown.com`>>`Accounts`依次创建账号。
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520175846967-678422547.png)
以上步骤结束，整个过程就搭建结束了。
测试一下是否成功。
# 下载邮件收发客户端
 我用的是Foxmail
添加账户，输入账户和密码
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520180448186-1809912273.png)
之后会有个确认页面
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520180529713-1805514809.png)
点击确定即可，出现下边页面表示创建成功
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520180627111-735763995.png)

再次添加另一个账户，看相互之间能否收发邮件。
发件人发送邮件
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520180918306-1614636646.png)

收件人邮箱
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520181030526-1680040823.png)

收件人进行一个回复
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520181141900-2053760830.png)

收件人邮箱

![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180520181221807-1821398947.png)


大功告成。


# 更新
终于解决了`gitlab`的邮件通知问题，
## 问题描述
> 在局域网内搭建了一个`gitlab`,当时没有配邮件服务，很难受。昨天晚上用了一晚上，终于解决了邮件收发问题了。
## 要求
 局域网内有一个`gitlab`站点，和一个邮件服务器
## 操作步骤
`vim /etc/gitlab/gitlab.rb`,建议先备份一下,不然待会搞坏了没办法还原了。`cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.bat`
加入下边的代码
```
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = 'mail.jointown.com'
gitlab_rails['smtp_port'] = 25
gitlab_rails['smtp_domain'] = 'jointown.com'
gitlab_rails['smtp_tls'] = false
gitlab_rails['smtp_openssl_verify_mode'] = 'none'
gitlab_rails['smtp_enable_starttls_auto'] = false
gitlab_rails['smtp_ssl'] = false
gitlab_rails['smtp_force_ssl'] = false
```
重新加载配置文件`gitlab-ctl reconfigure`
## 测试一下
`gitlab-rails console`
`Notify.test_email('xiaoqu@jointown.com', 'Message Subject', 'Message Body').deliver_now`
进入客户端查看结果
![](https://images2018.cnblogs.com/blog/914251/201805/914251-20180521095315995-288127403.png)
## 总结
要仔细看文档。