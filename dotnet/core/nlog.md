# .net Core 2.0使用NLog
最近研究了一下NLog的使用方式，简单的入了一下门。

实现的功能，对于不同的日志，进行不同的记录，分别有系统运行日志，和个人在程序中写的异常日志。发布之后放在了IIS上。进行查看日志的信息

参考了两篇博客。 

1.http://www.voidcn.com/blog/aojiancc2/article/p-6672009.html
2.http://www.cnblogs.com/linezero/p/Logging.html
个人觉得还是第一篇写的详细。第二篇可能是大神写的吧，一些细节并没哟特别的注意到。

那两篇博客已经写很详细了，我再重复一下，以及提醒一下像我一样的小菜们，需要注意的事项，以及个人在其中的一些疑惑。

首先我们建一个Core 2.0的项目，由于目前2.0 没有正式发布，如果想用2.0 需要装preview版的vs 

我们需要引入这些包，我们会用到。这是我的*.csproj文件的部分。（在这里需要注意下,如果是Core2.0的项目直接用2.0以上包，不然在vs中运行是没有问题的，在windows环境中运行也是没有问题的，但是到了Linux中就会出问题，在 restore 时，会给你报错，让你把包升级到2.0以上。这个问题自己原来也没有注意到，本来想着这些版本控制之类的东西，肯定是向下兼容的。可是前两天，在Linux上用docker 进行测试发布的时候就出现了这个问题。）

<ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.All" Version="2.0.0-preview1-final" />
    <PackageReference Include="NLog" Version="5.0.0-beta09" />
    <PackageReference Include="NLog.Web.AspNetCore" Version="4.4.1" />
    <PackageReference Include="System.Text.Encoding.CodePages" Version="4.3.0" />
  </ItemGroup>
打开我们的startUp.cs 文件

添加下边的代码

        public void Configure(IApplicationBuilder app, IHostingEnvironment env ,ILoggerFactory loggerFactory)
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);//这是为了防止中文乱码
            loggerFactory.AddNLog();//添加NLog
            env.ConfigureNLog("nlog.config");//读取Nlog配置文件
           //other Code
        }
在ConfigServie方法中不需要进行依赖注入的配置

由于这里我们添加了读取Nlog的配置文件的信息

所以我们要添加“nlog.config的文件”

新建一个 xml文件 名称为 你的 env.ConfigureNLog("nlog.config");里边穿的字符串参数的名称。

nlog.config
在HomeControler中进行如下修改（我结合了他们两个人的用法）

 public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        static Logger Logger = LogManager.GetCurrentClassLogger();
        public HomeController(ILogger<HomeController> logger)
        {
            this._logger = logger;
        }
        public IActionResult Index()
        {
            Logger.Info("普通信息日志-----------");
            Logger.Debug("调试日志-----------");
            Logger.Error("错误日志-----------");
            Logger.Fatal("异常日志-----------");
            Logger.Warn("警告日志-----------");
            Logger.Trace("跟踪日志-----------");
            Logger.Log(NLog.LogLevel.Warn, "Log日志------------------");

            _logger.LogInformation("你访问了首页");
            _logger.LogWarning("警告信息");
            _logger.LogError("错误信息");
           // _logger.LogDebug(NLog.LogLevel.Fatal, "NLog 致命日志");
            return View();
        }
}
可能有人会疑问：构造函数中的logger是怎么穿进去的，没有进行依赖注入。我个人了解的也不是特别的深入，目测是通过app.addNlog()。进行注入的。

之后我们修改一下我们的appsetting.json文件，把其中的日志级别调整为Information的。默认是Debug的

{
  "Logging": {
    "IncludeScopes": false,
    "Debug": {
      "LogLevel": {
        "Default": "Information"
      }
    },
    "Console": {
      "LogLevel": {
        "Default": "Information"
      }
    }
  }
}
这时候我们直接运行F5在/bin/Debug/netcoreapp2.0文件夹下是看不到日志文件的，在我们的项目的根目录下打开dos窗口。dotnet restore 一下，然后dotnet run 一下访问一下那个地址，之后再进入那个文件夹就可以看到日志文件了。



对这两个文件进行说明一下，第一个是网站运行时所有的日志记录，第二个只是有我们自己写的异常日志记录。

由于我要放在iis上，所以我要发布一下，在VS中直接发布也行，用 dotnet publish 进行发布也可以我用的是第一种，发布完成之后。这个时候我们如果直接运行的话，是没有办法运行原因是发布的时候。没有将我们写的nlog.config 文件放在发布的目录中去，我们需要手动的将这个文件复制到我们的发布的目录中。（另一中解决方法是：右击文件->属性->复制到输出目录）

之后设置一下发布的这个文件夹的权限，把Everyone这个角色添加进去，并给它读写的权限。

之后在iis上绑定这个发布的目录，在应用程序池中把刚才绑定到iis上的网站，改为无托管模式。之后将网站重新启动一下，在浏览器中运行输入你绑定的域名。可以直接访问这个网址了。

如果出现一下错误。请先进入发布程序的那个文件夹，执行一下dotnet run 如果项目可以成功运行，请检查一下everyone是否有读写的权限，重启一下iis服务器。如果都不行，请重新publish。就可以解决这个问题。



这是我运行之后的生成的日志文件目录是publishoutput



 ### source
 https://www.cnblogs.com/qulianqing/p/7222177.html