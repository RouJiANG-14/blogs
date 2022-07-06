# Java 枚举那点事
[TOC]

最近有需求，想存自定义的枚举值，比如
```
 HOTLINE("Hotline")
```
我想存 `Hotline` 于是研究了一下Java的枚举问题

如下数据库的Entity (贫血模型哈)
```
@Entity
@Table(name = "complaint")
public class Complaint {
    @Id
    @GeneratedValue
    private Long id;

    private CaseOrigin origin;
}
```
枚举
```
public enum CaseOrigin {
    HOTLINE("Hotline"),
    EMAIL("mail/fax/email"),
    WALK_IN("Walk-in"),
    OTHER("Others");
 
    public String value() {
        return value;
    }
    
    private final String value;
    
    private CaseOrigin(String value) {
        this.value = value;
    }
}
```
用的是Spring Boot 自带的 Hibernate
Hibernate 提供了两种方便的注解
* 1     也就是默认的注解 ，存是的 1，2，3，4，5 之类的数字
```
   @Enumerated(EnumType.ORDINAL)
    private CaseOrigin origin;
```
* 2 这是存枚举的name 如 ： `OTHER("Others")` 存的是`OTHER`
```
   @Enumerated(EnumType.STRING)
    private CaseOrigin origin;
```
但是这两种方式，都不符合我的需求，我想存的是 `Others`
于是，找到了目前为止最优雅的方式

实现接口 `AttributeConverter` 重写接口的方法，很表意，就不解释了。
```

public class CaseOriginConverter implements AttributeConverter<CaseOrigin, String> {
    
    @Override
    public String convertToDatabaseColumn(CaseOrigin attribute) {
        return attribute.value();
    }
    
    @Override
    public CaseOrigin convertToEntityAttribute(String dbData) {
      return CaseOrigin.formDbValue(dbData);
    }
}

```
枚举我们也要改造一下，当然,如果不想改造枚举类。在类`CaseOriginConverter` 重写`convertToEntityAttribute(String dbData) ` 就要费点事了，比如`switch`,`反射`（最优雅的方式 ）
```
public enum CaseOrigin {
    HOTLINE("Hotline"),
    EMAIL("mail/fax/email"),
    WALK_IN("Walk-in"),
    OTHER("Others");
    
    
    public String value() {
        return value;
    }
    
    private final String value;
    
    public static final Map<String, CaseOrigin> dbValues = new HashMap<>();
    
    static {
        for (CaseOrigin value : values()) {
            dbValues.put(value.value, value);
        }
    }
    
    private CaseOrigin(String value) {
        this.value = value;
    }
    
    public static CaseOrigin formDbValue(String dbValue) {
        return dbValues.get(dbValue);
    }
}
```
最后用的地方到了
```
   @Convert(converter = CaseOriginConverter.class)
    private CaseOrigin origin;
```
这样就OK了。