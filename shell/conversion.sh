#!/bin/bash
bytes=$1
B_B=${bytes}
B_GB=`echo "${bytes}/(1024^3)" | bc`
B_MB=`echo "${bytes}/(1024^2)" | bc`
B_KB=`echo "${bytes}/1024" | bc`

if [ ${bytes} -lt 1024 ];then
  echo "${bytes} B"
elif [ ${bytes} -ge 1024 -a ${bytes} -lt `echo "1024^2" | bc` ]; then
  echo "${B_KB} B_KB"
elif [ ${bytes} -ge `echo "1024^2" | bc` -a ${bytes} -lt `echo "1024^3" | bc` ]; then
  echo "${bytes} MB"
else
  echo "${B_GB} GB"
fi