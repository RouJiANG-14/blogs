# 小菜鸟入门nginx
### 实现功能：端口进行转发

>  比如我实际运行的是·`http:localhost:5000` 但是我想通过localhost:80 进行访问。

### 过程

1  [下载nginx](http://nginx.org/en/download.html)  

2  解压到某个目录(比如我放在C盘根目录)

3  进入目录（C:\nginx-1.14.0）我的是C盘，不同目录不一样。

4  在该目录打开命令行窗口，执行 `start nginx` or `start nginx.exe` ,窗口会一闪而过。

5 查看nginx 是否正常运行 :命令行窗口`tasklist /fi "imagename eq nginx.exe"` 如果正常运行可以看到
![](https://images2018.cnblogs.com/blog/914251/201804/914251-20180422205737728-1782687463.png)

如果没有看到运行的进程 进入目录`logs`,查看文件`error.log`,查看具体的错误。

我刚开始也遇到了无法运行的错误，错误信息如下：

> 2018/04/22 20:36:14 [emerg] 10404#316: bind() to 0.0.0.0:80 failed (10013: An attempt was made to access a socket in a way forbidden by its access permissions)

后来删除IIS默认绑定的`default`站点，解决问题。

6.编辑文件`C:\nginx-1.14.0\conf\nginx.conf`

修改其 server节点下的内容：

原内容：

```
 server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
               root   html;
             index  index.html index.htm;
        }
```
修改后：
```
 server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            proxy_pass https://localhost:5001;
            # root   html;
            # index  index.html index.htm;
        }
```

只添加了一行`proxy_pass https://localhost:5001`,后边的两行注释掉了。

7 重新载入nginx，`nginx -s reload`

8  访问`http://localhost`

![](https://images2018.cnblogs.com/blog/914251/201804/914251-20180422210917229-1892797270.png)
运行成功。

### 笔记

| 命令 | 解释 |
| ----- | ------- |
| nginx -s stop	|  强制停止 |
| nginx -s quit  |	正常退出 |
| nginx -s reload | 更改配置文件用到的命令，用新的配置文件启动新的进程，然后正常推出旧的进程。|
| nginx -s reopen  | 	重新打开日志文件。|

ubuntu 的nginx 默认配置文件在`/etc/nginx/conf.d/default.conf`下。