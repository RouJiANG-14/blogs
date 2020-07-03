# Java Functional Programming

## 前提

前两天看了Java的Functional接口，觉得很是好玩。然后今天在上TDD的课，然后有一个作业（等会聊），需求很简单，觉得用普通的面向对象写法没有什么进步，也觉得没啥意思。
于是尝试用Java写类似于函数式编程的方法去实现这个需求

## 需求

- 不超过8公里时每公里0.8元
- 超过8公里则每公里加收50%长途费
- 停车等待时加收每分钟0.25元

是不是感觉很简单，一会会就搞完了。我也是这么感觉的，想一想最近看的Java源码，试一试函数式的搞法。

## 普通实现

> 这里暂不关注测试，TDD是一定要先写测试的.

```Java
public class Taxi {
    
    private static final double BASIC_UNIT_PRICE = 0.8;
    private static final int NORMAL_DISTANCE = 8;
    private static final double LONG_DISTANCE_UNIT_PRICE = BASIC_UNIT_PRICE * 0.5;
    private static final double WAIT_TIME_UNIT_PRICE = 0.25;
    // 需求一
    private double getBasicFee(int distance) {
        return distance * BASIC_UNIT_PRICE;
    }
    //需求二
    private double getLongDistanceFee(int distance) {
        return distance - NORMAL_DISTANCE <= 0 ? 0D : (distance - NORMAL_DISTANCE) * LONG_DISTANCE_UNIT_PRICE;
    }
    //需求三
    private double getWaitTimeFee(int waitTime) {
        return waitTime * WAIT_TIME_UNIT_PRICE;
    }
    // 计算方法
    public double calculate(int distance, int waitTime) {
        return getBasicFee(distance) + getLongDistanceFee(distance) + getWaitTimeFee(waitTime);
    }
}
```

是不是很简答，一眼就能看明。这么做没问题，但是想一想，你工作要一直写这样的代码是不是很无聊，对于个人成长来说这相当于没成长呀。
这代码毕业生也能写出来，工作两年也写这代码？？？

## 纯函数式实现
```Java
public class Taxi {
    
    private static final double BASIC_UNIT_PRICE = 0.8;
    private static final int NORMAL_DISTANCE = 8;
    private static final double LONG_DISTANCE_UNIT_PRICE = BASIC_UNIT_PRICE * 0.5;
    private static final double WAIT_TIME_UNIT_PRICE = 0.25;
    // 需求一
    private ToDoubleTripleIntFunction getBasicFee = (initValue, distance, any) -> initValue + distance * BASIC_UNIT_PRICE;

    // 需求二
    private ToDoubleTripleIntFunction getLongDistanceFee = (initValue, distance, any) ->
            initValue + (distance - NORMAL_DISTANCE <= 0 ? 0D : (distance - NORMAL_DISTANCE) * LONG_DISTANCE_UNIT_PRICE);

    // 需求三
    private ToDoubleTripleIntFunction getWaitTimeFee = (initValue, any, waitTime) -> initValue + waitTime * WAIT_TIME_UNIT_PRICE;
    
    public double calculate(int distance, int waitTime) {
        return getBasicFee
                .thenCompose(getLongDistanceFee)
                .thenCompose(getWaitTimeFee)
                .applyAsDouble(0D, distance, waitTime);
    }
    
    @FunctionalInterface
    private interface ToDoubleTripleIntFunction {
        double applyAsDouble(double f, int t, int u);
        
        default ToDoubleTripleIntFunction thenCompose(ToDoubleTripleIntFunction next) {
            return (double first, int second, int third) -> next.applyAsDouble(applyAsDouble(first, second, third), second, third);
        }
    }

```

是不是方法都是纯函数，没有一点副作用，写起来是不是也很优雅。 
需求里的每个实现都是纯函数的，我只关注我当前这一步的计算逻辑。具体的组装放到了外边。
