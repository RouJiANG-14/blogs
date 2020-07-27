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
