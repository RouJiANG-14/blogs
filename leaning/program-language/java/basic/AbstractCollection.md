# AbstractCollection<T>

## 前文

今天看一了一天的Java的源码，终于把FunctionalInterface给搞明白了，就是一个注解，然后这个注解表示这个接口有且只能有一个抽象方法，接口的默认实现不算。

又看了Java utils下的Function包下所有的FunctionalInterface实现看了一遍，发现了Java基本类型虽然有boolean,byte，short，int, long, float, double。但是FunctionalInteface默认对基本类型的实现只有三个， int， long，double。

发现Function<T,R> 的compose和thenApply方法，很适合搞高阶函数。至少搞起来是不复杂的。

Supplier，Consumer这两个刚好是相反的，一个是提供数据的，一个是消费数据的。

Predicate 简单理解就是布尔表达式。 因为它规定了它的`test`方法，只能返回boolean值，是小的不是大的，然后还提供了三个默认实现的方法： `and`,  `or`, `negate`(取反)。

UnaryOperator extends Function<T,T> 表示它的传入和传出只能是同一种类型的值。

Bi前缀代表的是双数的意思。BiXXX 除了`BiPredicate`其他的都是有默认实现的`andThen`方法，很方便组合。

## 正文

前边的介绍完了进入正题。


看下定义：
```Java
public abstract class AbstractCollection<E> implements Collection<E> {
}
```
方法列表：
- 保护的构造函数
- `public abstract Iterator<E> iterator();`从Collection继承过来的。
- `public abstract int size();`  也是从Collection继承来的
- `public boolean isEmpty` 实现了Collection的方法。
- `public boolean contains(Object o)` 实现Collection的方法( 时间复杂度为O(n) ) 
- `public Object[] toArray()` 非泛型的  
    - 源码
    ```Java
    public Object[] toArray() {
        Object[] r = new Object[size()];
        Iterator<E> it = iterator();
        for (int i = 0; i < r.length; i++) {
            if (! it.hasNext()) // fewer elements than expected
                return Arrays.copyOf(r, i);
            r[i] = it.next();
        }
        return it.hasNext() ? finishToArray(r, it) : r;
    }
     private static <T> T[] finishToArray(T[] r, Iterator<?> it) {
        int i = r.length;
        while (it.hasNext()) {
            int cap = r.length;
            if (i == cap) {
                int newCap = cap + (cap >> 1) + 1;
                // overflow-conscious code
                if (newCap - MAX_ARRAY_SIZE > 0)
                    newCap = hugeCapacity(cap + 1);
                r = Arrays.copyOf(r, newCap);
            }
            r[i++] = (T)it.next();
        }
        // trim if overallocated
        return (i == r.length) ? r : Arrays.copyOf(r, i);
    }
    ```
    - new了一个新的Object[size()],以`size`进行遍历，避免了数组越界的`IndexOutOfBoundsException`异常
    - 避免了iterator中的元素比size少的情况。
    - 又处理iterator中的元素比size多的情况。
    - 这里有个知识点： 数组的最大长度是Integer.MAX_VALUE - 8
- `public <T> T[] toArray(T[] a)` 泛型的，这个和非泛型的类似，有一点不同就是数组长度分配的问题。其中有反射，所以如果知道长度还是提前分配好是最好的
    ```java
     T[] r = a.length >= size ? a :
                  (T[])java.lang.reflect.Array
                  .newInstance(a.getClass().getComponentType(), size);
    ```
- add 方法没有实现
- remove方法 时间复杂度也是O(n)
- public boolean containsAll(Collection<?> c)   时间复杂度是O(m*n) 实现是单独遍历每个C的元素去判断contains
- `public void clear()` O(n) 
  


















