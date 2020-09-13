# Mysql 5.7 distinct 小记

## 背景

项目的上用的ORM框架是[tk-mybatis](https://github.com/abel533/Mapper)， 数据库连接层面用的是sharding-core和sharding-jdbc 版本都是3.0.0.M3

中间过程踩了一些坑，顺带了解了一下mysql的`distinct`和`distinctrow`的区别和`distinct`的实现原理。

## distinct实现原理

官方文档

> In most cases, a DISTINCT clause can be considered as a special case of GROUP BY. For example, the following two queries are equivalent:

通常情况下 distinct等同于group by。

## distinct和distinctrow的区别

mysql 5.7 文档

> DISTINCTROW is a synonym for DISTINCT.

distinctrow是distinct的同义词，也就是两者是一个东西。
