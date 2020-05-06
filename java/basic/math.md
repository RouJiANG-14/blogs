# Math
---
## Math.ceil

主要是聊一聊`Math.ceil()` 这个函数，众所周知这个函数是向上取整时用到的，最常用的场景是数据库分页查询，手动拼写sql（offset， limit）时用到。

然而这个函数返回的`double`类型的，在使用的时候还要进行一次强转int，用起来很是费劲。 

### 为什么Java要强转，JS却不用？
写JS的时候前端分页，一直用的lodash的[_.ceil()](https://lodash.com/docs/4.17.15#ceil)，也不记得有强转呀。 后来用代码跑了一遍
```
typeof Math.ceil(11) =>"number"
```
恍然大悟： 
> JS里是没有int，double，float这些类型的，这些类型统称为Number

[MDN上](https://developer.mozilla.org/en-US/docs/Glossary/Number)说:
> In  [JavaScript](https://developer.mozilla.org/en-US/docs/Glossary/JavaScript) , **Number** is a numeric data type in the  [double-precision 64-bit floating point format (IEEE 754)](http://en.wikipedia.org/wiki/Double_precision_floating-point_format) . In other programming languages different numeric types exist; for example, Integers, Floats, Doubles, or Bignums.

### 为什么Java要返回double类型的，而不是int类型的？
看下函数签名
![](../images/math.ceil.png)
接受的是个`double`类型的参数，如果返回`int`就会出问题，因为两者表示的数据范围不一致。

来个测试
```
@Test
void test5() {
    final double maxDouble = Double.MAX_VALUE;
    final int maxInt = Integer.MAX_VALUE;

    final int intResult = (int)Math.ceil(maxDouble);
    assertEquals(maxInt, intResult);

    final double doubleResult = Math.ceil(maxDouble);
    assertEquals(maxDouble, doubleResult);
}
```
测试是绿的。

这就解释了为啥`Math.ceil()`返回double了。


### 另外一个有意思的现象
看测试
```
@Test
void test6() {
    final double doubleResult = Math.ceil(100L/11);
    assertEquals(10D, doubleResult);
}
```
然测试挂了。。。返回的是居然是`9.0`.
![](../images/math.ceil.test.failed.png)
一步一步剖析一下
![](../images/math.ceil.test.failed.reason.png)
提取个变量就找到问题了，常见的问题，一不小心就会出问题。。。
```
@Test
void test6() {
    final double result = 100L / 11D;
    final double doubleResult = Math.ceil(result);
    assertEquals(10D, doubleResult);
}
```
稍微改一下，测试又绿了。
