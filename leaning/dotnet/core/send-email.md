# 发送邮件的小功能(.net core 版)
 前言：

   使用.net core 开发有一段时间了，期间从.net core 2.0 preview1 到 preview2 又到core 1.1 现在2.0正式版出来了。又把项目升级至2.0了。目前正在用2.0进行开发。期间也遇到了不少问题。在这里进行总结一下。

    最近工作内容就是job的迁移工作，从Framework迁移到.net Core上。体会到了两个框架的不同之处。以及使用过程中体会到的1.1和2.0的不同 以及Framework和Core的不同。首先说一下2.0和Framework的不同吧。刚开始用的preview1 用的时候感觉差异不是特别的大。有些方法2.0的实现方式和Framework实现的方式一样。命名空间也没有变，方法名也没有变。当然了有些东西还是不一样的。或者说有些方法没有实现。后来升级到preview2后。突然感觉那里不对。后来仔细观察了一下原来是类库变了。preview1类库是netcore2.0。preview2类库是.netstandard2.0。总体来说升级影响不是特别的大。后来降到1.1 差别就出来了。很多方法1.1没有实现。或者说用别的方法给实现了。最头疼的可能就是反射的那块了。几乎每次都要getRuntimeXXX一次。很是烦人。2.0的语法就和Framework反射的语法是一致的。很是方便。现在升级到2.0反射那块没有变，依旧可以用。应该是保留了1.1的那种过度的写法。或者说保留了那种写法。

更新：2017-9-15 事实证明：反射那块不兼容，getRuntime***();2.0保持和Framework用法一样，1.1那个过渡的写法2.0已经不兼容了。

内容：

  内容比较乱吧。自己想到哪里就讲到哪里吧。

  我有这么一个需求：将razor视图加载之后生成的html获取出来。我用的视图引擎，加载执行，之后将执行的结果进行返回过来。

IViewRenderService
更新：2017-17-27

RazorViewEngine.FindView（）方法有点小问题，无法识别绝对路径。

如果要识别绝对路径，需要用GetView（）方法。用法GetView（viewAbsolutePath:string,viewAbsolutePath:string,IsMainPage:bool），具体参数没有详细研究，我目前是这么用的。

详见github 上的issue https://github.com/aspnet/Mvc/issues/4936 

用法呢：当然我需要进行依赖注入。services.AddScoped<IViewRenderService, ViewRenderService>();对于ViewRenderService需要的依赖注入，其实mvc框架中这些已经注入过了。直接拿来用就可以。

我是这么用的 

 var userResumeAttachmentString = await _viewRenderService.RenderToStringAsync("_ResumeForEmail", resume);
 

说明一下： 传的第一参数是视图名称。或者视图文件所在路径也可以，第二参数是加载视图所需要的model。

 说一下发邮件的问题。由于Core1.1没有system.net.mail 。发送邮件一时间成了难题。有难难题就有人解决，于是mailkit出现了，用法呢和Framework发送邮件的方式大致是一样的。

        /// <summary>
        ///发送邮件
        /// </summary>
        /// <param name="receive">接收人</param>
        /// <param name="sender">发送人</param>
        /// <param name="subject">标题</param>
        /// <param name="body">内容</param>
        /// <param name="attachments">附件</param>
        /// <returns></returns>
        public bool SendMail(string receive, string sender, string subject, string body, byte[] attachments = null)
        {
            string displayName = _configuration["Mail:Name"];
            string from = _configuration.GetSection("Mail").GetSection("Address").Value;
            var fromMailAddress = new MailboxAddress(displayName, from);
            var toMailAddress = new MailboxAddress(receive);
            var mailMessage = new MimeMessage();
            mailMessage.From.Add(fromMailAddress);
            mailMessage.To.Add(toMailAddress);
            if (!string.IsNullOrEmpty(sender))
            {
                var replyTo = new MailboxAddress(displayName, sender);
                mailMessage.ReplyTo.Add(replyTo);
            }
            var bodyBuilder = new BodyBuilder() { HtmlBody = body };
            mailMessage.Body = bodyBuilder.ToMessageBody();
            mailMessage.Subject = subject;
            return SendMail(mailMessage);

        }
        private bool SendMail(MimeMessage mailMessage)
        {
            try
            {
                var smtpClient = new SmtpClient();
                smtpClient.Timeout = 10 * 1000;   //设置超时时间
                string host = _configuration.GetSection("Mail").GetSection("Host").Value;
                int port = int.Parse(_configuration.GetSection("Mail").GetSection("Port").Value);
                string address = _configuration.GetSection("Mail").GetSection("Address").Value;
                string password = _configuration.GetSection("Mail").GetSection("Password").Value;
                smtpClient.Connect(host, port, MailKit.Security.SecureSocketOptions.None);//连接到远程smtp服务器
                smtpClient.Authenticate(address, password);
                smtpClient.Send(mailMessage);//发送邮件
                smtpClient.Disconnect(true);
                return true;

            }
            catch 
            {
                return false;
            }

        }
 

 发邮件这个问题解决了。可是还有一个需求，那就是发送邮件附件。当时查了国外的资料，也没有弄明白。后来自己慢慢的试出来了。具体做法就是将字符串转化为byte数组。然后借用bodyBuilder的一个方法进行附件的添加。

            if (attachments != null)
            {
                bodyBuilder.Attachments.Add("用户简历.pdf", attachments);
            }
 

