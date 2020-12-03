# 如何消除while（true）

## 背景

一个服务需要不停的在调用另一个服务，去抓取数据。 处理完了然后处理下一批。

## 实现方案

| 实现方案 | 优点 | 缺点 |
| -------- | ---- | ---- |
| 定时任务 | 简单 | 存在资源浪费 |
| while(true) | 资源不浪费 | 线程无法结束执行 |
| Actor 模式| 同上，且资源不浪费 | 两个Actor耦合优点高  |
| Actor模式 + mailBox|同上且耦合度低 | 实现稍微优点复杂 |

## 代码实现

### 定时任务

```java
    public void startTask() {
        List<User> users = userClient.getData(batchSize);
        users.stream().forEach(this::doWork);
    }
```

在定时任务平台上配个定时任务，每隔一段时间trigger这个API，去干活。

这么做有这么2个问题：

下次定时任务来的时候

1. 可能没有处理完。可能会导致并发问题。
2. 很快我就处理完了，就会导致资源浪费。

## while（true）

```java
public void startTaskNoEnd() {
    final Thread thread = new Thread(() -> {
        while (true) {
            List<User> users = userClient.getData(batchSize);
            users.stream().forEach(this::doWork);
        }
    });

    thread.start();
}
```

这么做资源不会浪费，但是呢线程会一直执行，不会结束。

## Atcor模式

```java
public class Actor {
 
 // 负责调度Actor
    public static class MasterActor {

        private final WorkerActor worker;

        public MasterActor(WorkerActor workerActor) {
            this.worker = workerActor;
        }
        // 抓取数据
        public void fetchData() {
            List<User> users = userClient.getData(batchSize);
            worker.doWork(users);
        }

        // 继续抓取数据
        public void done() {
            fetchData();
        } 
    }

    // 干活Actor
    public static class WorkerActor {

        private final MasterActor master;

        public WorkerActor(MasterActor masterActor) {
            this.master = masterActor;
        }

       // 干活，干完活通知master
        public void doWork(List<User> users) {
            // do work
            master.done();
        }
    }

}

```

这么做while（true） 消掉了，但是master和worker耦合度太高了。

### Actor模式 + MailBox 

```java
public class Actor {
    
    // 这里定义了Actor接口
    public interface IActor {

        void receive(Object message);
    }

// 这里是邮箱
    public static class MailBox {

// 这里是订阅者
        private List<IActor> subscribes;

        public MailBox(IActor... actors) {
            this.subscribes = Arrays.asList(actors);
        }
// 这里是接受消息，且通知给订阅者
        public void tell(Object message) {
            subscribes.forEach(subscribe -> {
                subscribe.receive(message);
            });
        }
    }

    public static class MasterActor implements IActor {

        private final MailBox mailBox;

        public MasterActor(MailBox mailBox) {
            this.mailBox = mailBox;
        }

        public void fetchData() {
            List<User> users = userClient.getData(batchSize);
            mailBox.tell(users);
        }


// 这里定义我接受哪种消息
        @Override
        public void receive(Object message) {
            if (message instanceof String) {
                if (String.valueOf(message).equals("DONE")) {
                    this.fetchData();
                }
            }
        }
    }

    public static class WorkerActor implements IActor {

        private final MailBox mailBox;

        public WorkerActor(MailBox mailBox) {
            this.mailBox = mailBox;
        }

// 这里定义我接受哪种消息
        @Override
        public void receive(Object message) {
            if(message instanceof List) {
                doWork((List<User>) message);
            }
        }

        // 这里干活
        public void doWork(List<User> users) {
            // do somework
            mailBox.tell("DONE");
        }
    }

}

```
