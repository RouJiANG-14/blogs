# Maven 项目如何用git hooks

## 背景

最近上了一个新项目，项目用的是Maven作为构建工具。提交代码前要手动执行一遍测试`mvn clean test`。自从在Gradle 项目和前端的项目中体验过git hooks 再也不想回到“原始的生活”。

于是简单研究了一下maven项目中如何使用git hook

## 原理

前段时间研究过Java构建工具的历史。

了解到maven是在ant上的一个更新，最重要的特点是引入了中心仓库的概念。

maven项目中使用git hook要以来ant的plugin去进行实现。


## 实现

根目录的pom文件

```maven
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-antrun-plugin</artifactId>
    <version>3.0.0</version>
    <inheritable>false</inheritable>
    <executions>
        <execution>
            <id>hooks</id>
            <phase>clean</phase>
            <goals>
                <goal>run</goal>
            </goals>
            <configuration>
                <target name="check">
                    <delete file="${basedir}/.git/hooks/pre-push.sample"/>
                    <chmod file="${basedir}/pre-push" perm ="777"/>
                    <copy file="${basedir}/pre-push" tofile="${basedir}/.git/hooks/pre-push">
                </target>
            </configuration>
        </execution>
    </executions>
</plugin>
```

项目的根目录的pre-push file

```bash
#！bin/sh
mvn clean test
```