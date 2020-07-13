#  mysql row format 小记

| Row Format	| Compact Storage Characteristics	| Enhanced Variable-Length Column Storage	| Large Index Key Prefix Support	| Compression Support	| Supported Tablespace Types	| Required File Format |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| REDUNDANT	| No	| No	| No	| No	| system, file-per-table, general	| Antelope or Barracuda |
| COMPACT	| Yes	| No	| No	| No	| system, file-per-table, general	| Antelope or Barracuda | 
| DYNAMIC	| Yes	| Yes	| Yes	| No	| system, file-per-table, general	| Barracuda |
| COMPRESSED	| Yes	| Yes	| Yes	| Yes	| file-per-table, general	| Barracuda |

## REDUNDANT
这种格式适配旧版本的mysql。 支持InnoDB的`Abtelope`和`Barracuda`两种文件格式

## DYNAMIC

### 开启方式
 
 > 这个变量在之后会被删除。

可以同过`show global variables  like 'innodb_large_prefix'`查看状态。 5.7默认为ON。

## 默认行格式
### 查看方式
```sql
show global variables  like 'innodb_default_row_format'
```

### 设置默认行格式

> 有效值为： DYNAMIC, COMPACT, and REDUNDANT.

```sql
set @@global.innodb_default_row_format='COMPACT';

set global innodb_default_row_format='COMPACT';
```

### 查看表的默认行格式

```sql
show table status from test_db where name = 'temp_table';
-- 第二种
select * from information_schema.INNODB_SYS_TABLES where NAME like 'test_db/temp_table';
```

