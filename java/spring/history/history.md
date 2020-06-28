# Spring 的历史
本文主要去介绍spring 的历史和每个版本发布的不同的功能。

# 0.9 
Spring的第一次出现在2020年的“Expert One-on-One J2EE Design and Developmen”上。

这次带来的有

- JavaBeans 配置管理
- JDBC抽象层
- MVC框架
- 事务
- AOP

更多信息看 [spring-0.9](https://github.com/HackerRookie/spring-framework-0.9)

# 1.0 
这个版本在2004年3月24日发布

- IOC
- AOP 做了升级
- application context 引入
- 更通用的事务管理
- support for source-level metadata 比如transaction注解
- 通用的DAO支持
- JDBC抽象的简化
- hibernate支持，`SessionFactory`和事务级别的` ThreadLocal Sessions`
- 支持iBATIS SQL Maps 1.3/2.0，并且集成到spring的事务级别的管理
- mail sender的抽象，
...

更多请看 [spring-1.0](https://spring.io/blog/2004/03/24/spring-framework-1-0-final-released)

# 2.X
- IOC 
  - 更简单的XML配置
  - 新的bean scope
  - 可拓展的XML
- AOP
  - 更简单的XML配置
  - 支持 @AspectJ 切片
- The Middle Tier （中间层）
  - 在XML中声明`transactions`更简单
  - JPA spring 2.0 嵌入了JPA的抽象层
  - JDBC 
    - 引入了几个新的class ` NamedParameterJdbcTemplate`,`SimpleJdbcTemplate`
- web层（spring MVC）
  - form 标签库（JSP tag lib 集成）
- 其他
  - 动态语言支持（Groovy， JRuby, BeanShell）
  -  Task scheduling
  -  Java 5的支持

更多请看 [Spring-2.X](https://docs.spring.io/spring/docs/2.0.x/reference/new-in-2.html)


# 3.X
- 基于Java 5
- Spring 的模块都单独分离出各自的jar包
-  Spring 表达式
- IOC enhance 
- [JavaConfig]()的元注解集成
- 通用的类型转化和字段格式化
- Object to XML mapping functionality (OXM) moved from Spring Web Services project
- 全面的 REST 支持
- @MVC additions
- 声明式模型验证（Declarative model validation）
- Early support for Java EE 6
- Embedded database support（HSQL, H2, and Derby）


更多请看[Spring-3.0](https://docs.spring.io/spring/docs/3.0.x/spring-framework-reference/html/new-in-3.html)

# 4.X

- get start对新人友好
- 移除deprecated包和方法
- java 8
- java EE 6和7
- Groovy bean definition DSL
- Core Container的提升
- @RestController @ReseponseBody
- AsyncRestTemplate class的添加，支持non-blocking 异步
- spring-websocket 模块的引入,支持websocket
- spring-messaging 模块 支持STOMP
- 测试提升
  - spring-test 模块包含几乎所有的新的注解，（`@ContextConfiguration`, ` @WebAppConfiguration`,`@ContextHierarchy`, `@ActiveProfiles`）

更多请看[spring-4.0](https://docs.spring.io/spring/docs/4.1.5.RELEASE/spring-framework-reference/html/new-in-4.0.html)

# 5.X

目前版本是5.3
5.X正在开发中，具体可看[what's new in spring 5.x](https://github.com/spring-projects/spring-framework/wiki/What%27s-New-in-Spring-Framework-5.x)

## 结束

接下来准备看看spring 0.9的源码
