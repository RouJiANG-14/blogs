# 记一次结巴分词.net core 2.0版 nuget发布过程
###最近用到分词考虑很久，选用了结巴分词，原因见博客[Lucene.net(4.8.0) 学习问题记录五: JIEba分词和Lucene的结合，以及对分词器的思考](http://www.cnblogs.com/dacc123/p/8431369.html) 
既然选好了，难就开始行动吧 。
查了.net core版的JIEba分词目前已经有人迁移了
  1.  [https://github.com/linezero/jieba.NET](https://github.com/linezero/jieba.NET) 不过是net core 1.1版本，看到上边有issue也没有人处理，感觉好像作者不维护了。
  2. [https://github.com/SilentCC/JIEba-netcore2.0](https://github.com/SilentCC/JIEba-netcore2.0)，这个是fork上边的然后自己升级到.net core 2.0 和Lucene结合了。由于我没有用Lucene，所以这个对我来说作用不大。
考虑了很久最终决定fork第一个，然后自己纯粹的升级到.net core 2.0 就行了。
实际升级过程并没有难度。很快就升级上去了。地址：[https://github.com/1483523635/jieba.NetCore](https://github.com/1483523635/jieba.NetCore)
准备使用的时候发现没有可用的nuget包，连1.1的nuget包都没有。我彻底绝望了。
.net core 下开发没有nuget包？让我在项目中引用dll？ 太蛋疼了。
于是开启了首次发布nuget的过程。
1. 注册个账户
2.创建一个api key 然后保存下来
3. 打开解决方案 可以看到一共有三个项目： 分别是Analyser（类库），jieba.NET(控制台输出)，Segmenter(类库)。
由于Segmenter项目没有引用别的项目 ，于是准备先发布这个nuget 
首先要下载[nuget.exe](https://www.nuget.org/downloads)，根据自己需要下载对应的版本，然后将nuget.exe 所在的路径添加到环境变量中去。
然后命令行进入该项目 
```nuget setApiKey <my_api_key>```
成功之后会有以下提示信息：`已保存Nuget库和符号服务器的API 秘钥`
``` nuget spec```
提示：`已成功创建 *.nuspec` ,记事本打开进行编辑
![](https://images2018.cnblogs.com/blog/914251/201802/914251-20180228211526539-946961692.png)
根据需要自行修改内容
`nuget pack Segmenter.csproj`
出现错误：
`无法将类型为“System.String”的对象强制转换为类型“NuGet.Frameworks.NuGet.Frameworks1070507.NuGetFramework”。`有人反馈说是nuget.exe 版本问题，我换了nuget版本可是问题依旧存在，后来在Stack Overflow 上找到了答案：替换为dotnet pack 就行了。
`dotnet pack `
成功之后出现：successfully create package ****.nupkg
之后将生成的 nupkg文件上传到nuget上就行了
`nuget push *.nupkg <you api key >`
出现错误`Source  paramter was not specified ` 
google一下看到确实有这个问题 后来在github上找到了答案 :
正确的做法是：
`nuget push *.nupkg <you api key> -Source https://api.nuget.org/v3/index.json`
成功push上去了
![](https://images2018.cnblogs.com/blog/914251/201802/914251-20180228212858388-1492952393.png)
之后就可以在nuget上看到了
目前发布了两个结巴分词的nuget
![](https://images2018.cnblogs.com/blog/914251/201802/914251-20180228213042068-1589001249.png)
每次上传都要进行审核，审核通过之后才可以被外界访问。
以后大家可以在nuget里搜索关键字`结巴分词`就能够找到nuget包了
![](https://images2018.cnblogs.com/blog/914251/201802/914251-20180228213459904-1594906624.png)
###补充一下
如果是vs2017 发布nuget更简单了详见[vs 2017 发布nuget](https://docs.microsoft.com/zh-cn/nuget/quickstart/create-and-publish-a-package-using-visual-studio)