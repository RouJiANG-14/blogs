# Java 小技巧

## 如何优雅合并多个数组

> Steam.of(steam...)

```java
    List<String> list1 = Arrays.asList("1", "2");
    List<String> list2 = Arrays.asList("3", "4");
    List<String> list3 = Arrays.asList("5", "6");

    List<String> mergedList = Stream.of(list1.stream(), list2.stream(), list3.stream())
        .flatMap(r -> r)
        .collect(Collectors.toList())
;
    System.out.println(mergedList); // [1, 2, 3, 4, 5, 6]
```

## 如何优雅的进行flatMap

场景一： 取到每个元素进行转化为list，之后进行flatMap

```java
    List<String> list1 = Arrays.asList("1", "2");
    List<Integer> collect = list1.stream()
        // 这里做了个map操作，将单个元素转化为list
        .map(Arrays::asList)
        // 这里将list进行拍平
        .flatMap(Collection::stream)
        // 这里进行了一次map操作
        .map(Integer::parseInt)
        .collect(Collectors.toList());
    System.out.println(collect);

```

场景二： 取出list的中每个元素对应的子项列表

```java
// 数据结构
class A { 
    List<B> subItems;
}

```

```java
// 代码实现一： 这种场景下flatMap放在这里就有点尴尬了
    List<A> listA;
    listA.stream()
        .map(a -> a.getSubItems())
        .flatMap(r -> r.getSteam())
        .collect(Collectors.toList())
// 代码实现二： 这种实现会好一点，但是差别不大，
    listA.stream()
        .flatMap(a -> a.getSubItems().stream())
        .collect(Collectors.toList())

```