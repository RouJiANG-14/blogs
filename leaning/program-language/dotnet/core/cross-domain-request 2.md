# .net core 一个避免跨站请求的中间件

前提：
> 前几天看到博客园首页中有这么一篇文章：跨站请求伪造（CSRF）,刚好前段时间自己一直也在搞这个东西，后来觉得每次在form表单里添加一个@Html.AntiForgeryToken，在对应的方法上添加特性[ValidateAntiForgeryToken],很是麻烦，于是自己动手写了一个全局的中间件，只要是post请求就会生成一个表单验证的token。

话不多说，上代码；核心代码：
```
 public class GlobalValidateMiddleTool
 {
     private RequestDelegate _requestDelete;
     private IAntiforgery _antiforgery;
     public GlobalValidateMiddleTool(RequestDelegate requestDelegate,IAntiforgery antiforgery)
     {
         _requestDelete = requestDelegate;
         _antiforgery = antiforgery;
     }
    public async Task Invoke(HttpContext context)
    {
        if (context.Request.Method.ToLower() == "post")
        {
            await _antiforgery.ValidateRequestAsync(context);
        }
        await _requestDelete(context);
    }
}
 ```

一个拓展方法：
```
public static class IapplicationExt
{
    public static IApplicationBuilder UseGlobalTokenValidate(this IApplicationBuilder app)
    {
        return app.UseMiddleware<GlobalValidateMiddleTool>();
    }
}
```
使用方法：
```
app.UseGlobalTokenValidate();
```
验证一下，写了一个form表单

<form asp-action="about" method="post">
    <input type="text" id="data" name="data" />
    <input type="submit" value="test" />
</form>
对应的action 

        [HttpPost]
        public IActionResult About(string data)
        {
            if (ModelState.IsValid)
            {
                return Json(data);
            }
            return NotFound();
        }
界面：

![](https://images2017.cnblogs.com/blog/914251/201710/914251-20171030214815886-1807536027.png)

表单中填写test 点击提交按钮

 返回结果：
![](https://images2017.cnblogs.com/blog/914251/201710/914251-20171030214933636-434411176.png)


这样就表示我们的这个中间件生效了。