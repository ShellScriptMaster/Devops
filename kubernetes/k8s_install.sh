systemctl disable firewalld --now 
iptables -F 
setenforce 0 
swapoff -a
yum -y install ipvsadm

echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf  
sysctl -p


yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-9.noarch.rpm
sed -i 's|^#baseurl=https://download.example/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*
rm -rf epel-cisco-openh264.repo

yum -y install bridge-utils

modprobe br_netfilter
echo 'br_netfilter' >> /etc/modules-load.d/bridge.conf

echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-ip6tables=1' >> /etc/sysctl.conf
sysctl -p

yum -y install yum-utils
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

vim /etc/docker/daemon.json
{
  "data-root": "/data/docker" ,
  "exec-opts":["native.cgroupdriver=systemd"] ,
  "log-driver": "json-file" ,
  "log-opts": {
    "max-size": "100m",
    "max-file": "100"
  } ,
  "insecure-registries": ["harbor.jacky.com"] ,
  "registry-mirrors": ["https://z0uzjl54.mirror.aliyuncs.com"]

}

https://github.com/Mirantis/cri-dockerd/releases/download/v0.4.3/cri-dockerd-0.4.3.arm64.tgz
tar -xf cri-dockerd-0.4.3.arm64.tgz
cp cri-dockerd/cri-dockerd   /usr/bin/

git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
cp  packaging/systemd/cri-docker* /usr/lib/systemd/system/
systemctl daemon-reload 
systemctl restart cri-docker.socket


systemctl restart docker
systemctl restart cri-docker.socket
systemctl restart cri-docker.service

systemctl enable docker --now 
systemctl enable cri-docker.socket --now 
systemctl enable cri-docker.service --now 

yum -y install https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.29/rpm/aarch64/kubeadm-1.29.0-150500.1.1.aarch64.rpm
yum -y install https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.29/rpm/aarch64/kubectl-1.29.0-150500.1.1.aarch64.rpm
yum -y install https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.29/rpm/aarch64/kubelet-1.29.0-150500.1.1.aarch64.rpm


yum -y install https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.29/rpm/x86_64/cri-tools-1.29.0-150500.1.1.x86_64.rpm
yum -y install https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.29/rpm/x86_64/kubernetes-cni-1.3.0-150500.1.1.x86_64.rpm
yum -y install https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.29/rpm/x86_64/kubelet-1.29.15-150500.1.1.x86_64.rpm
yum -y install https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.29/rpm/x86_64/kubeadm-1.29.15-150500.1.1.x86_64.rpm
yum -y install https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.29/rpm/x86_64/kubectl-1.29.15-150500.1.1.x86_64.rpm



使用NAT 远程连接到ecs上
NAT --> 创建DNAT --> 公网端口222私网端口22 VPC ip 192.168.4.10 --> VPC创建路由表 0.0.0.0/24下一跳NAT网关


kubeadm config images pull  --- 查看kubeadm 引导安装需要什么镜像

registry.aliyuncs.com/google_containers/kube-apiserver:v1.29.15
registry.aliyuncs.com/google_containers/kube-controller-manager:v1.29.15
registry.aliyuncs.com/google_containers/kube-scheduler:v1.29.15
registry.aliyuncs.com/google_containers/kube-proxy:v1.29.15
registry.aliyuncs.com/google_containers/coredns:v1.11.1
registry.aliyuncs.com/google_containers/etcd:3.5.10-0
registry.aliyuncs.com/google_containers/pause:3.9
registry.k8s.io/pause:3.10

kubeadm init --apiserver-advertise-address=192.168.4.20 --image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version 1.29.15 --service-cidr=10.10.0.0/12  --pod-network-cidr=10.244.0.0/16  \
 --cri-socket unix:///var/run/cri-dockerd.sock  --ignore-preflight-errors=all

kubeadm reset -f --cri-socket unix:///var/run/cri-dockerd.sock
rm -rf /etc/kubernetes/pki
rm -rf /etc/kubernetes/manifests
rm -rf $HOME/.kube/config


kubeadm join 192.168.4.20:6443 --token ufk2cv.7eb38nvw5hsex9fo --cri-socket unix:///var/run/cri-dockerd.sock  --discovery-token-ca-cert-hash sha256:d5e4ef1e9ddbe27516da011f0c63d4a487ae4870171fc43edab3603f6573a9ff


工作节点需要有admin.conf文件指定API server
mkdir -p $HOME/.kube
scp master:/etc/kubernetes/admin.conf $HOME/.kube/config
chmod 600 $HOME/.kube/config


所有的node 都需要导入calico & pause镜像 并且pause镜像要重新改名

下载calico
https://github.com/projectcalico/calico/releases

解压后导入镜像
docker load -i calico-cni.tar
docker load -i calico-kube-controllers.tar
docker load -i calico-node.tar
docker load -i calico-typha.tar

修改Calico 网络策略 BGP/Vxlan/IPIP
vim calico-typha.yaml

# Enable IPIP
- name: CALICO_IPV4POOL_IPIP
  value: "Always"
# Enable or Disable VXLAN on the default IP pool.
- name: CALICO_IPV4POOL_VXLAN
  value: "Never"
# Enable or Disable VXLAN on the default IPv6 IP pool.
- name: CALICO_IPV6POOL_VXLAN
  value: "Never"
  修改集群子网
- name: CALICO_IPV4POOL_CIDR
  value: "10.244.0.0/16"

kubectl apply -f calico-typha.yaml 

/var/lib/kubelet/kubeadm-flags.env --> 指定了kubeadm 的容器接口以及镜像地址
systemctl enable kubelet --now



calico/cni:v3.31.6
calico/kube-controllers:v3.31.6
calico/node:v3.31.6
calico/typha:v3.31.6
registry.k8s.io/pause:3.10
registry.aliyuncs.com/google_containers/coredns:v1.11.1
registry.aliyuncs.com/google_containers/kube-apiserver:v1.29.15
registry.aliyuncs.com/google_containers/kube-controller-manager:v1.29.15
registry.aliyuncs.com/google_containers/kube-proxy:v1.29.15
registry.aliyuncs.com/google_containers/kube-scheduler:v1.29.15
