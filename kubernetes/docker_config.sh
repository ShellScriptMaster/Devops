#!/bin/bash
sed -i 's/--log-driver=journald//' /etc/sysconfig/docker
sed -i '/--exec-opt/d'  /usr/lib/systemd/system/docker.service

yum -y install epel-release  && yum -y install ansible
