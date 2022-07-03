# 函数式编程二

## 基础

[函数式编程一](functionalProgram.md)

在java中用函数式的方式去做事情，Happy Path确实很好玩，但是编程中最不好玩的就是异常的情况。

通常函数式都是流式，然而通常不希望数据在流的过程中出现异常。 于是出现了这么三种处理方式：

1. F#中提出了[Railway Oriented Programming](https://fsharpforfunandprofit.com/rop/) 特别有意思的一个想法。

2. Try/Success/Failed 模式最早是在Twitter中提出的， 后被引入Scala的标准类库中。

3. Option/Some/None模式是另一种处理模式。

2和3 在Scala文章中有详细的说明： [FUNCTIONAL ERROR HANDLING IN SCALA](https://docs.scala-lang.org/overviews/scala-book/functional-error-handling.html)

强烈推荐去看一下，文章不长，也不枯燥。中间对比和2和3的优缺点，和使用场景。


了解了一番之后，回过头看Java的Optional弱鸡一个。


## 背景

1. 项目中用的是Java，然后处理数据是一批一批的处理，之后改成了函数式，并没有大动结构，只是用函数式给串了起来。

2. 由于传统面向对象思想的束缚，throw exception，在流中的操作原子中有出现。

3. 每个操作原子中可能会有副作用。

4。 对业务代码无感知

5. 能够给调用方返回数据


## 函数式编程最佳实「踩」践「坑」指南

函数式编程通常有这么一个原则：

> 所有在操作原子中**主动抛异常**的行为都是耍流氓。

标准的函数式异常处理模式有什么问题：无法携带异常数据。只能携带异常。

Java中有人实现了标准Scala的[Try](https://github.com/lambdista/try)。

有兴趣的可以看看，代码也很简单，一会就能看完。看完之后，自己手动实现java Optional就很轻松了。

## Try的实现增强版

1. 定义接口，用于承接数据

```Java
public interface IError<T> {
    T toSystemError();
}
```

2. 定义Try

```Java
// 定义承载数据类型为IN， 并且要实现IERROR
// 定义异常类型为ERROR
public final class Try<IN extends IError<ERROR>, ERROR> {

        // 流进来的数据
        private final IN value;
        // 承载的异常数据
        private final ERROR error;
        // 发生异常的现场
        private final Throwable exception;

// success的构造函数
        private Try(IN IN) {
            this(IN, null, null);
        }

// failed的构造函数
        private Try(IN IN, ERROR error, Throwable exception) {
            this.value = IN;
            this.error = error;
            this.exception = exception;
        }


        public boolean isSuccess() {
            return Objects.isNull(exception);
        }

        public boolean isFailed() {
            return !this.isSuccess();
        }

        public IN get() {
            return this.value;
        }
// 流中数据类型的转化
        public <R extends IError<ERROR>> Try<R, ERROR> map(Function<IN, R> mapper) {
            return getData(mapper);
        }
// 流中数据类型转化处理
        private <R extends IError<ERROR>> Try<R, ERROR> getData(Function<IN, R> mapper) {
            if (this.isFailed()) {
                return new Try<>(null, error, exception);
            }
            if (Objects.isNull(value)) {
                return new Try<>(null);
            }
            try {
                final R newValue = mapper.apply(value);
                return new Try<>(newValue);
            } catch (Exception e) {
                return new Try<>(null, value.toSystemError(), e);
            }
        }
// 类似于flatMap，但是又不是。
        public <R> R transformTo(Function<IN, R> converter) {
            return converter.apply(value);
        }
// 这里参照CompletableFuture的做法，并且参照了NodeJs的做法（error first）
        public void whenComplete(BiConsumer<Throwable, ERROR> afterFailed, Consumer<IN> afterSuccess) {
            if (this.isSuccess()) {
                afterSuccess.accept(value);
            } else {
                afterFailed.accept(exception, error);
            }
        }
        
// 这里是Try的构造。
        public static <I extends IError<E>, R extends IError<E>, E> Try<R, E> apply(Supplier<R> supplier) {
            return new Try<>(supplier.get());
        }

    }
```

4. 用法

```java
class TryDemoTest {

    class TestClass implements TryDemo.IError<String> {

        private String id;

        public TestClass(String id) {
            this.id = id;
        }

        @Override
        public String toSystemError() {
            return id;
        }
    }

    @Test
    void shouldExecNextStep() {
        final TestClass test =
            TryDemo.Try.apply(() -> new TestClass("start"))
                .map(testClass -> new TestClass("1"))
                .map(testClass -> new TestClass("2"))
                .get();

        assertEquals("2", test.id);
    }

    @Test
    void shouldNotExecNextStep() {
        Function<TestClass, TestClass> exception = testClass -> {
            throw new NullPointerException();
        };
        TryDemo.Try.apply(() -> new TestClass("start"))
            .map(testClass -> new TestClass("1"))
            .map(exception)
            .map(testClass -> new TestClass("3"))
            .whenComplete((e, data) -> {
                // log ERROR and get Error data
                assertTrue(true);
                assertEquals("1", data);
            }, successData -> {
                // handle success Logic
                assertFalse(true);
            });
    }
}
```

## 总结

这里和原始的Try的不同在于原始的Try是一个抽象类，Success和Failed都是其具体的实现，没法同时持有success和failed，导致它没法持有异常数据。
