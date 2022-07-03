# 记一次为gitlab启用CI的过程

问题描述：
>  在局域网内搭了了一个gitlab，最近有需求要用CI

那时我不在 ，他们尝试了一段时间的Jenkins，但是还没有成功，我说gitlab已经有这些功能了，不用那个。于是一个人搞起来了。

从开始用到现在，大致用了不到一天的时间。特来记录一下。
刚开始弄不清`gitlab`和`Runner`的区别,以为`gitlab`已经有这个功能了，直接修改配置文件开启就行了。后来看文档明白了。
`GitLab Runner` 需要额外安装，可以跑在一个单独的机子上。要求这个机器需要能够访问gitlab

## 步骤

 ###   安装ubuntu Server 
 ###   为ubuntu Server安装Docker
 ###   将 `gitlab Runner` 安装为docker 服务

 ```

docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest

```
 ### 进入容器 `docker exec -it gitlab-runner bash`

  ### 修改hosts文件`vim /etv/hosts`
 ```
192.168.1.116 gitlab.xxxx.com //你的gitlab ip 地址和域名
```
  ###  注册`runner`
```
gitlab-runner register
```
### 输入你的注册信息
token之类的信息在`admin/runners`可以看到，需要 `root`用户登陆gitlab
![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180608155446390-714541586.png)

设置成功页面(docker 之后一路点回车，runner会被设置为共享的，每个项目都可以用)

![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180608155213154-1347686803.png)
### 登陆gitlab查看Runner信息
![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180608155544486-246113260.png)

### 编辑runner，将runner 分配给相应的项目
![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180608155721103-1484617998.png)

### 进入项目在项目的根目录中创建文件`.gitlab-ci.yml`，一定是根目录，内容如下：
![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180608160014608-1682299615.png)

提交之后就会自动运行了

![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180608160327625-1379353767.png)

报了一个SDK版本错误，上了[dockerhub](https://hub.docker.com/r/microsoft/aspnetcore-build/)一看才知道，原来弃用了，以后没有`microsoft/aspnetcore-build`改为了`microsoft/dotnet`,[变更说明](https://github.com/aspnet/aspnet-docker/tree/master/2.1)
修改错误之后。终于成功了。

![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180608160651177-460849488.png)

## 参考资料
https://docs.gitlab.com/runner/install/docker.html

https://dotnetthoughts.net/building-dotnet-with-gitlab-ci/

http://www.cnblogs.com/xishuai/p/ubuntu-install-gitlab-runner-with-docker.html