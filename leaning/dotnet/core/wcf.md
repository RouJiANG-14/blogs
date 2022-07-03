#  .Net Core下使用WCF

在.net core 下的wcf 和framework下的wcf使用方式有点不太一样。在core下用wc，需要安装VS扩展Visual Studio WCF Connected Service，目前这个插件不是特别的稳定，经常会出现莫名其妙的错误，前段时间最高支持到.net standard 1.6，可是我用的是.net core 2.0 于是，在同事的提醒下，我先将 .net standard 降为1.6 调用完wcf服务后，再升级为2.0。不会出现任何错误。最近好了，升级到2.0了，直接可以在 standard 2.0下调用wcf服务了。不过插件依旧是不稳定。解决方法是，多添加几次，别怕麻烦，只要你发布的wcf服务配置没有错误。多试几次，就行了。

方法的问题：在.net core 环境中用WCF全是异步的，自动会将你的wcf服务提供的同步方法变为异步方法，具体为什么这么做，原因我还不是清楚。Framework 中则不会出现这种情况，如果是同步的，那么调用的wcf服务也是同步的，异步的还是异步的，不会进行转化。

类型的问题：现在.net core 2.0 可以直接用Framework的包 ，我在这里举个例子。

///这代表一个公用的类
namespace CNblogs.job.A
{
   public class a
  {
       public string Name{get;set;}
   }
}
//这代表WCF的服务
namespace CNBlogs.Job.WcfHost
{
   using CNBlogs.job.A;
   public class  wcfService
   {
      //这代表WCF服务中的一个测试方法
      public a Test(string name)
      {
          return new a(){Name=name};
      }
   }
}
 假设我们已经把这个服务发布在了IIS上，或者说这个服务已经跑起来了。 我们在Core中的项目已经加入这个WCF服务的引用，名称为：WcfTestService。

namespace CNBlogs.job.Core.WcfTest
{
    using CNBlogs.Job.A
    public class C 
    {
        public a GetWcfService()
        {
          var name="test"; 
          var WcfClient=new WcfTestService.WcfTestServiceClient();
          //在这里我将异步方法转化为了同步的方法
          var result=WcfClient.TestAsync(name).Result;
          //如果这时返回Result 会报错 ；无法将WcfTestService.a的类型转化为CNBlogs.Job.A.a的类型
          //我们需要用到AutoMapper进行一个类型的转化，这样才不会报错
          AutoMapper.Mapper.Initialize(c=>c.CreateMap<WcfTestService.a,,CNBlogs.Job.A.a>());
          return AutoMapper.Mapper.Map<CNBlogs.Job.A.a>(result);
        }
    }
}
 希望能够帮助到和我一样的小菜们。

 ### source
 https://www.cnblogs.com/qulianqing/p/7197302.html