#  NetGear R6400 刷华硕小记

从第一次刷机到现在也有八年了，当时刷了最难刷的阿里云os，为了原生安卓。去网吧通不少宵。

最近一直在考虑换路由器，咸鱼上淘了一个二手的华为荣耀pro2，准备刷机一番，发现根本刷不了。原因是因为华为路由器用的是自家的cpu，所以没人去做适配。

可是我想折腾，很显然不适合我。

然后又给卖了。之后淘了一个网件的R6400。发现这个玩意是真的大。比华为荣耀pro2 大了三四个吧。


不过这里表扬一下华为荣耀pro2，信号是真的好。我住在五楼。路由器在客厅放着。晚上在一楼楼下歇脚，还是能够轻松上网的，网件就不行了，虽然刷机之后超频了。但是还是不行。
不过这点可以忍，毕竟它带来的便利还是大于这点问题的。

遇到问题：

## r6400 新版本中无法开telnet，通过还原注释过html也不行

解决方法： 
> 固件版本降级
我在官网上用：1.0.0.20 这个版本固件 (https://www.netgear.com/support/product/R6400.aspx#Firmware%20Version%201.0.0.20)

刷完之后在http://<routerIP>/debug.htm 页面就可以直接勾选了。


## 无法安装离线插件
> 检测到离线安装包：v2xxx_switch1.3.tar.gz 含非法关键词！！！
> 根据法律规定，koolshare软件中心将不会安装此插件！！！
> 删除相关文件并退出...

解决方法：

* 开启路由器Merlin系统的SSH

> 系统管理 -> 系统设置 -> 服务。 之后开启ssh。 应用本页面设置

* ssh 登陆上你的路由器 (用户名和密码都是你登陆路由器的用户名和密码)
> ssh admin@<your IP>

>  sed -i 's/\tdetect_package/\t# detect_package/g' /koolshare/scripts/ks_tar_install.sh

demo: 
```
ssh admin@192.168.2.1
The authenticity of host '192.168.2.1 (192.168.2.1)' can't be established.
ECDSA key fingerprint is SHA256:d2OuW66vMeVSAfbWqNwtquE38LWaR9Wv5gDONwS8xTw.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.2.1' (ECDSA) to the list of known hosts.
admin@192.168.2.1's password:


ASUSWRT-Merlin R6400 380.63-2-X7.2.1 Fri Dec  9 08:38:46 UTC 2016
admin@NETGEAR-0442:/tmp/home/root# sed -i 's/\tdetect_package/\t# detect_package/g' /koolshare/scripts/ks_tar_install.sh
admin@NETGEAR-0442:/tmp/home/root# exit
Connection to 192.168.2.1 closed.
```

## 提示
> v2XXX插件，是通过hook小火箭的进程，然后实现它原用的功能的。所以用V2xxx的同学一定要安装好小火箭先。