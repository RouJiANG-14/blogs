## datagrip bug 小记
今天遇到了一个小bug，datagrip 2020.1出现
> [S1000] Attempt to close streaming result set com.mysql.cj.protocol.a.result.ResultsetRowsStreaming@42b0babe that was not registered.
>  Only one streaming result set may be open and in use per-connection. Ensure that you have called .close() on any active result sets before attempting more queries.

查了一下，这是个jet brains 全家桶里都有的bug。 [bug](https://youtrack.jetbrains.com/issue/DBE-8481?_ga=2.67420950.666561808.1594194627-1671204354.1591262277)

## 怎么复现

非常简单： 在存储过程里然后个循环，然后循环里执行select 查询，然后将结果赋值给另一个变量，call自定义函数。

```sql
CREATE PROCEDURE test_loop()
BEGIN
    declare p1 bigint;
    declare total bigint;
    declare current varchar(100);
    set p1 = 0;
    select count(*) into total from A_table;

    label1: 
    LOOP
        IF p1 >= total THEN
            leave label1;
        END IF;

        select id into current from A_table order by id limit 1 offset p1;

        select test_func(current);

        SET p1 = p1 + 1;
        ITERATE label1;
    END LOOP label1;
    SET @x = p1;
END;

-- table 

create table A_table
(
    id   varchar(100),
    create_time datetime default CURRENT_TIMESTAMP,
    index idx_id (id)
);

-- function

create
    definer = root@`%` function test_func(id varchar(50)) returns varchar(50)
begin
    return id;
end;

```


## 如何修复
这里我用的是mysql 5.7 所以一下方案只对mysql 5.7 管用：

> 更改mysql的驱动,默认选中的是mysql， 要手动改为mysql 5.1 


![bug-image](./images/mysql-derver.jpeg)


