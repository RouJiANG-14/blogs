# 线程与进程基础

目录

- [线程与进程基础](#%E7%BA%BF%E7%A8%8B%E4%B8%8E%E8%BF%9B%E7%A8%8B%E5%9F%BA%E7%A1%80)
  * [什么是进程](#%E4%BB%80%E4%B9%88%E6%98%AF%E8%BF%9B%E7%A8%8B)
  * [什么是线程](#%E4%BB%80%E4%B9%88%E6%98%AF%E7%BA%BF%E7%A8%8B)
  * [线程和进程的区别与联系](#%E7%BA%BF%E7%A8%8B%E5%92%8C%E8%BF%9B%E7%A8%8B%E7%9A%84%E5%8C%BA%E5%88%AB%E4%B8%8E%E8%81%94%E7%B3%BB)
  * [Java线程创建与运行](#java%E7%BA%BF%E7%A8%8B%E5%88%9B%E5%BB%BA%E4%B8%8E%E8%BF%90%E8%A1%8C)
    + [线程的等待与通知](#%E7%BA%BF%E7%A8%8B%E7%9A%84%E7%AD%89%E5%BE%85%E4%B8%8E%E9%80%9A%E7%9F%A5)
  * [线程死锁](#%E7%BA%BF%E7%A8%8B%E6%AD%BB%E9%94%81)
  * [守护线程和用户线程](#%E5%AE%88%E6%8A%A4%E7%BA%BF%E7%A8%8B%E5%92%8C%E7%94%A8%E6%88%B7%E7%BA%BF%E7%A8%8B)

## 什么是进程

* 是指计算机中已经运行的程序。
* 曾是分时系统的基本运作单位。
* 面向进程设计的系统中，进程是程序的基本执行实体。
* 面向线程设计的系统中，进程不是基本运行的单位，而是线程的容器。
* 程序本身只包含指令、数据及其组织结构的描述，进程才是程序的真正运行实例。（这点和Docker image 和 Docker container的关系很像）

进程有五种状态：

* 新生： 进程产生中（主动）
* 运行： 正在运行中（被动）
* 等待： 等待某事发生，比如等待用户输入完成。也称为阻塞。（主动）
* 就绪： 进入CPU的等待队列，等待获取CPU（主动）
* 结束： 完成运行（主动/被动）

进程之间的各个状态是不能随便切换的。
比如无法从**等待**直接转为**运行**，因为**运行**是指CPU目前正在执行，**等待**结束之后，只能进入CPU的等待队列，等待CPU的调度，然后等CPU去激活

## 什么是线程

* 线程是操作系统能够进行运算的最小单位。
* 大部分情况下他被包含在进程之中，是进程的实际运作单位。
* 一条线程指的是进程中一个单一顺序的控制流，一个进程中可以并发多个线程，每条线程执行不同的任务。
* 在unix 系统中，也被成为轻量级进程，但轻量级进程更多的是指**内核线程**，而把用户线程成为线程。

线程有四种基本状态：

* 产生
* 阻塞
* 非阻塞
* 结束

## 线程和进程的区别与联系

* 一个进程可以有很多线程，每条线程并行执行不同的任务。
* 同一个进程中的多条线程将共享该进程中的全部系统资源，比如：虚拟地址空间，文件描述符，信号处理等。
* 同一个进程中的多个线程有各自的调用栈，自己的寄存器环境，自己的线程本地存储。

操作系统在分配资源时要把资源分配给进程，但是CPU比较特殊，它是被分配到线程的，因为CPU真正执行的是线程，也就是说线程是CPU分配的基本单位。

每个线程都有自己的栈资源，用于存储该线程的局部变量和线程的调用栈帧，这个局部变量是线程私有的，其他线程访问不到。

堆是进程内最大的一块内存，堆是被进程中的所有线程共享的，是进程创建时分配的，堆里面主要放的是使用new操作创建的对象实例。

方法区则用来存放JVM加载的类、常量、静态变量等信息，也是线程共享的。


## Java线程创建与运行

三种方式：

1. 继承Thread类，重写run方法(创建线程和线程的任务耦合)
2. 实现Runnable接口重写run方法（线程任务和创建线程解耦，不能有返回值）
3. 实现Callable<> 接口重写call<>方法（优点同上，可以有返回值）

### 线程的等待与通知

> wait（）函数

当一个线程调用共享变量wait方法时，该调用线程会被挂起，知道发生一下事情才会返回：

* 其他线程调用该共享对象的notify/notifyAll方法
* 其他线程调用了该线程的interrupt方法，该线程抛出InterruptedException异常返回 

> notify 函数

一个线程调用共享对象的notify方法后，会唤醒一个在该共享变量上调用等待wait系列方法后挂起的一个**随机**线程

注意：

* 被唤醒的线程不能马上从wait方法返回继续执行，他必须获得了共享对象监视锁之后才能返回。
* 只有获取了共享对象监视器锁之后才能够调用notify方法，否则会抛出IllegalMonitorStateException异常。

> notifyAll 函数

通知所有等待在该共享变量上的wait线程。

注意：

* notifyAll 只会唤醒调用这个方法前调用了wait方法系列线程。

> Join 函数

等待当前线程执行完成，之后执行其他事情。

> sleep

当一个执行中的线程调用了sleep方法后，调用线程会暂时让指定时间的执行权，也就是这期间不参与CPU的调度，但是该线程拥有的资源监视器，比如锁，还是持有不让出的。

执行之后正常返回，线程处于就绪状态，参与CPU调度。

> yield 方法

当一个线程调用yield方法的时候，实际上就是在暗示线程调度器当前线程请求让出自己的CPU使用，但是线程调度器可以无条件忽略掉这个暗示。
操作系统是以时间片为每个线程分配CPU的，正常情况下一个线程用完自己的时间片后，线程调度器才会进行下一轮的线程调度。
而当一个线程调用Thread类的静态方法yield时，是在告诉线程调度器自己占有时间片没有用完但是自己不想用了，可以开启下一轮调度了。

## 线程死锁

> 定义

死锁是指两个或者两个以上线程在执行过程中，因争夺资源而互相等待的现象，在无外力作用的情况下，这些线程会一直互相等待而无法继续进行下去。

> 死锁产生的四个必要条件

* 互斥条件
* 请求并持有
* 不可剥夺
* 环路等待

> 解除死锁：

破坏掉上述四个条件中的一个即可。

## 守护线程和用户线程

> 简介：

Java中的线程分两类： daemon 线程和 user线程。

JVM在启动的时候调用main函数，main函数所在的线程就是一个用户线程，在JVM内部同时也启动了很多守护线程，比如垃圾回收。

> 区别

当最后一个非守护线程结束时，JVM会正常退出，而不管是否有守护线程。

> 设置守护线程

```java
Thread daemonThread = new Thread(() -> {
    while (true) {
        System.out.println("This is daemon thread");
    }
});
daemonThread.setDaemon(true);
daemonThread.start();
```

> ThreadLocal

作用：

ThreadLocal 是JDK包提供的，它提供了线程本地变量，也就是如果你创建了一个threadlocal变量，那么访问这个变量的每个线程都会有一个本地副本。

当多个线程操作这个变量的时候，实际操作的是自己本地内存里的变量，从而避免了线程安全访问问题。

原理：

Thread类中有一个threadLocals和inheritableThreadLocals, 他们都是ThreadLocalMap类型的变量，而ThreadLocal是一个定制化的HashMap。

默认情况下每个线程中的这两个变量都为null，只有当线程第一次调用ThreadLocal的set或get方法的时候才会去初始化。

其实每个线程的本地变量不是存在ThreadLocal实例的，而是存在调用线程的threadLocals变量里边。

也就是说，ThreadLocal类型的本地变量存放在具体的线程内存空间中。

注意：

使用完之后一定要调用remove方法，否则会一直存在线程内存空间中，可能会造成内存溢出。

threadLocal不支持继承，父线程对threadLocal的设置，在父线程中创建的自线程是无法获取到值的。

inheritable Demo 

```java
localVariable.set("aaaa");
new Thread(() -> {
    System.out.println("child thread :" + localVariable.get());
}).start();

System.out.println("parent thread " + localVariable.get());

output
// parent thread aaaa
//child thread :null
```

> InheritableThreadLocal

与ThreadLocal之间的不同就是父子线程之间可以共享该变量。

demo

```java
static InheritableThreadLocal<String> inheritableThreadLocal = new InheritableThreadLocal<>();

public static void main(String[] args) throws InterruptedException {
    inheritableThreadLocal.set("value");
    final Thread thread = new Thread(() -> {
        System.out.println("child thread get " + inheritableThreadLocal.get());
        final Thread thread1 = new Thread(() -> {
            System.out.println("child child thread get " + inheritableThreadLocal.get());
        });
        thread1.start();
        try {
            thread1.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        inheritableThreadLocal.remove();
    });
    System.out.println("before child thread remove " + inheritableThreadLocal.get());
    thread.start();
    thread.join();
    System.out.println("after child thread remove " + inheritableThreadLocal.get());
}
```
