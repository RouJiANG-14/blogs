# Docker之My sql 之旅
>  要用到mysql 数据库，本来想在本机装，后来想想还是有点污染环境，既然有docker为什么不用呢？ 
于是开启了采坑之旅，与其说采坑，倒不如说看文档不仔细看。
```
docker pull mysql:5.7
docker run --name mysql -d mysql:5.7
docker ps 
```
![](https://img2018.cnblogs.com/blog/914251/201809/914251-20180925004537637-1717390019.png)

居然不暴露端口，真是醉了，和mssql差远了，mssql docker版直接暴露端口。
```
docker rm -f mysql
docker run --name mysql -d -p 3306:3306 mysql:5.7
docker ps
```
这次终于用客户端连上了，但是没有root的密码。
通过查文档得知:会生成一个随机的root密码
`Once initialization is finished, the command's output is going to contain the random password generated for the root user; `
可以通过
```
docker logs <containerName> 2>&1 | grep GENERATED
```
得到密码。
![](https://img2018.cnblogs.com/blog/914251/201809/914251-20180925010002213-1265352765.png)

进入容器：
```
docker exec -it <containerName> mysql -uroot -p
```
接下来会提示你输入密码。成功进入。
![](https://img2018.cnblogs.com/blog/914251/201809/914251-20180925010154783-2000804845.png)

就可以执行sql cmd了。
这时可以修改密码
```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'newpassword';
```

> 如果我想在创建容器的时候指定密码怎么办？
于是我在docker官方文档上找到了答案。[地址](https://docs.docker.com/samples/library/mysql/#environment-variables)。你要设置变量，就可以生效了。
```
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=<your pwd> --name mysql mysql:5.7
```
这样就OK了。


## Note
待后续更新。
## 12.02更新
今天踩到坑了，容器丢了之后数据也丢了。
```
docker run -d -p 3306:3306 -v /mysql/path:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=<your pwd> --name mysql mysql:5.7
```