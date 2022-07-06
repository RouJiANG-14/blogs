# Java 8 CompletableFuture探索1
最近一直在用响应式编程写Java代码，用的框架大概上有[WebFlux](https://docs.spring.io/spring-framework/docs/5.0.0.BUILD-SNAPSHOT/spring-framework-reference/html/web-reactive.html)(Spring)、[R2dbc](https://r2dbc.io/)、[Akka](https://doc.akka.io/docs/akka/current/index.html)...一些响应式的框架。
全都是Java写的，我于是就在想:
> 全都是Java的代码怎么搞成了响应式呢？ 是不是语言本身就支持呢？

于是找到了Java 8 的 concurrency。这个是啥呢？
写个代码看一下：
```java
@Test
void test7() throws ExecutionException, InterruptedException {
    CompletableFuture<String> future = new CompletableFuture<>();
    Runnable task = new Runnable() {
        @Override
        public void run() {
            try {
                String result = "result";
                future.complete(result);
            } catch (Exception e) {
                future.completeExceptionally(e);
            }
        }
    };
    //这里是new了一个新的线程去跑
    final Thread thread = new Thread(task);
    thread.start();
    final String s = future.get();
    assertEquals("result", s);
}
```
代码写到了这里，感觉和JS的Promise如出一辙呀：
```javaScript
it('just a promise test', function () {
    Promise.resolve('success'); // return promise
    Promise.reject('error'); // return promise
    new Promise((resolve, reject) => {
        resolve('success');
        reject('error');
    });
});
```
用`ForkJoinPool`玩一把
```Java
@Test
void test8() throws ExecutionException, InterruptedException {
    CompletableFuture<String> future = new CompletableFuture<>();
    final Runnable runnable = () -> {
        try {
            String result = "result";
            future.complete(result);
        } catch (Exception e) {
            future.completeExceptionally(e);
        }
    };

    ForkJoinPool forkJoinPool = ForkJoinPool.commonPool();
    forkJoinPool.submit(runnable);
    final String s = future.get();
    assertEquals("result", s);
}
```
写到了这里，我感觉我大概明白了所用的响应式框架里边怎么玩的了。

---
假设说不用框架纯Java的代码怎么写那些响应式代码呢？
比如说常用的操作符map，zip，reduce，group...这些要怎么玩？
```Java
@Test
void test9() throws ExecutionException, InterruptedException, TimeoutException {
    CompletableFuture<String> future = new CompletableFuture<>();
    final Runnable runnable1 = () -> {
        try {
            String result = "1";
            future.complete(result);
        } catch (Exception e) {
            future.completeExceptionally(e);
        }
    };

    CompletableFuture<String> future2 = new CompletableFuture<>();
    final Runnable runnable2 = () -> {
        try {
            String result = "2";
            future2.complete(result);
        } catch (Exception e) {
            future2.completeExceptionally(e);
        }
    };

    ForkJoinPool forkJoinPool = ForkJoinPool.commonPool();
    forkJoinPool.submit(runnable1);
    forkJoinPool.submit(runnable2);
    final List<Integer> result = future
        .whenComplete((aVoid, throwable) -> {
            if (Objects.nonNull(throwable)) {
                log.error("bla bla bla,", throwable);
            }

        })
        .thenApply(s -> Integer.parseInt(s)) // like stream Map
        .thenCombine(future2, (integer, s) -> Arrays.asList(integer, Integer.parseInt(s)))// zip
        .thenCompose(list -> CompletableFuture.completedFuture(list)) // flatMap or mapAsync
        .get(3, TimeUnit.SECONDS);
    assertThat(result)
        .containsExactly(1, 2);
}
```
这些`.thenXXX`方法都是可以换成`.thenXXXAsync`的，之间的不同就是换成另一个线程去处理，而不是当前线程继续处理。

#### 如何做reduce,collect,groupBy,orderBy操作呢？
答案：`.thenCompose`or`.thenApply`方法
```Java
@Test
void test10() throws ExecutionException, InterruptedException, TimeoutException {
    CompletableFuture<List<Integer>> future = new CompletableFuture<>();
    final Runnable runnable1 = () -> {
        try {
            future.complete(Arrays.asList(1, 3, 5));
        } catch (Exception e) {
            future.completeExceptionally(e);
        }
    };
    ForkJoinPool forkJoinPool = ForkJoinPool.commonPool();
    forkJoinPool.submit(runnable1);
    final Integer result = future
        .thenCompose(list -> CompletableFuture.completedFuture(list.stream().reduce(0, Integer::sum)))
        .get(3, TimeUnit.SECONDS);
    assertThat(result).isEqualTo(3);
}
```
#### 有没有类似于Promise.all和Promise.race之类的方法呢？
答案是有的`CompletableFuture.allOf(futures...)`和`CompletableFuture.anyOf(futures...)`


### 总结
断断续续思考了两天，心中的困惑才一点点的解开，有深度的思考是不可缺少的。


