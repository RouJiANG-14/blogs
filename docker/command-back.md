# Docker入门命令备份

1.安装Docker curl -sSL https://get.docker.com/ | sh

2.将当前用户加入Docker用户组，这样就不用每次执行docker 命令时加上sudo了

3.查看镜像：docker images -a（查看所有镜像），docker images -f dangling=true (查看虚悬镜像)

4.删除镜像：docker rmi 镜像id OR name  ,docker rmi $(docker images -q -f dangling=true)  (删除所有的虚悬镜像)

5.运行简单的一个demo ： docker run --name webserver -d -p 81:80 nginx  解释：运行一个Nginx容器，名称为 webserver ，将81端口映射出去，外界访问的时候需要加上端口号：IP:81

6..进入容器 ：docker exec -it webserver bash ,修改完文件之后 exit 退出文件

7.查看镜像修改的内容：docker diff 容器名称

8.删除容器 doker rm  容器Name

9.将修改后的内容生成一个镜像，保存下来，docker commit --author "" --message "" 容器名称 容器的版本号 例：docker docker commit  --author "xiaoqu"  --message "修改了默认网页" webserver  nginx:v2,执行完之后会出现一个哈希值，查看镜像：docker images nginx 就可以查到当前的镜像了。

10.构建简单的镜像（nginx）mkdir mynginx touch Dockerfile ,vim Dockerfile

Dockerfile中这样写：

FROM nginx:latest 
run echo "<h1>你好我的Eginx</br>Author:小曲</h1>" >/usr/share/nginx/html/index.html
在有Dockerfile文件的目录下执行：docker build -t nginx:v3  .  后边的“.”表示在当前的目录中进行构建。

11.创建 docker network

  *  docker network create --driver bridge cnblogs //创建一个名称为 "cnblogs"的网络

  *  docker network create --subnet 172.16.0.0/16 --opt com.docker.network.bridge.name=cnblogs --opt com.docker.network.bridge.enable_icc=false cnblogs //创建一个cnblogs网络 网络段为172.16.0.0 子网掩码为 255.255.0.0 

   查看网络： docker network ls //所有网络

                  doocker network inspect cnblogs //查看cnblogs的网络配置，以及在该网络中运行的容器

                  docker network rm cnblogs //删除名为cnblogs的网络， 注意：一定要删除所有在改网络中运行的所有容器，否则无法删除网络。

 将容器运行在制定的网络中：docker run -d -it -p 80:80 --network cnblogs --name webserver nginx  //指定容器运行在cnblogs网络中。运行成功之后可以查看 docker network inspect cnblogs

 12. docker-compose 安装

服务 (service)：一个应用容器，实际上可以运行多个相同镜像的实例。

项目 (project)：由一组关联的应用容器组成的一个完整业务单元。

 可用daocloud  提供的资源安装：

          1. curl -L https://get.daocloud.io/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
          2. chmod +x /usr/local/bin/docker-compose 
    基本命令：docker-compose up //启动程序
                   docker-compose up -d //设置为后台运行
                   docker-compose ps //查看运行的程序
                   docker-compose stop //停止处于运行状态容器,并没有移除，可以通过docker-compose start 重新启动。
                   docker-compose rm   //删除掉所有服务状态的容器。
                   docker-compose config //对compose 文件进行语法检查，正常就输出配置文件，错误就输出错误信息。
                   docker-compose logs //输出日志
                  docker-compose restart //重启项目中的服务。
                   docker-compose scale //指定服务运行容器的个数。
13. docker-machine 遇到问题解决方式：
      Error with pre-create check: “VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path” 解决方法：sudo apt-get install -y virtualbox
     This computer doesn't have VT-X/AMD-v enabled. Enabling it in the BIOS is mandatory 解决方法：开启虚拟化 进入bios开启，或者虚拟机设置里直接开启。
 

 ### source 
 https://www.cnblogs.com/qulianqing/p/7295512.html
