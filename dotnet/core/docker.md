# .net core 下的一个docker hello world
####接触 docker 有段时间了，发现docker这个东西，真是越用越爽。
那就从零开始跑一个 docker simple 。
#### 方法一：
```步骤一```:  ```dotnet new mvc --name myweb``` //创建一个.net core 的mvc 项目名称为```myweb``` 
```步骤二```:```cd myweb``` //进入目录
```步骤三```: ```dotnet restore```  //还原项目
```步骤四```：```dotnet publish -c release -o publish``` //发布项目到```publish```文件夹中去。 
```步骤五```：```touch Dockerfile```//创建dockerfile 文件
```步骤六```:  ```vim Dockerfile``` //编辑docker file 
```
    FROM microsoft/aspnetcore 
    WORKDIR /app         //设置当前目录为 app
    COPY /publish .       // 将本地publish 文件夹中的文件 复制到当前目录（app）中
    ENTRYPOINT ["dotnet","myweb.dll"]
```

```步骤七```: ```docker build -t webapp .``` //生成docker镜像 名称为webapp
```步骤八```:```docker run -d -p 5000:80 --name webapp webapp``` //启动镜像，设置为后台运行，并且暴露本地5000端口 ，名称为webapp 用的镜像名称为webapp

#### 方法二：
 ```执行步骤1-2，省略掉步骤3-4，直接操作步骤5-8```唯一的不同是```Dockerfile```不一样了。
```
FROM  microsoft/aspnetcore-build as  builder
WORKDIR /source
COPY *.csproj .
RUN dotnet restore
copy . .
run dotnet publish -c release -o /publish/
from microsoft/aspnetcore
workdir /app
copy --from=builder /publish .
ENTRYPOINT ["dotnet","test.dll"]
```
查看一下：![](http://images2017.cnblogs.com/blog/914251/201711/914251-20171107195933231-1548257121.png)
本地浏览器 ```localhost:5000```查看：
![](http://images2017.cnblogs.com/blog/914251/201711/914251-20171107200050966-1370228217.png)

####总结：
```方法一```和```方法二```的不同就是： 方法一需要手动进行build和publish ，方法二是直接在docker中进行build 和publish省去了麻烦。

### docker-compose 
在该项目目录下创建文件`docker-compose.yaml`
编辑该文件
```
version : '3.3'
services :
    web :
       build  :  .
       ports :
          -  80 : 80
```
直接运行`docker-compose up ` 自动构建镜像，并启动。
### docker-compose 笔记
| 命令 | 解释 |
| --- | ----  |
| build  | --force-rm 删除构建过程中的临时容器。 |
|          | --no-cache 构建镜像过程中不使用 cache（这将加长构建过程）。 |
|      |  --pull 始终尝试通过 pull 来获取更新版本的镜像。 |
| config | 验证 docker compose 语法检查  |
| down | 此命令将会停止 up 命令所启动的容器，并移除网络  |
| exec | 进入指定的的容器 和docker exec 用法差不多。 |
| images |  列出 Compose 文件中包含的镜像。 |
| kill | 通过发送 SIGKILL 信号来强制停止服务容器。|
| logs | 容器运行状况的日志输出 和`docker logs`差不多。 |
| pause | 暂停一个容器 |
| port | 打印某个容器端口所映射的公共端口。|
| ps |  列出项目中目前的所有容器。| 
| push | 推送服务依赖的镜像到 Docker 镜像仓库。| 
| restart | 重启项目中的服务。|
| rm |  删除所有（停止状态的）服务容器 |
| run | 在指定服务上执行一个命令。 |
| scale | 指定容器的个数 |
| start | 启动已经存在的容器 |
| stop |  停止已经处于运行状态的容器，但不删除它 |
| top | 查看各个服务容器内运行的进程。 | 
| up | -d 在后台运行服务容器。|
| | -no-color 不使用颜色来区分不同的服务的控制台输出。 |
| | --no-deps 不启动服务所链接的容器。 |
| | --force-recreate 强制重新创建容器，不能与 --no-recreate 同时使用 |
| |  --no-recreate 如果容器已经存在了，则不重新创建，不能与 --force-recreate 同时使用。 |
| | --no-build 不自动构建缺失的服务镜像。 |
| | -t, --timeout TIMEOUT 停止容器时候的超时（默认为 10 秒）。 |