这里有个坑，那就是添加附件的时候需要将附件的文件名和格式直接指定。

到这里基本已经完成了。我用单元测试进行测试了一番。关于在控制台进行依赖注入的用法，我能想到就是在单元测试中使用。很方便。比如有时候需要进行数据提交的测试。我们可以在单元测试中造假数据，然后向对应的action提交数据。获取返回结果。不用在界面的一次次的填充数据了。

 1         [Fact]
 2         public void TestSendEmail()
 3         {
 4             var builder = new ConfigurationBuilder()
 5                .SetBasePath(Directory.GetCurrentDirectory())
 6                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
 7             var k1 = Directory.GetCurrentDirectory();
 8             builder.AddEnvironmentVariables();
 9             var Configuration = builder.Build();
10             var serviceProvider = new ServiceCollection()
11                      .AddSingleton<IConfigurationRoot>(Configuration)
12                      .AddScoped<MsgServices, MsgServices>()
13                      .BuildServiceProvider();
14             var msgService = serviceProvider.GetService<MsgServices>();
15             var k = msgService.SendMail("xiaoqu@cnblogs.com", "1483523635@qq.com", "测试", "你好我进行了测试");
16             Assert.True(k);
17         }
需要在单元测试项目的目录中添加appsetting.json文件。（我项目已经升到2.0了，但这些用法还是1.1的旧的用法。）

我的appsetting.json 文件 (敏感信息已删除)

1   "Mail": {
2     "Name": "博客园招聘频道",
3     "Address": "emailAddress",
4     "Host": "xxxxxxx",
5     "Port": 25,
6     "Password": "password"
7   }
 

单元测试显示效果：



发送附件的测试没有放在单元测试中，因为视图需要加载。显示一张截图吧



最后还有一个问题，还么有解决，就是HTML to PDF中文乱码的问题。我用的是node.js 参考的是微软官网的。英文没有问题，中文就乱码，乱码原因目前正在查找中。期间也尝试过用jspdf 但是中文乱码问题解决的方式并不是很理想。目前常见的解决方式是：获取指定元素所在块的内容，然后进行截图，截图分辨率很低，没有使用。也试过DinkToPdf 我看了一点源码，主要核心的的功能使用的wkhtmltopdf的一个类库，他是在这个类库上进行了一层封装。中文乱码问题解决了，但是不是特别的优雅。考虑到跨平台，也没有使用。目前没有合适的解决方案。正在找node.js中文乱码的原因。希望有人用过的给提点建议。很是头疼的中文乱码问题。

 写了这么多的代码最终在界面上显示的功能就是一个小按钮。


### source
https://www.cnblogs.com/qulianqing/p/7413640.html