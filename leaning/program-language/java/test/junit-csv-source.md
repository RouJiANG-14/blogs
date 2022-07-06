# Junit测试

> 场景： if(dto.a> 0 || dto.b> 0 || dto.c.length>0 || ....)  很多个字段验证， 分之覆盖率要达到99%

原来是这么写的： 一个分支一个测试，分之多了问题就暴露出来了。第一名字难起，第二代码重复度高，控制变量似的一个个的测试。最近学了一个新方法
```
 @ParameterizedTest
    @CsvSource(value =
        {
          
            "1,hehe,C200,xxxxx,多彩色,1546608910219,2018",
            "10,he,C200,xxxxx,多彩色,1546608910219,2018",
            "10,hehe,C100,xxxxx,多彩色,1546608910219,2018",
            "10,hehe,C200,llll,多彩色,1546608910219,2018",
            "10,hehe,C200,xxxxx,彩色,1546608910219,2018",
            "10,hehe,C200,xxxxx,多彩色,1546608910200,2018",
            "10,hehe,C200,xxxxx,多彩色,1546608910219,2019"
        })
    void should_set_evaluation_rv_to_null_when_update_evaluation_and_vehicle_required_fields(
        Integer mi, String bb, String cc, String mm, String pp,
        Long dd, String my) {
     // do somethings
}
```
这样做你的测试只用写一个，控制变量就在参数上了，很省事。  
吐槽一下： `@CsvSource(value ={...})`不支持模版字符串，很无奈， 不能用 String.format()了。