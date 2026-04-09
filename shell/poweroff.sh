#!/bin/bash
for i in 192.168.1.{21,31,32,33,100}
do
ssh $i poweroff
if [ $? ! -eq 0 ];then
echo  -e   '\033[31m fail to poweroff \033[0m' && exit
fi
done

poweroff

