#!/bin/bash
#查看内核信息
a=`uname -r`
#查看操作系统
b=`cat /etc/redhat-release`
#查看主机名称
c=`echo $HOSTNAME`
#查看本机ip地址
d=`ifconfig ens33 | sed -n '/broadcast/{p}' | awk '{print $2}'`
#查看内存总容量
e=`free | awk '/Mem/{print $2}'`
#查看内存剩余容量
f=`free | awk '/Mem/{print $NF}'`
#查看swap容量
g=`free | awk '/Swap/{print $2}'`
#查看swap剩余容量
h=`free | awk '/Swap/{print $4}'`
#查看磁盘信息
i=`df -h | awk 'BEGIN{print "文件系统 容量 已用 可用"}{print $1,$2,$3,$4}' | column -t`
#cpu1.5.15分钟的平均负载
j=`w | sed -n  '/load average/{p}' | awk 'BEGIN{print "一分钟负载 五分钟负载 十五分钟负载"}{print $(NF-2),$(NF-1),$NF}' | column -t`
#总用户数量
k=`awk 'END{print NR}' /etc/passwd`
#进程数量
l=`ps aux | wc -l`
#系统登录用户数量
m=`who | wc -l`


#查看内核信息
a=`uname -r`
#查看操作系统
b=`cat /etc/redhat-release`
#查看主机名称
c=`echo $HOSTNAME`
#查看本机ip地址
d=`ifconfig ens33 | sed -n '/broadcast/{p}' | awk '{print $2}'`
#查看内存总容量
e=`free | awk '/Mem/{print $2}'`
#查看内存剩余容量
f=`free | awk '/Mem/{print $NF}'`
#查看swap容量
g=`free | awk '/Swap/{print $2}'`
#查看swap剩余容量
h=`free | awk '/Swap/{print $4}'`
#查看磁盘信息
i=`df -h | awk 'BEGIN{print "文件系统 容量 已用 可用"}{print $1,$2,$3,$4}' | column -t`
#cpu1.5.15分钟的平均负载
j=`w | sed -n  '/load average/{p}' | awk 'BEGIN{print "一分钟负载 五分钟负载 十五分钟负载"}{print $(NF-2),$(NF-1),$NF}' | column -t`
#总用户数量
k=`awk 'END{print NR}' /etc/passwd`
#进程数量

l=`ps aux | wc -l`
#系统登录用户数量
m=`who | wc -l`
#cpu型号
n=`lscpu | awk '/型号名称/{print $2,$3,$4,$5,$6,$7}'`
#cpu内核数量
o=`awk '/processor/{core++} END{print core}' /proc/cpuinfo`
#占用内存资源最多的10个进程
p=`ps --no-headers -eo comm,rss | sort -k2 -n |tail -10`
#查看网卡进流量
q=`ifconfig ens33 | awk  '/RX packets/{print$3}'`
#查看网卡出站流量
s=`ifconfig ens33 | awk  '/TX packets/{print$3}'`

echo "************************本机主要参数列表********************" 

echo "内核信息:$a"

echo "操作系统:$b"

echo "主机名称:$c"

echo "本机ip地址:$d"

echo "内存总容量:$e"

echo "内存剩余容量:$f"

echo "swap容量:$g"

echo "swap剩余容量:$h"

echo "磁盘信息:$i"

echo "cpu1.5.15分钟的平均负载:$j"

echo "用户数量:$k"

echo "进程数量:$l"

echo "系统登录用户数量:$m"

echo "cpu型号:$n"

echo "cpu内核数量:$o"

echo "占用内存资源最多的10个进程:$p"

echo "网卡进流量:$q"

echo "网卡出站流量:$s"
