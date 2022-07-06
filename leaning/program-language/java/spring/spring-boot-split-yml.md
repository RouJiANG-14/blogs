# Spring Boot 分离配置文件

项目越做越久，配置文件也就会越来越大。**application.yml**里配置文件就会越来越大。导致大家找配置文件很是不方便。于是有些数据配置文件的东西，却放在了代码里。code review的时候问其原因，因为application.yml文件太大了，放在里边不好找。。。。

于是找了一下文档，改了一波配置文件

## 创建文件：
   `application-db-config.yml`
```yml
db:
    name: mysql
    password: 123456
```
`application-request.yml`
```yml
## 你的配置
```



### application.yml
```yml
spring:
  profiles:
    include:
      - db-config
      - request
```
有个坑：include 里的文件一定是要以**application-**开头的，然后还不能写全称。类似于`spring.profiles.active: local`自动激活application-local.yml文件

这样你的配置文件就可以分离出去了。

## 如果测试文件我想用不同的config怎么办？

有两种方法：
1. `application-test.yml`这么写
```yml
spring:
  profiles:
    include:
      - db-config-test
      - request-test
```
然后创建两个文件`application-db-config-test.yml`,`application-request-test.yml`,然后在文件里自定义你的配置需求。

### application-db-config-test.yml
```yml
db:
    name: sql-lite
    password: admin123
```

2. `application-test.yml`这么写
```yml
spring: 
    # other spring config
db:
    name: sql-lite
    password: admin123
```
这样就能愉快的玩耍了。

### 参考
[spring-boot-how-to-use-multiple-yml-files](https://stackoverflow.com/questions/23134869/spring-boot-how-to-use-multiple-yml-files)
