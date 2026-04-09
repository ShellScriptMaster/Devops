#!/bin/bash
read -p 'what is your machine number   '  node

nmcli connection modify eth0 ipv4.method manual  ipv4.addresses 192.168.4.$node/24 connection.autoconnect yes
ifdown eth0
ifup eth0
hostnamectl set-hostname node$node
sed -i "4aserver_id=$node" /etc/my.cnf
sed -i '$avalidate_password_policy=0' /etc/my.cnf
sed -i  '$avalidate_password_length=4' /etc/my.cnf
systemctl restart mysqld
password=`grep -i 'temporary password'  /var/log/mysqld.log | awk '{print $11}' `
mysqladmin  -uroot -p"$password"  password '123456'
