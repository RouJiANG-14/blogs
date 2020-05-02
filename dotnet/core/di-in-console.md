
首先我们准备两个服务接口

    public interface IServiceA
    {
        void showConsole();
        int GetValue(int val);
    }
　　

    public  interface IServiceB
    {
        void DoWork();
        string ShowName();
    }
　　接着我们分别实现两个接口

    public class ServiceA : IServiceA
    {
        private IServiceB _serviceB { get; }
        public ServiceA(IServiceB serviceB)
        {
            _serviceB = serviceB;
        }

        public int GetValue(int val)
        {
            return val;
        }

        public void showConsole()
        {
            _serviceB.ShowName();
        }
    }
　　

    class ServiceB : IServiceB
    {
        private Microsoft.Extensions.Logging.ILogger _log { get; }

        public ServiceB(ILogger<ServiceB> logger)
        {
            _log = logger;
        }
        public void DoWork()
        {
            _log.LogInformation($" I am doing work ");
        }
        public string ShowName()
        {
            _log.LogInformation($" At Time :{DateTime.Now.ToString()} 被调用");
            return "I am ServiceB ";
        }
    }
　　在主函数中这么写

 static void Main(string[] args)
        {
            var serviceProvider = new ServiceCollection()
            .AddLogging()
            .AddTransient<IServiceB, ServiceB>()
            .AddTransient<IServiceA, ServiceA>()
            .BuildServiceProvider();

            serviceProvider.GetService<ILoggerFactory>().AddConsole(LogLevel.Debug);
            var Logger = serviceProvider
                                        .GetService<ILoggerFactory>()
                                        .CreateLogger<Program>();
            Logger.LogDebug("Starting Program");
            var serviceB = serviceProvider.GetService<IServiceB>();
            serviceB.DoWork();
            var serviceA = serviceProvider.GetService<IServiceA>();
            var k = serviceA.GetValue(12345);
            Console.WriteLine(k);
            serviceA.showConsole();
            Logger.LogInformation("All Done ");
            Console.ReadLine();
}
　　提示需要引入的Nuget包

<ItemGroup>
    <PackageReference Include="Microsoft.Extensions.DependencyInjection" Version="1.1.1" />
    <PackageReference Include="Microsoft.Extensions.Logging" Version="1.1.2" />
    <PackageReference Include="Microsoft.Extensions.Logging.Abstractions" Version="1.1.2" />
    <PackageReference Include="Microsoft.Extensions.Logging.Console" Version="1.1.2" />
  </ItemGroup>　　
　　运行结果：


 
### source
https://www.cnblogs.com/qulianqing/p/7347427.html