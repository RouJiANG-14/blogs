# GitLab CI 之 Java HelloWrold
### 问题描述
> 测试人员想在gitalb上跑 `JUnit`项目，也就是java代码。  

听到这个之后，我当时都懵了，我他妈gitlab的runner是为运行.net core 安装的呀。后来一想，是我错了，我用的是docker，跟什么语言关系不大，只要有docker镜像就行了。

于是开启了疯狂学习java的两小时。
这俩小时产出效率很高，大致做了这件事情，为windows安装java运行环境，安装java 的IDE，熟悉IDE，熟悉java Helloworld的运行过程。写一个CI的Demo。

### 说一下过程吧
 创建java文件 ` HelloWorld.java `
```
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World");
    }
}

```
创建 ` .gitlab-ci.yml `,好吧这是从网上抄的。
```
image: java:latest

stages:
  - build
  - execute

build:
  stage: build
  script: /usr/lib/jvm/java-8-openjdk-amd64/bin/javac HelloWorld.java
  artifacts:
    paths:
     - HelloWorld.*

execute:
  stage: execute
  script: /usr/lib/jvm/java-8-openjdk-amd64/bin/java HelloWorld

```
结果根本跑不通。
后来我想了一下，启动一个java容器，然后进入容器里看一看命令`java`,和`javac`能不能识别，以及路径在哪里。
启动并进入容器 `docker run -it testjava java bash`
我试了一下，居然`java`和`javac`都可以用。
于是对`.gitlab-ci.yml`进行了另一番改装
```
image: java:latest

stages:
  - build
  - execute

build:
  stage: build
  script: javac HelloWorld.java

execute:
  stage: execute
  script: java HelloWorld

```
以为终于结束了，结果是我错了。
build 通过了 
![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180614085635481-2009292305.png)
execute 失败了
 ![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180614085653875-1867693358.png)

于是进行了另一番改装。
```
image: java:latest

stages:
  - execute

before_script:
  - "javac HelloWorld.java "

execute:
  stage: execute
  script: " java HelloWorld "

```
终于结束了。
![](https://images2018.cnblogs.com/blog/914251/201806/914251-20180614085854922-185315102.png)