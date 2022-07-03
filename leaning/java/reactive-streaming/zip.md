# Reactive stream Programming 踩坑记录（zip）
前提介绍吧：
用的全是异步非阻塞的操作符，框架选用的是[Akka](https://doc.akka.io/docs/akka/current/index.html)和[R2DBC](https://r2dbc.io)
最外层流是[Akka stream](https://doc.akka.io/docs/akka/current/stream/index.html)， 内部和DB交互用的是[Project Reactor](https://projectreactor.io/)
先看代码：
```
    @Test
    void name() throws ExecutionException, InterruptedException {
        final List<Integer> lists = Source.single(1)
                                          .map(any -> Arrays.asList(1, 2, 3))
                                          .flatMapConcat(Source::from)
                                          .grouped(2)
                                          .zip(Source.single(4))
                                          .map(pair -> {
                                                    log.info("map-pair.first:{}", pair.first());
                                                    log.info("map-pair.second:{}", pair.second());
                                                    return pair.first();
                                                })
                                          .withAttributes(ActorAttributes.withSupervisionStrategy(e -> {
                                                    log.info("withAttributes:{}", e.getMessage());
                                                    return Supervision.resume();
                                                })).runWith(Sink.head(), actorSystem)
                                          .toCompletableFuture().get();
        Assertions.assertEquals(2, lists.size());

    }
```
![](https://img2020.cnblogs.com/blog/914251/202004/914251-20200402211538665-1963794492.png)
![](https://img2020.cnblogs.com/blog/914251/202004/914251-20200402211737129-1242868949.png)

从测试结果看只有两个数据，然后从log我们也发现map只被执行了一次。

解释一下流吧： 
![](https://img2020.cnblogs.com/blog/914251/202004/914251-20200402212200521-817956900.png)

然后就是zip。
干掉zip
```java
    @Test
    void name() throws ExecutionException, InterruptedException {
        final List<List<Integer>> lists = Source.single(1)
                                                .map(any -> Arrays.asList(1, 2, 3))
                                                .flatMapConcat(Source::from)
                                                .grouped(2)
//                                                .zip(Source.single(4))
                                                .map(item -> {
                                                    log.info("map：{}", item);
//                                                    log.info("map-pair.second:{}", pair.second());
                                                    return item;
//                                                    return pair.first();
                                                })
                                                .withAttributes(ActorAttributes.withSupervisionStrategy(e -> {
                                                    log.info("withAttributes:{}", e.getMessage());
                                                    return Supervision.resume();
                                                })).runWith(Sink.seq(), actorSystem)
                                                .toCompletableFuture().get();
        assertThat(lists).containsExactly(Arrays.asList(1, 2), Arrays.asList(3));
    }
```
 看下效果
![](https://img2020.cnblogs.com/blog/914251/202004/914251-20200402213538620-1445454056.png)

是不是很神奇。
有两种解决方案
1. 在zip之前 将流中数据全都收集起来，也就是将group 换成普通函数式编程的reduce， akka中叫 Fold
```java
   @Test
    void name() throws ExecutionException, InterruptedException {
        final List<List<Integer>> lists = Source.single(1)
                                                .map(any -> Arrays.asList(1, 2, 3))
                                                .flatMapConcat(Source::from)
                                                .fold(Collections.<Integer>emptyList(), (array, item) ->{
                                                    List<Integer> list = new ArrayList<>(array);
                                                    list.add(item);
                                                    return Collections.unmodifiableList(list);
                                                })
                                                .zip(Source.single(4))
                                                .map(pair -> {
                                                    log.info("map-pair.first：{}", pair.first());
                                                    log.info("map-pair.second:{}", pair.second());
                                                    return pair.first();
                                                })
                                                .withAttributes(ActorAttributes.withSupervisionStrategy(e -> {
                                                    log.info("withAttributes:{}", e.getMessage());
                                                    return Supervision.resume();
                                                })).runWith(Sink.seq(), actorSystem)
                                                .toCompletableFuture().get();
        assertThat(lists).containsExactly(Arrays.asList(1,2,3));
    }
```
![](https://img2020.cnblogs.com/blog/914251/202004/914251-20200402215733423-847882980.png)

方法二： 不用zip 换成mapAsync
```java
   @Test
    void name() throws ExecutionException, InterruptedException {
        final List<List<Integer>> lists = Source.single(1)
                                                .map(any -> Arrays.asList(1, 2, 3))
                                                .flatMapConcat(Source::from)
                                                .grouped(2)
                                                .mapAsyncUnordered(1, list -> Mono.just(4).map(s -> Pair.create(list,s)).toFuture())
                                                .map(pair -> {
                                                    log.info("map-pair.first：{}", pair.first());
                                                    log.info("map-pair.second:{}", pair.second());
                                                    return pair.first();
                                                })
                                                .withAttributes(ActorAttributes.withSupervisionStrategy(e -> {
                                                    log.info("withAttributes:{}", e.getMessage());
                                                    return Supervision.resume();
                                                })).runWith(Sink.seq(), actorSystem)
                                                .toCompletableFuture().get();
        assertThat(lists).containsExactly(Arrays.asList(1,2), Arrays.asList(3));
    }
}
```
运行结果
![](https://img2020.cnblogs.com/blog/914251/202004/914251-20200402220340459-297197309.png)


为什么会这样：
看下官网怎么说
> Combines elements from each of multiple sources into Pair and passes the pairs downstream.
官网demo
```java
import akka.stream.javadsl.Source;
import akka.stream.javadsl.Sink;
import java.util.Arrays;

Source<String, NotUsed> sourceFruits = Source.from(Arrays.asList("apple", "orange", "banana"));
Source<String, NotUsed> sourceFirstLetters = Source.from(Arrays.asList("A", "O", "B"));
sourceFruits.zip(sourceFirstLetters).runWith(Sink.foreach(System.out::print), system);
// this will print ('apple', 'A'), ('orange', 'O'), ('banana', 'B')
```
是不是很鸡贼：两个流中的元素数量是一致的，不一致会导致流会丢东西，以少的元素的流为基准，去生成pair。
当流中数据元素不匹配的时候非要用zip 请使用zipAll方法，他会有个default参数，当流中数据元素不匹配的时候，会以多的为准，然后用default的值去构建pair

个人建议：zip能不用就不用，如果非要用请用zipAll
