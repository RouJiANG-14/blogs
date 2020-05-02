# Lodash踩坑记录
一直在用lodash 这个框架，最近踩了一个坑 
`reverse` 这个函数是mutable的 ，后边去查了文档
```
Note: This method mutates array and is based on Array#reverse.
```
果然是没有看清文档， 于是和一个精通前端的人请教了一下:

> lodash 有几个函数是mutable，大部分是immutable的

于是整理了一下， 下边的函数都是mutable的
`fill`,`pull`,`pullAll `,`pullAllBy`,`pullAllWith `,`pullAt`,`remove `,`reverse `,`assign `,`assignIn`,`assignInWith `,`assignWith `,`defaults `,`defaultsDeep `,`merge `,`mergeWith `,`set `,`setWith `,`unset `,`update `,`updateWith `,`prototype.reverse()`