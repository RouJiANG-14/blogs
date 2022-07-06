# lldb 调试常用命令
## 设置目标程序
### 通过程序名调试
```
lldb /Applications/demo-app-ob-storyboard.app
(lldb) target create "/Applications/demo-app-ob-storyboard.app"
Current executable set to '/Applications/demo-app-ob-storyboard.app' (x86_64).
(lldb)
```
### 进入lldb之后设置程序名
```
➜  ~ lldb
(lldb) file /Applications/demo-app-ob-storyboard.app
Current executable set to '/Applications/demo-app-ob-storyboard.app' (x86_64).
(lldb)
```
### 调试可执行文件
```
➜  demo-app-hook git:(dark-mode) ✗ lldb -w Products/demo_app_hook.framework/demo_app_hook
(lldb) target create "Products/demo_app_hook.framework/demo_app_hook"
Current executable set to 'Products/demo_app_hook.framework/demo_app_hook' (x86_64).
(lldb)
```
## 断点

### 设置断点

#### 设置入口
```
(lldb) b -[NSObject init]
Breakpoint 1: where = libobjc.A.dylib`-[NSObject init], address = 0x000000000000a3a8
```
#### 给某个方法下断点
```
(lldb) breakpoint set --method Append
Breakpoint 4: 55 locations.
(lldb)
```
#### 指定类的某个方法
```
(lldb) breakpoint set -n "-[AppendText Append:]"
Breakpoint 6: where = demo-app-ob-storyboard`-[AppendText Append:] + 7 at AppendText.m:13:12, address = 0x0000000100001ac5
(lldb)
```
简写

```
br s -n "-[AppendText Append:]"
```


### 查看断点
```
(lldb) breakpoint list
Current breakpoints:
1: name = '-[NSObject init]', locations = 1
  1.1: where = libobjc.A.dylib`-[NSObject init], address = libobjc.A.dylib[0x000000000000a3a8], unresolved, hit count = 0

2: name = 'delete', locations = 1
  2.1: where = CoreData`-[NSPersistentHistoryChangeRequestToken delete], address = CoreData[0x00000000002fcbd0], unresolved, hit count = 0

(lldb)
```
### 删除断点
```
(lldb) breakpoint delete
About to delete all breakpoints, do you want to do that?: [Y/n] y
All breakpoints removed. (2 breakpoints)
(lldb)
```
## 启动程序

### process launch
### run
### r

## 调试命令
这里和idea命令做对比
* 跳过断点（F9）
  * thread continue
* 步入（F7）
  * thread step-in
* 步出（F8）
  * thread stop-out
* 继续执行
  * c
* 查看变量
    * p 变量名
    * print 变量名
* 修改方法返回值
  * `thread return <value>`
* 查看线程列表
  * thread list
```
    lldb) thread list
   Process 45369 stopped
 thread #1: tid = 0x17b21f, 0x0000000100001ac5 demo-app-ob-storyboard`-[AppendText Append:](self=0x00000001002d9850, _cmd="Append:", name=@"sadf") at AppendText.m:13:12, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
  thread #9: tid = 0x17b26c, 0x00007fff679dc25a libsystem_kernel.dylib`mach_msg_trap + 10, name = 'com.apple.NSEventThread'
  thread #13: tid = 0x17bdf6, 0x00007fff679dd92e libsystem_kernel.dylib`__workq_kernreturn + 10
  thread #14: tid = 0x17c121, 0x00007fff679dd92e libsystem_kernel.dylib`__workq_kernreturn + 10
  thread #15: tid = 0x17c163, 0x00007fff679dd92e libsystem_kernel.dylib`__workq_kernreturn + 10
  thread #16: tid = 0x17c164, 0x00007fff679dd92e libsystem_kernel.dylib`__workq_kernreturn + 10
```

* 查看调用栈
  * thread backtrace
```
    (lldb) thread backtrace
    thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
   frame #0: 0x0000000100001ac5 demo-app-ob-storyboard`-[AppendText Append:](self=0x00000001002d9850, _cmd="Append:", name=@"sadf") at AppendText.m:13:12 [opt]
    frame #1: 0x000000010000195b demo-app-ob-storyboard`-[DetailController viewDidLoad](self=0x00000001002dc200, _cmd=<unavailable>) at DetailController.m:20:35 [opt]
    frame #2: 0x00007fff2d43817d AppKit`-[NSViewController _sendViewDidLoad] + 87
    frame #3: 0x00007fff2d492d0e AppKit`_noteLoadCompletionForObject + 643
    frame #4: 0x00007fff2d3994ad AppKit`-[NSIBObjectData nibInstantiateWithOwner:options:topLevelObjects:] + 1930
    frame #5: 0x00007fff2d41f93a AppKit`-[NSNib _instantiateNibWithExternalNameTable:options:] + 647
    frame #6: 0x00007fff2d41f5be AppKit`-[NSNib _instantiateWithOwner:options:topLevelObjects:] + 143
    frame #7: 0x00007fff2d41e92f AppKit`-[NSViewController loadView] + 345
    frame #8: 0x00007fff2d41e676 AppKit`-[NSViewController _loadViewIfRequired] + 72
    frame #9: 0x00007fff2d41e5f3 AppKit`-[NSViewController view] + 23
    frame #10: 0x00007fff2d6a29bf AppKit`+[NSWindow windowWithContentViewController:] + 41
    ......
```
```
(lldb) run
Process 45369 launched: '/Applications/demo-app-ob-storyboard.app/Contents/MacOS/demo-app-ob-storyboard' (x86_64)
2020-06-02 11:45:28.635549+0800 demo-app-ob-storyboard[45369:1552927] -------------hook method -------------
2020-06-02 11:45:28.914460+0800 demo-app-ob-storyboard[45369:1552927] [Nib Loading] Failed to connect (nameTest) outlet from (ViewController) to (NSTextFieldCell): missing setter or instance variable
demo-app-ob-storyboard was compiled with optimization - stepping may behave oddly; variables may not be available.
Process 45369 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x0000000100001ac5 demo-app-ob-storyboard`-[AppendText Append:](self=0x0000000100300be0, _cmd="Append:", name=@"sadf") at AppendText.m:13:12 [opt]
   10
   11  	@implementation AppendText
   12  	- (NSString *)Append:(NSString *)name {
-> 13  	    return [NSString stringWithFormat:@"你好 %@", name];
   14  	}
   15  	@end
Target 0: (demo-app-ob-storyboard) stopped.
(lldb) p name
(NSTaggedPointerString *) $0 = 0x4efa213d7d9a3739 @"sadf"
(lldb) print name
(NSTaggedPointerString *) $1 = 0x4efa213d7d9a3739 @"sadf"
(lldb)
```


## 退出
```
exit
```
## 参考
[手把手教你给企业微信 Mac 客户端去除水印 - X140Yu’s Blog](https://x140yu.github.io/2018-11-24-crack-wew/)
[Tutorial — The LLDB Debugger](https://lldb.llvm.org/use/tutorial.html#)