# JUnit 异常测试
JUnit  异常测试
1. 上古写法
```java
    @Test
    void name() {
        boolean hasException = false;
        String exceptionMessage = null;
        try {
            check();
        } catch (RuntimeException e) {
            hasException = true;
            exceptionMessage = e.getMessage();
        }
        assertEquals("runtime", exceptionMessage);
        assertTrue(hasException);
    }

    void check() {
        throw new RuntimeException("runtime");
    }
```
2. 普通写法（易错的）
check message 和异常类型
 ```java
    @Test
    void name() {
       assertThrows(RuntimeException.class, () -> check(), "aaa");
    }

    void check() {
        throw new RuntimeException("runtime");
    }
```
这个测试我们发现异常message 不对但是测试也能过。
扒一扒源码
![](https://img2020.cnblogs.com/blog/914251/202004/914251-20200402201617949-1769992280.png)

发现消费message 居然测试不是异常的消息，而是异常不是期待的，和没有异常的情况去消费的。
2.1 普通写法
```java
   @Test
    void name() {
        final RuntimeException runtimeException = assertThrows(RuntimeException.class, () -> check());
        assertEquals("runtime", runtimeException.getMessage());
    }

    void check() {
        throw new RuntimeException("runtime");
    }
```
3.流式写法
```java
     @Test
    void name() {
        assertThatThrownBy(() -> check())
            .isInstanceOf(RuntimeException.class)
            .hasMessage("runtime");
    }

    void check() {
        throw new RuntimeException("runtime");
    }
```
个人认为流式写法目前的认知范围内是最优雅的。