# ArchUnit自定义规则

ArchUnit自定义规则
 最近team遇到了一个问题，问题大致如下： 抽象类去封装了几个方法， 然后每个字类要去重写这个属性的set方法。
```java
@Data
public abstract class RequestMessage<U> {

    private ServiceName serviceName;

    private HttpMethod method;

    private String uri;

    private Object body;
    
}

public static class Order extends RequestMessage<List<OrderCreationResponse>> {
    public Order(String userId, List<ServiceOrderRequest> body) {
        setServiceName(ServiceName.ORDER);
        setMethod(HttpMethod.POST);
        setBody(body);
        setUri(builder -> builder.path(“/api/users/{userId}/orders”).build(userId));
    }
}
```

一不小心就会忘记，但是呢编译器又不会告诉我，只有我运行起来才会发现，和JavaScript 有点像。大多数情况下可能写完了， 然后测试一波没有问题，然后去重构，然后就会遗忘掉某些东西。。。就会导致挂了没有人知道，直到有人调用这个方法的时候才会发现。。。。

至于有没有更好方法去实现，我想应该是有的，目前的来说team没有精力去干这件工作，于是大家能不能提前发现这些问题。于是想到了ArchUnit这个好用的工具，在.net 的世界里用过[ArchTestNet](https://github.com/BenMorris/NetArchTest)(.net core ) ,[ArchTestNet](https://github.com/1483523635/ArchTestNet) .net framework & .net core 很是好用。
于是花了一个多小时去拔文档，终于被我发现了`ClassesShouldConjunction should(ArchCondition<? **super**JavaClass> condition);`就是它

在写测试的过程中发现ArchUnit还是有点挫的。比如没办法扫描抽象类的继承关系，只能通过接口去扫描
于是提取了一个接口
```java
public interface IRequestMessage<U> {
     void setServiceName(ServiceName serviceName);
     void setMethod(HttpMethod method);
     void setBody(Object body);
     void setUri(Function<UriBuilder, URI> builderURIFunction);
}
```

让原来的抽象类去实现这个借口
```java
@Data
public abstract class RequestMessage<U> implements IRequestMessage<U> {

    private ServiceName serviceName;

    private HttpMethod method;

    private String uri;

    private Object body;
    
}
```
其他的不变
ArchUnit写法如下
```java

@AnalyzeClasses(packages = “com.tw.xiaoqu”, importOptions = {DoNotIncludeJars.class, DoNotIncludeTests.class, DoNotIncludeArchives.class})
class CodingRulesTest {

  @ArchTest
  void request_message_should_call_those_methods(JavaClasses classes) {
    classes().that()
             .implement(IRequestMessage.class)//实现这个接口
             .should(shouldCallSetBodyMethod) // 应该自己有setBody方法
             .andShould(shouldCallSetServiceNameMethod)//应该自己有setServiceName方法
             .andShould(shouldCallSetMethodMethod)//应该自己有setMethod方法
             .andShould(shouldCallSetURIMethod)// 应该自己有//setRri 方法
             .check(classes);
   }

ArchCondition<JavaClass> shouldCallSetBodyMethod =
    getArchCondition(“should call setBody method”, “setBody”, “[%s] not call setBody method”);

ArchCondition<JavaClass> shouldCallSetMethodMethod =
    getArchCondition(“should call setTypeReference method”, “setMethod”, “[%s] not call setTypeMethod method”);

ArchCondition<JavaClass> shouldCallSetURIMethod =
    getArchCondition("should call setUri method", "setUri", "[%s] not call setUri method");

private ArchCondition<JavaClass> getArchCondition(String description, String methodName, String errorMessage) {
    return new ArchCondition<JavaClass>(description) {
        @Override
        public void check(JavaClass javaClass, ConditionEvents conditionEvents) {
            String name = javaClass.getName();
            //这里是排除掉RequestMessage这个抽象类
            if (!name.contains("RequestMessage") && javaClass.getMethodCallsFromSelf().stream().map(item -> item.getTarget().getName())
                         .noneMatch(m -> m.equals(methodName))) {
                conditionEvents.add(SimpleConditionEvent.violated(javaClass, String.format(errorMessage, name)));
            }
        }
    };
}

}
```
功能完成。
### 参考
[ArchUnit User Guide](https://www.archunit.org/userguide/html/000_Index.html)
http://www.throwable.club/2019/02/16/java-archunit-research/
