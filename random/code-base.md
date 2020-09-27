# 一个项目是如何烂掉的

## 主题

今天聊一聊项目是如何烂掉的。

## 方式


### 后端

分页取数据， 分页信息藏在了response body的第一个元素里会多一个obj。

### 前端

没有代码规范，

eslint 直接干掉

eslintignore 中ignore *.js 和 *.vue
#### 导致问题
find 方法 find（_ => test）;

let result;

try {
    do something;
    result = something;
} catch() {

}
return result;

if(som) {
    do something 
} else {
    
}
