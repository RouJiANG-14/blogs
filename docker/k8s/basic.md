# K8s 命令基础

## Namespace

### 创建：

* kubectl create namespace xiaoqu
* kubectl apply -f namespace.yaml

namespace.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: xiaoqu
```

注意

* 命名空间名称满足正则表达式[a-z0-9]([-a-z0-9]*[a-z0-9])?,最大长度为63位

### 删除

* kubectl delete namespace xiaoqu

获取所有namesapce

* kubectl get namespaces

注意

* 删除一个namespace会自动删除所有属于该namespace的资源。
* default和kube-system命名空间不可删除。

## Deployments

管理pod的扩容和收缩。pod的生死归Deployments管。

* 如果删除service，deployments依旧会存在，并且pod也依旧存在。
* 如果删除pod，deployments依旧存在，并且会去创建新的pod， service 依旧存在。
* 如果删除deployments，pod会被删除，

## services

services 本质上是通过pod的上的label selector 对一组pod进行汇总，路由分发，负载均衡等操作。

## pod

### 注意

通过yaml创建的pod 不可通过修改yaml，修改pod的属性，只能删除pod，然后再去apply yaml 创建新的。

