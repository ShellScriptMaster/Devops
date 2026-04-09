#!/b1in/bash
#before you use this script ,you should be aware that if registry address have been modify
#configure the imgages-registry
if [ ! -d /etc/docker/ ];then
mkdir /etc/docker
touch /etc/docker/daemon.json
file=/etc/docker/daemon.json
echo { > $file
sed -i '$a\\t"exec-opts":["native.cgroupdriver=systemd"],' $file
sed -i '$a\\t"registry-mirrors":["https://hub-mirror.c.163.com"],' $file
sed -i  '$a\\t"insecure-registries":["192.168.1.100:5000","registry:5000"]' $file
echo } >> $file
fi
##########################################################

#pull all images from img_registry
registry='192.168.4.100:5000'
curl -s  $registry/v2/_catalog > ./registry.txt 
awk -F[ '{print $2}' ./registry.txt  > ./catalog.txt
awk -F] '{print $1}' ./catalog.txt > ./ALL_IMG.txt
colunms=`awk -F\" '{print NF}' ./ALL_IMG.txt`
count=2
 while 
[ $count -lt $colunms ]
do 
awk -F\" "{print \$$count}" ./ALL_IMG.txt   > ./img_name.txt
img_name=`awk '{print $0 }' ./img_name.txt`

curl -s $registry/v2/$img_name/tags/list > ./i_t.txt 
tag=`awk -F\" 'NR==1{print $8}' ./i_t.txt`
echo "$img_name:$tag"
docker pull $registry/$img_name:$tag
let count+=2
done
rm -rf ./registry.txt ./catalog.txt  ./ALL_IMG.txt ./img_name.txt  ./i_t.txt ./images.txt
