# .net core 自定义错误页面
####需求：自定义错误页面。并在错误页面中嵌入数据信息。

```  
    public class ResponseRewindMiddleware
    {
        private readonly RequestDelegate next;

        public ResponseRewindMiddleware(RequestDelegate next)
        {
            this.next = next;
        }

        public async Task Invoke(HttpContext context)
        {

            Stream originalBody = context.Response.Body;

            try
            {
                await next(context);
                using (var memStream = new MemoryStream())
                {
                    context.Response.Body = memStream;
                   
                    memStream.Position = 0;
                    string responseBody = new StreamReader(memStream).ReadToEnd();
                    memStream.Position = 0;
                    await memStream.CopyToAsync(originalBody);
                }

            }
            finally
            {
                context.Response.Body = originalBody;
            }


        }
    } 
```