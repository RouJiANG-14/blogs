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

## 扩容回滚等常用命令

```s
## 扩容
kubectl scale deployment nginx-deployment --replicas 10
## 自动拓展
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80
## 更新镜像 还可以更新其他东西比如ENV, 
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
## 回滚 可通过 --to-revision 指定版本
kubectl rollout undo deployment/nginx-deployment
## 查看版本记录
kubectl rollout history deployment
## 获取pods带着label
kubectl get pods --show-labels
## 获取运行着的service的yaml
kubectl get service hello-kube -o yaml
## pod 更新策略
kubectl get rs
```


## 常用yaml模版
 
### service 

```
apiVersion: v1
kind: Service
metadata:
  name: hello-kube-d
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: hello-kube-d
```

### deployments

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-kube-d
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-kube-d
  template:
    metadata:
      labels:
        app: hello-kube-d
    spec:
      containers:
      - name: hello-kube-d
        image: paulbouwer/hello-kubernetes:1.8
        ports:
        - containerPort: 8080
        env:
        - name: MESSAGE
          value: hello-kube-d
```

### pods

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-kube
spec:
  hostNetwork: true
  containers:
  - name: hello-kube
    image: paulbouwer/hello-kubernetes:1.8
    ports:
    - containerPort: 8080
    env:
    - name: MESSAGE
      value: "hello-kube"
```

### namespaces

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: xiaoqu
```

### configMap
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello-kube-config
  labels:
    name: hello
data:
  MESSAGE: "message"
  name: "hello"
```