# [TK-Mybatis](https://github.com/abel533/Mapper)的Example的一些用法

## 背景

最近项目中使用tk-mybatis遇到了一些问题：

问题详情：

> (A=A1 and B=B1) or (A=A2 and B=B2) and C IN (C1,C2)

抽象一点：

> A or B and C

实际执行方式为：

> A or (B and C)

实际期望：

> (A or B ) and C


## 代码


有问题的代码为：

```java
    List<Map<String, String>> properties = new ArrayList<>();
    Example example = new Example(Country.class);

    properties.forEach(map -> {
        Example.Criteria criteria = example.createCriteria();
        map.forEach((key, value) -> criteria.andEqualTo(key, value));
        example.or(criteria);
    });

    Example.Criteria criteria = example.createCriteria()
        .andIn("countryname", Arrays.asList("CN", "US", "UK"));

    example.and(criteria);

    CountryMapper mapper = sqlSession.getMapper(CountryMapper.class);

    mapper.selectByExample(example);
```

最终生成的sql为：

> **(A=A1 and B=B1)** or **(A=A2 and B=B2)** and **C IN (C1,C2)**


每个粗体代表一个criteria

很明显不符合预期

## 解决方案

只能手写sql进行组装

```java
// 这里组装sql
    String sql = properties.stream()
        .map(map ->
            map.entrySet()
                .stream()
                .map(item -> String.format("`%s` = '%s'", item.getKey(), item.getValue()))
                .collect(Collectors.joining(" and ", " ( ", " ) "))
        ).collect(Collectors.joining(" or "));
//这里只有一个criteria 就可以避免问题
    example.createCriteria().andCondition(sql);

//其他一样的
    Example.Criteria criteria1 = example.createCriteria()
        .andIn("countryname", Arrays.asList("CN", "US", "UK"));
    
    example.and(criteria1);

    CountryMapper mapper = sqlSession.getMapper(CountryMapper.class);

    mapper.selectByExample(example);
```

生成sql为：

> **((A=A1 and B=B1) or (A=A2 and B=B2))** and **C IN (C1,C2)**

每个粗体代表一个criteria


## 核心解决方案

让OR语句生成一个criteria，之后就不会影响后续的步骤了。