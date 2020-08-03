# K8s 常见问题及解决方案

1. 我已经通过k8s官方提供的解决方案安装的docker，并且docker可以成功运行。 启动minikube的时候出现的问题 

```bash
xiaoqu@k8s2:~$ sudo minikube start --driver=none
[sudo] password for xiaoqu:
Sorry, try again.
[sudo] password for xiaoqu:
😄  minikube v1.12.1 on Ubuntu 16.04
✨  Using the none driver based on user configuration
💣  Sorry, Kubernetes 1.18.3 requires conntrack to be installed in root's path
```

> Sorry, Kubernetes 1.18.3 requires conntrack to be installed in root's path

之前在另一台虚拟机上安装minikube 就没有出现这个问题。

解决方法：

安装`conntract`，之后在此尝试启动minikube。

```shell
 sudo apt-get install conntract -y
```
参考 ：
[https://github.com/kubernetes/minikube/issues/7179](https://github.com/kubernetes/minikube/issues/7179)


----   


2. docker 的Cgroup driver 改为 systemd 

```
# (Install Docker CE)
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2
```

```
# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
```

```
# Add the Docker apt repository:
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
```

```
apt-get update && apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)
```

##### 重点来了

```
# Set up the Docker daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"], ## 这里改为了systemd
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
```

```
mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl daemon-reload
systemctl restart docker

# enable start on boot
sudo systemctl enable docker

```

参考： 
https://kubernetes.io/zh/docs/setup/production-environment/container-runtimes/

--- 

sudo kubeadm init 出现下列错误   

> [ERROR Swap]: running with swap on is not supported. Please disable swap.

解决方法：

```
sudo swapoff -a
```

永久关闭：


```bash
vim /etc/fstab
注释掉下边这行
# /dev/mapper/k8s1--vg-swap_1 none            swap    sw              0       0
```

参考

[How do I disable swap? - Ask Ubuntu](https://askubuntu.com/questions/214805/how-do-i-disable-swap)
[https://github.com/kubernetes/kubeadm/issues/610](https://github.com/kubernetes/kubeadm/issues/610)

--- 

问题：

``` 
sudo kubelet 
```

> ] failed to run Kubelet: misconfiguration: kubelet cgroup driver: "cgroupfs" is different from docker cgroup driver: "systemd"


解决 
目前也没有找到正确的姿势，唯一的方式就是重新安装docker 和 kubectl

---  

### 问题： k8s 集群搭好了 `kubectl get nodes` role是空的，如何指定节点的role

```bash
root@k8s2:~# kubectl get nodes
NAME   STATUS   ROLES    AGE   VERSION
k8s1   Ready    <none>   14h   v1.18.6
k8s2   Ready    master   15h   v1.18.6
```

答案： 
 暂时没记录 。

---

### 问题 如何查看K8s集群的版本号

答案：我是用kube admin 构建的k8s集群，用minikube构建的可能会不一样

> kubeadm version

```bash
root@k8s2:~/k8s# kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.6", GitCommit:"dff82dc0de47299ab66c83c626e08b245ab19037", GitTreeState:"clean", BuildDate:"2020-07-15T16:56:34Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
```

这里是1.18.6


### 如何删除加入集群中的节点

下线节点

```bash
root@k8s2:~# kubectl drain k8s1 --ignore-daemonsets --delete-local-data
node/k8s1 already cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-proxy-bw8mn
node/k8s1 drained
```

确认下线

```bash 
root@k8s2:~# kubectl get nodes
NAME   STATUS                        ROLES    AGE   VERSION
k8s1   Ready,SchedulingDisabled   <none>   23h   v1.18.6
k8s2   Ready                         master   23h   v1.18.6
```

删除节点

```bash
root@k8s2:~# kubectl delete node k8s1
node "k8s1" deleted
root@k8s2:~# kubectl get nodes
NAME   STATUS   ROLES    AGE   VERSION
k8s2   Ready    master   23h   v1.18.6
root@k8s2:~#
```

删除成功

### kubeadm init 如何指定pod的网络段

> sudo kubeadm init --pod-network-cidr=192.168.0.0/16

参考： https://docs.projectcalico.org/getting-started/kubernetes/quickstart

### 如何配置K8s集群的calico网络

前提

> 基于kubeadm init 指定的pod网络段。

kubeadm init 之后的coreDNS状态

```bash
root@k8s2:~/k8s# kubectl get pods --all-namespaces
NAMESPACE     NAME                           READY   STATUS    RESTARTS   AGE
kube-system   coredns-66bff467f8-l4lq5       0/1     Pending   0          65s
kube-system   coredns-66bff467f8-mqpxc       0/1     Pending   0          65s
kube-system   etcd-k8s2                      1/1     Running   0          75s
kube-system   kube-apiserver-k8s2            1/1     Running   0          75s
kube-system   kube-controller-manager-k8s2   1/1     Running   0          75s
kube-system   kube-proxy-5twv5               1/1     Running   0          65s
kube-system   kube-scheduler-k8s2            1/1     Running   0          75s
```

下载calico网络配置文件

> wget -P ~/k8s/ https://docs.projectcalico.org/v3.8/manifests/calico.yaml

编辑`calico.yaml` 修改默认网络段和你在kubeadm init指定的一致

```bash
vim calico.yaml /192.168 可快速定位
> - name: CALICO_IPV4POOL_CIDR
>   value: "10.10.0.0/16"
```

安装插件

> kubectl apply -f calico.yaml

查看状态

启动比较慢需要等大约1-2min

> watch kubectl get pods --all-namespaces 

```s
root@k8s2:~/k8s# kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-75d555c48-x87bq   1/1     Running   0          12m
kube-system   calico-node-g2rhd                         1/1     Running   0          12m
kube-system   coredns-66bff467f8-l4lq5                  1/1     Running   0          13m
kube-system   coredns-66bff467f8-mqpxc                  1/1     Running   0          13m
kube-system   etcd-k8s2                                 1/1     Running   0          13m
kube-system   kube-apiserver-k8s2                       1/1     Running   0          13m
kube-system   kube-controller-manager-k8s2              1/1     Running   0          13m
kube-system   kube-proxy-5twv5                          1/1     Running   0          13m
kube-system   kube-scheduler-k8s2                       1/1     Running   0          13m
```

安装成功。

参考：

https://www.jianshu.com/p/3de558d8b57a

## k8s 的服务如何让外网去访问

背景：
> 我在把ubuntu 装在了两个不同的虚拟机里，网络都是桥接的。这两个组成了k8s的集群，想让集群里部署的服务被我的真实的物理机访问到。

解决方式有四种：

1. hostNetwork: true 直接暴露 pod在部署pod的节点上，然后通过节点的ip加端口去访问。
   yaml 
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

![](./images/hostOnly.png)

2. hostPort 直接定义Pod网络的方式,通过宿主机和pod之间的端口映射，类似直接起docker 然后做端口映射。

yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-kube
spec:
  containers:
  - name: hello-kube
    image: paulbouwer/hello-kubernetes:1.8
    ports:
    - containerPort: 8080
      hostPort: 8081
    env:
    - name: MESSAGE
      value: "hello-kube-host-port"
```

![](./images/hostPort.png)

3. nodePort 定义网络方式

NodePort在kubenretes里是一个广泛应用的服务暴露方式。
Kubernetes中的service默认情况下都是使用的ClusterIP这种类型，这样的service会产生一个ClusterIP，这个IP只能在集群内部访问，要想让外部能够直接访问service，需要将service type修改为 nodePort。


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-kube
  labels:
    name: hello-kube
spec:
  containers:
  - name: hello-kube
    image: paulbouwer/hello-kubernetes:1.8
    ports:
    - containerPort: 8080
    env:
    - name: MESSAGE
      value: "hello-kube-node-port"
---
apiVersion: v1
kind: Service
metadata:
  name: hello-kube
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30001 # 只能在区间 30000-32767
  selector:
    name: hello-kube
```


4. LoadBalancer  只能在service上定义 

yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-kube
  labels:
    name: hello-kube
spec:
  containers:
  - name: hello-kube
    image: paulbouwer/hello-kubernetes:1.8
    ports:
    - containerPort: 8080
    env:
    - name: MESSAGE
      value: "hello-kube-load-balancer"
---
apiVersion: v1
kind: Service
metadata:
  name: hello-kube
spec:
  type: LoadBalancer
  ports:
  - port: 8080
  selector:
    name: hello-kube
```

5. ingress

创建service 和pod 的yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-kube
  labels:
    name: hello-kube
spec:
  containers:
  - name: hello-kube
    image: paulbouwer/hello-kubernetes:1.8
    ports:
    - containerPort: 8080
    env:
    - name: MESSAGE
      value: "hello-kube-load-balancer"
---
apiVersion: v1
kind: Service
metadata:
  name: hello-kube
spec:
  ports:
  - port: 8080
  selector:
    name: hello-kube
```

service 状态

```
NAME               TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
hello-kube         ClusterIP      10.111.142.96    <none>        8080/TCP         4s
```


## 集群重启之后无法使用kubelet

> The connection to the server 192.168.2.121:6443 was refused - did you specify the right host or port?

```s
1. sudo -i

2. swapoff -a

3. exit

4. strace -eopenat kubectl version
```

手动关掉 swapoff 在master 节点

## nodePort 不生效

> 设置service type为 nodePort， 理论上能在集群中任意ip均可访问，但是只能在部署pod的节点访问

暂时没找到能在kubeadm 上建立的集群的解决方案。

## port, nodePort, targetPort 分别是指什么？

port 是在k8s集群内部暴露的端口，其他sevice/pod可以通过这个端口开访问
nodePort： 也就是在k8s集群的node上暴露的端口，供外界访问。宿主机的端口。
targetPort： pod 本身自己暴露的端口，也就是k8s内部和外界访问的流量最终都会到这里。

## configMap的值变了为什么 pod引用的内容没变？

congMapYaml

```yaml
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

service with deployments Yaml

```yaml
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
---
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
          valueFrom:
            configMapKeyRef:
              name: hello-kube-config
              key: MESSAGE # 这里引用的是configMap的值
```

答案： 

当configMap作为 environment variable 加载到pod中，当configMap对应的key发生改变时，需要重启pod才能生效。

当confgiMap 作为卷mount到系统中，变更将自动生效，但是有延迟，在下次ttl检查之前不会生效，之后才会成效。


## 集群无法部署pod

解决方法： 需要安装网络插件，安装完成之后 coreDNS的pod才会启起来，之后才可以用。