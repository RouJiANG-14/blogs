# Transient

今天在看Java的AbstractList的源码，看到了`transient`关键字，很是好奇。因为在之前从来没有看到了，也没用到过。也没见项目的代码库里有人用。
于是好奇的研究了一下。


  ## 引入时间

  引入时间是在Java SE 7。
  JLS:[https://docs.oracle.com/javase/specs/jls/se7/html/jls-8.html#jls-8.3.1.3](https://docs.oracle.com/javase/specs/jls/se7/html/jls-8.html#jls-8.3.1.3)

  ## 有什么作用
> Variables may be marked transient to indicate that they are not part of the persistent state of an object.

变量可以被标示为`transient`，标示它不是对象持久化过程中的一部分

  ## 怎么用

我有一个类
```Java
class UserInfo implements Serializable {

/   // 这个字段标示为transient
    private transient int age;
    private String name;
    

    public UserInfo(String name, int age) {
        this.name = name;
        this.age = age;
    }
    // getter 和setter
    // ....
}
```

搞个测试


```Java
@Test
void serializableTest() {
    final UserInfo test = new UserInfo("lisi", 23);
    assertEquals("lisi", test.getName());
    // 这里age是23
    assertEquals(23, test.getAge());
    writeObjectToFile(test);
    UserInfo o = null;
    o = readToObject(o);
    assertEquals("lisi", o.getName());
    // 这里age是0 也就是int的默认值，包装类型的话是null
    assertEquals(0, o.getAge());
}
// 支撑方法
private void writeObjectToFile(UserInfo test) {
    try {
        ObjectOutputStream outputStream = new ObjectOutputStream(
            new FileOutputStream("./name.txt"));
        outputStream.writeObject(test);
        outputStream.flush();
        outputStream.close();

    } catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    }
}

private UserInfo readToObject(UserInfo o) {
    try {
        ObjectInputStream inputStream = new ObjectInputStream(
            new FileInputStream("./name.txt"));
        o = (UserInfo) inputStream.readObject();
        inputStream.close();
    } catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    }
    return o;
}
```
> 有个小坑： User类不能是内部类，一定要是一级类。



  ## spring 的@transient的不同
  | Java | Spring |
  | ---- | ------ | 
  | 关键字 | 注解 | 
  | 序列化时使用到 | 持久化数据到DB中用到 |
  | 标记为序列化是忽略掉 | 标记为持久化是忽略掉 |

  ## 能在fasterxml.jackson 中生效吗？

答案是 
> **不能的**

写个测试验证一下：
```Java
@Test
void jacksonTest() throws IOException {
    UserInfo test = new UserInfo("lisi", 23);
    assertEquals("lisi", test.getName());
    assertEquals(23, test.getAge());
    ObjectMapper mapper = new ObjectMapper();
    final String testJson = mapper.writeValueAsString(test);
    final UserInfo newUserInfo = mapper.readValue(testJson, UserInfo.class);
    assertEquals("lisi", newUserInfo.getName());
    assertEquals(23, newUserInfo.getAge());
}
```





  


