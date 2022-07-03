# MYSQL 5.7 alter table 小记

mysql的alter table 本质上是通过创建临时表，然后将数据copy到临时表里，之后删除原来的表，重命名临时表 去做的alter操作

## alter table 这个操作能干啥

* 创建删除索引
* 更改列类型
* 重命名列或者表本身

## 重置自增列的起始值

不能设置值为当前DB中已经用到过的最大值。  

```sql
alter table t21 auto_increment=13;
```

## alter table 的算法

* COPY
* INPLACE

### 算法区别

* copy 这个操作一行一行的copy数据从原始表到新表， 而且不支持并发DML，但是并发查询仍然是支持的，默认使用共享锁（可以并发查询），也可指定拍他锁（并发查询和DML都不支持）
* inplace 这个操作会避免copy表数据，但是可能会重建表。在数据准备和执行阶段会进行行锁定，通常支持并发DML

mysql默认选择inplace，如果存储引擎不支持，就会选中copy。

InnoDB 对于在共享表空间中的表，使用的是COPY进行的alter table。此类会增加表的空间使用量，因为alter完成之后使用的额外空间并不会释放会操作系统。

使用INPLACE的算法场景包括：

* alter table的操作被InnoDB online DDL的特性所支持。
* 重命名表。 mysql会重命名table对应的文件，并不会做copy数据的操作。（per_file_on_table 需要打开）
* 仅修改表的元数据的操作，包括： rename column，变更列的默认值，不改变数据类型存储空间的操作
* 重命名索引
* 添加或者删除一个二级索引

## 并发控制

LOCK= DEFAULT ｜ NONE ｜ SHARED ｜ EXCLUSIVE

* DEFAULT 最大级别的并发。并发读和写 -> 并发读  -> 排它锁（依次降级）
* NONE 并发读和写，不支持就报错
* SHARED 并发读，不允许写。
* EXCLUSIVE 不允许并发读和写。

## 修改列的三种方式

* change 
  * 能够重命名列和更改列的定义，或者同时进行
  * 有更多的能力比`modify`，但是在某些方面会比较慢。 比如： 如果不是重命名的话， `change`会对列命名两次
  * 可以通过`first`/ `after`  更改列顺序
* modify
  * 能够改变列定义，但是不能改变列的名称。
  * 不是重命名的时候比`change`更加方便
  * 可以通过`first`/ `after`  更改列顺序
* alter
  * 用来更改列的默认值

demo

```sql
alter table temp_table change name name_new varchar(100);
alter table temp_table change name name varchar(100);
alter table temp_table modify name varchar(200) after id ;
alter table temp_table alter name set default '';
```

备注：
> `change`是mysql对标准sql的拓展， `modify`是mysql对oracel的兼容。
> `modify`or `change` 去更改数据类型的时候，mysql会尝试转化存在的列的值到新的类型中。

注意： 通过`change`重命名列

* 自动变更
  * 指向旧列的索引
  * 外键
* 不会自定变更
  * 生成的列和分块的表达式
  * 视图和存储过程