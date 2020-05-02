最近这两周一直在修bug，修的很是痛苦，不过痛苦也是件好事，不然每天都是在做同样的事情，没有什么挑战，工作多无聊呀！ 是吧。

大致说一下背景吧：
>  这个项目是两年前开新项目，到现在一直还在开发中，一直不停的向里边加新功能。

不停的加新功能，有些类似的功能，大家不免会偷懒，基本就是一下两种：
1.  复用以前的实现，大致拿过来就用
2. 或者把以前的组件改一改直接用

这次前人用的是第一种，直接用前人的前人引进来的组件库。稍作修改就直接用， 基本没什么问题。主流浏览器都是OK的。但是有个坑爹的`IE`不能不考虑.

测试人员在IE上测发现了bug: 
> 我们在上传文件的时候，会有一个遮罩，等上传成功之后，这个遮罩会消失， 但是在`IE`里却不会消失，导致文件上传成功，遮罩依旧还在。

本人前端菜鸟一个，当时很慌，准备把这个问题给我们组里的前端大牛去处理，无奈大牛比较忙。于是开始了探索之旅。

这个初始化代码
```
  this.uploader = new FileUploader({
      url: 'URL'
      authToken: 'Bearer TOKEN'
      additionalParameter: '********'
    });
```
上传文件代码
```
this.uploader.queue.forEach(item => {
      const size = item.file.size / 1024 / 1024;
      if (size <= MAX_FILE_SIZE) {
        item.upload();
       /* 开启新的遮罩*/
       ***********
      item.onComplete = (response: string, status: number) => {
            this.uploader.clearQueue();
            // 终止当前遮罩
          };
         // handle some other logic 
          ***************
      } else {
        alert("上传失败，附件大小不可超过20M")
        this.uploader.removeFromQueue(item);
      }
```
解释一下代码： 
> 获取文件上传的队列，遍历队列元素，进行max file size 的检查， 上传文件，开启遮罩。
   订阅文件上传完成事件：清空上传队列（这里没有设置multiple），关闭遮罩


这个代码在其他浏览器里是没有问题的，但是在`IE`里会出现这么一种情况：
> 一次click 会触发两次的文件上传逻辑的代码。 导致` item.onComplete = (response: string, status: number) => {` 这行代码在第一次执行订阅时间的时候，会抛出一个 引用的object未定义的异常。  

debug了很久也没找到原因，由于mac 开windows的虚拟机很卡，mac上跑本地环境，然后在虚拟机里debug体验很差。于是准备放弃了，研究一下[文档](https://github.com/valor-software/ng2-file-upload/tree/master)，看木有推荐的姿势，觉得这个姿势不太好。github上的project上次提交时几年前的，于是很绝望，clone下来，看了两个小时的源代码，找到了好看的姿势，一切都用事件订阅的形式，不去处理其他额外的逻辑。
这是修改后的代码
初始化加了maxFileSize
```
  this.uploader = new FileUploader({
      url: 'URL'
      authToken: 'Bearer TOKEN'
      additionalParameter: '********'
     **maxFileSize: MAX_FILE_SIZE**,
    });
```
订阅开始上传每个文件的事件： 开启遮罩
```
    this.uploader.onBeforeUploadItem = () => // 开启遮罩;

```
订阅每个文件上传完成后的时间：关闭遮罩，处理其他逻辑
```
    this.uploader.onCompleteItem = (item, response, status) => {
      // 关闭遮罩
      // handle some other logic
    }

```
订阅文件添加失败的事件，也就是文件大于max file size 的事件
```
    this.uploader.onWhenAddingFileFailed = () => {
      alert（'bla bla'）;
            this.uploader.clearQueue();
    }
```
按钮点击的时候直接file upload all 就行了，其他的全交给订阅的事件去处理了
```
    this.uploader.uploadAll();

```

问题就样莫名其妙的消失了。 所以写代码要坚持用优雅的姿势，能少些一行代码，就少写一行，bug的几率也会下降一点。