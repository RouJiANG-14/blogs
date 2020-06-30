# Gradle 的历史

## Java构建工具
### Ant 

#### 介绍
Ant 是 Apache 组织下的一个跨平台的项目构建工具，它是一个基于任务和依赖的构建系统，是过程式的。
#### 怎么用
开发者需要显示的指定每一个任务，每个任务包含一组由 XML 编码的指令，必须在指令中明确告诉 Ant 源码在哪里，结果字节码存储在哪里，如何将这些字节码打包成 JAR 文件。
#### 缺点
Ant 没有生命周期，你必须定义任务和任务之间的依赖，还需要手工定义任务的执行序列和逻辑关系。这就无形中造成了大量的代码重复。

想象一个场景： 我又一个第三方的Jar包要引入项目，但是在Ant中是没有包管理的功能的，我需要把Jar包下载下来，然后放进项目里，然后上传版本管理器中。

> 这么做会有什么问题呢？

问题一： 项目如果依赖太多，就会导致代码仓库很大。就会导致自动化构建过程极其漫长。
问题二： 没有版本号控制。如果项目的两个依赖之间都依赖另一个第三方jar包，而自己项目中也依赖这个第三方jar包，然后这个 jar包似乎还不是同一个版本的，他们的代码似乎不兼容。是不是很头疼，不敢删把。
问题三： 项目里公用的jar包，如果升级怎么办？ 每个项目都去拷一份吗？ 



### Maven

#### 介绍

Maven 是 Apache 组织下的一个跨平台的项目管理工具，它主要用来帮助实现项目的构建、测试、打包和部署。
Maven 提供了标准的软件生命周期模型和构建模型，通过配置就能对项目进行全面的管理。它的跨平台性保证了在不同的操作系统上可以使用相同的命令来完成相应的任务。
Maven 将构建的过程抽象成一个个的生命周期过程，在不同的阶段使用不同的已实现插件来完成相应的实际工作，这种设计方法极大的避免了设计和脚本编码的重复，极大的实现了复用。
Maven 不仅是一个项目构建工具还是一个项目管理工具。

#### 为啥会有Maven

看一看Ant的缺点，你就知道Maven统一包管理。你就知道Maven有多好用了。。

#### 怎么用

它有约定的目录结构和生命周期，项目构建的各阶段各任务都由插件实现，开发者只需遵照约定的目录结构创建项目，再配置文件中生命项目的基本元素，Maven 就会按照顺序完成整个构建过程。
Maven 的这些特性在一定程度上大大减少了代码的重复

#### 缺点

配置语言选用的和Ant一样的XML，但是XML本身表达能力很差，就会出现大量冗余的XML


### Gradle
gradle 集结了Ant和Maven等构建工具的最佳特性。

#### 优点

- 性能
  - gradle 每次构建的时候只会处理那些变更的文件
  - 构建缓存 构建过程中，如果发现input相同直接跳过，不同机子上也可以做到检查
  - 守护进程 gradle会在后台启动一个守护进程，构建信息，全都放在内存区的“热”块
- 用户体验

Gradle采用groovy，这是一种DSL的语言，写起来很流畅，简洁且表达能力强。

具体请看：[https://gradle.org/maven-vs-gradle/](https://gradle.org/maven-vs-gradle/)

## gradle 版本历史

- 0.7 - 0.9
- 0.9.1
- 0.9.2
- **1.0**
- 1.1
- 1.2
- 1.3 - 1.12
- **2.0**
- 2.1 
- 2.2
- 2.2.1
- 2.3 - 2.14
- 2.14.1
- **3.0**
- 3.1
- 3.2
- 3.2.1
- 3.3
- 3.4
- 3.4.1
- 3.5
- 3.5.1
- **4.0**
- 4.0.1
- 4.0.2
- 4.1
- 4.2
- 4.2.1
- 4.3
- 4.3.1
- 4.4
- 4.5
- 4.5.1
- 4.6 - 4.8
- 4.8.1
- 4.9
- 4.10
- 4.10.1
- 4.10.2
- 4.10.3
- **5.0**
- 5.1
- 5.1.1
- 5.2
- 5.2.1
- 5.3
- 5.3.1
- 5.4
- 5.4.1
- 5.5
- 5.5.1
- 5.6
- 5.6.1 - 5.6.4
- **6.0**
- 6.0.1
- 6.1
- 6.1.1
- 6.2
- 6.2.1
- 6.2.2
- 6.3
- 6.4
- 6.4.1
- 6.5