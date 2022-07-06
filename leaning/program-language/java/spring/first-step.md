# Spring Boot 菜鸟入门
最近入了Java的坑，正在学习spring boot。记录一下遇到的问题吧。  
[TOC]

## 问题一
> 请求参数的问题

`/get/bob`我想获取`bob`

```
    @RequestMapping(value = "/get/{name}")
    public String GetName(@PathVariable String name){
        return "Hello world "+name;
    }
```

`/get/?name=alice`我想获取name的值`alice`

方法一

```
 @RequestMapping(value = "/get")
    public String GetName(@RequestParam String name){
        return "Hello world "+name;
    }
```

note : 这种写法强制name必须有值。如果url为`/get`，就会得到错误提示：name必须在场

![](https://images2018.cnblogs.com/blog/914251/201807/914251-20180728113454714-1906321098.png)

方法二

```
  @RequestMapping(value = "/get")
    public String GetName( String name){
        return "Hello world "+name;
    }
```

note: 这种写法name在不在场关系都不太大。请求url可以为`/get`,name的值为`null`也可以`/get/?name=xxxx`。

## Note

`Spring Boot Url 是区分大小写的`