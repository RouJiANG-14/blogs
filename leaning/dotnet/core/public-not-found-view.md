# 记一次 .net core publish 之后找不到视图文件的问题
周末将VS从15.3 升级到15.5 ，之后又将VS版本由社区版，升级为企业版。
于是问题来了：
> 项目publish 之后找不到视图文件了？？？

问题很是蛋疼，后来仔细想了一下，也没有动什么东西。查看了SKD 还是 `2.0.0`的，publish 的时候我用的是命令行，和VS没有关系。于是也没有仔细排查啊问题的根源，今天查看`*.csproj`文件发现了问题的根源：
```
 <PropertyGroup>
    <TargetFramework>netcoreapp2.0</TargetFramework>
    <MvcRazorCompileOnPublish>True</MvcRazorCompileOnPublish>
    <TypeScriptToolsVersion>2.5</TypeScriptToolsVersion>   
  </PropertyGroup>
```
原来这里不知道什么时候将` <MvcRazorCompileOnPublish>True</MvcRazorCompileOnPublish>` 设置为true了，于是手动改false。熟悉的视图文件又在项目的发布文件夹中出现了。