# MacOS app 逆向准备
## 理论知识
### 什么是[逆向](https://zh.wikipedia.org/wiki/%E9%80%86%E5%90%91%E5%B7%A5%E7%A8%8B)
> 逆向工程（Reverse engineering），又称反向工程，是一种技术过程，即对一项目标产品进行逆向分析及研究，从而演绎并得出该产品的处理流程、组织结构、功能性能规格等设计要素，以制作出功能相近，但又不完全一样的产品。逆向工程源于商业及军事领域中的硬件分析。其主要目的是，在无法轻易获得必要的生产信息下，直接从成品的分析，推导产品的设计原理。

> 逆向工程可能会被误认为是对知识产权的严重侵害，但是在实际应用上，反而可能会保护知识产权所有者。例如在集成电路领域，如果怀疑某公司侵犯知识产权，可以用逆向工程技术来寻找证据。

### 逆向用途
主要用于产品分析，知识产权保护，软件安全。

### 逆向方式
1. 网络分析
 > 通过抓包工具进行流量分析，之后篡改接口数据控制客户端的行为。

2. 静态分析
 > 通过砸壳，反汇编，classdump等技术来分析app的行为

3. 动态分析
> 通过分析app的运行的数据，来定位注入点，或者获取关键数据。 


### 逆向流程

                                  
界面分析 -> 动态分析  -> 静态分析 ->  |-> 修改源码 -> 替换可执行文件（可能会需要反签名和签名）
                                  |-> 创建hook的类库，动态注入到程序运行时（著名的insert_dylib）  

### 常用工具
- [XCode](https://developer.apple.com/xcode/)
- [network link conditioner]()限制Mac的网速
- [unsign]()移除签名
- [restore-symbol]()还原符号


静态分析:

* [Interface Inspector](https://www.interface-inspector.com/)

* [otool](https://www.manpagez.com/man/1/otool/) `otool -L libWeChatWork-Plugins.dylib`

* [nm]() `nm libWeChatWork-Plugins.dylib`

* [class-dump](https://github.com/nygard/class-dump)

* [Hopper Disassembler]()

动态分析：
* [firda]()
```bash
frida-trace -m "-[WEWConversationWaterMarkMgr *]" WeChat\ Work
```
* [dtrace]()  遇到问题[osx elcapitan - Is there a workaround for: “dtrace cannot control executables signed with restricted entitlements”? - Stack Overflow](https://stackoverflow.com/questions/33476432/is-there-a-workaround-for-dtrace-cannot-control-executables-signed-with-restri/33584192)
```
 sudo dtrace -s trace.d -p 19570
```
* [lldb](https://lldb.llvm.org/)


hook 函数：

*  [ZKSwizzle](https://github.com/alexzielenski/ZKSwizzle) 
*  [Aspects](https://github.com/steipete/Aspects) 
*  [substitute](https://github.com/comex/substitute) 
*  [fishhook](https://github.com/facebook/fishhook)

嵌入目标程序：

* [mach_inject]()

* [osxinj](https://github.com/scen/osxinj)

* [insert_dylib]() 
```bash
insert_dylib --all-yes ~/learning/WeChatWork-Plugins/Build/Products/Debug/libWeChatWork-Plugins.dylib 企业微信 企业微信_pach
```
