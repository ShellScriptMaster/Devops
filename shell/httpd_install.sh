#/bin/bash
# 该脚本主要实现检查本机是否能够访问外部网络以及检查并且更改DNS配置,实现自动配置阿里云yum源，部署http服务并且做一定测试
# 查看本机网络信息
IP_ADDR=`ifconfig ens33 | sed -n '2p' | awk '{print$2}'`
echo -e "\033[33m IP address is  ${IP_ADDR} \033[0m"

# 测试本机是否可以访问外网
ping -c 2 8.8.8.8 
if [ `echo $?` -eq 0 ];then
  echo -e  "\033[32m 本机可以连接外网！\033[0m "
  echo -e  "\033[33m 请稍等，正在尝试ping百度  \033[0m"
  ping -c 2 www.baidu.com
  if [ `echo $?` -eq 0 ]; then
    echo -e  "\033[32m 本机DNS设置没有问题，可以访问网站域名 \033[0m"
  else
    echo -e  "\033[33m 自动设置阿里云DNS服务器 \033[0m"
    echo  "nameserver 223.5.5.5" > /etc/resolv.conf
    echo -e "\033[33m  现在准备ping百度查看网络是否可用 \033[33m "
    ping -c 2 www.baidu.com
      if [ `echo $?` -eq 0 ]; then
        echo -e  "\033[32m 网络可用 \033[0m "
      else
        echo -e  "\033[31m 网络不可用，请检查 \033[0m"
      fi 
  fi
else 
  echo -e  "\033[31m 请查看你的路由设置是否有问题 \033[0m "
fi  

# 配置阿里云yum源
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all  > /dev/null
yum makecache  fast
# 安装httpd 
yum -y install httpd 
# httpd 启动
systemctl enable httpd --now 

# se-linux disable + firewall 禁用
systemctl disable firewalld --now 
setenforce 0 
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 

# testing
echo -e  " \033[34m  shell script testing \033[0m" > /var/www/html/index.html
curl 127.0.0.1

