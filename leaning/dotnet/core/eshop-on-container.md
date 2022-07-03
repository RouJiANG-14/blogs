# eShopOnContainer 第一步

运行结果截图：![](http://images2017.cnblogs.com/blog/914251/201801/914251-20180107200209049-2114985332.png)
操作流程：
 1.  git上clone 项目
 2.  windows版的docker并且安装成功，配置3核CPU，4G内存 
 3.  vs 2017 （15.5）版本以上。 
 4.  打开项目 ``` eshopOnContainer.ServiceAndMvc ``` 
 5.  设置docker-compose 为启动项目 
 6.  点击运行，就行了。
说一下自己遇到的坑：
 配置镜像加速器的时候，阿里云的加速地址没有生效，特别慢，后来改为DaoCloud的加速地址就快很多了
 报端口 6379 被占用，我以为第一次启动没有成功，运行的容器把端口给占用了，结果删除掉所有运行的容器，再次启动依旧报端口占用的错误。后来经过排查是我本机装的有redis-server 
然后和项目中依赖的redis 容器启启动时 导致端口占用冲突。把进程redis-server.exe 停用掉就可以了。
附加知识：
 windows 中查看端口占用情况： netstat -ano |findstr 6379
       ![](http://images2017.cnblogs.com/blog/914251/201801/914251-20180107201325315-1353732142.png)
   返回的最后一个参数是进程的PID 
查看所有的进程列表： tasklist
#### 2018-01-08 更新
  替换掉eshop 的redis 
问题是这样的由于昨天第一次跑eshop，报端口占用的问题。于是把redis进程给干掉了。今天发现开发环境的项目跑不起来了。查看日志是redis没有启动的原因。于是又把redis手动启动起来了。
今天晚上又想跑eshop，于是想不能把redis进程再给干掉，然后明天再重启。 
  
后台仔细一想：eshop用的redis 和本地装的redis端口是用的同一个端口，于是想把eshop中用的redis，用本机装的redis给替换掉。一不做，二不休，于是动起手来了。  
主要修改如下：
 `docker-compose.yml`文件
删除掉redis容器服务
```
  basket.data:
    image: redis
    ports:
      - "6379:6379"
```
删除掉依赖该service的引用(只有basket.api引用该服务)
```
 basket.api:
    image: eshop/basket.api:${TAG:-latest}
    build:
      context: ./src/Services/Basket/Basket.API
      dockerfile: Dockerfile    
    depends_on:
      - basket.data
      - identity.api
      - rabbitmq
```
删除掉`- basket.data` 即可。再次完美运行。目前没有发现问题。