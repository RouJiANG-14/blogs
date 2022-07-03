# web api的新玩法
 前言：

     目前大多数的.net core 项目的web api 都是用的json作为数据传输格式，或者说几乎是所有的都是，可是有没有想过换一种数据传输格式怎么处理，比如XML，或者谷歌首推的Protobuf数据传输格式？对于这种请求，我们要怎么处理呢？比如相同的url 只是想用不同数据格式, api/Values.json | api/Values.xml 这又怎么处理？

 正文：

    首先既然默认得是json格式，我们首先拿json开刀。

    新建一个 Core 2.0的web api 项目。进入默认的ValueController 中

        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }
正常情况下我们默认请求的url是 api/values 然后取到上述数据 默认的json格式。

我们现在变一下 请求api/values.json 怎么样系统会识别吗？我们试一下，不好意思系统并没有鸟我，什么都没有给我。

 



那怎么样让系统能够识别呢？其实和简单。FormateFilterAttribute 就行了。我们改造一下。

        [HttpGet("api/Values.{format}"),FormatFilter]
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }
　　我们再次请求 api/values.json 



 好了取到数据了，如果我们把后缀换成.xml 怎么样？是不是就可以用xml进行数据传输了？

我们试一试。



天真是要付出代价的，原因是什么呢？因为默认的json格式的数据。所以加上FormatFilterAttribute只是进行了一个过滤的作用，并没有起到注册类型的作用。

想解决这个问题需要引入新的nuget包

 <PackageReference Include="Microsoft.AspNetCore.Mvc.Formatters.Xml" Version="2.0.0" />
然后在startup.cs 的configureServices中注册xml 类型。

        public void ConfigureServices(IServiceCollection services)
        { 
            services.AddMvc(options=> {
                options.FormatterMappings.SetMediaTypeMappingForFormat("xml", "application/xml");
               
            });
        }
　然后我们访问api/values.xml 



 

 

 

 

 

终于得到我们想要的数据了。

### source
https://www.cnblogs.com/qulianqing/p/7564438.html