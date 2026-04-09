#!/bin/bash
read -p 'input the docker-distribution ip  ' docker_harbor
#start up docker



#configure registry
file=/etc/docker/daemon.json
> file
echo { > ${file}
sed -i '$a\\t"exec-opts":["native.cgroupdriver=systemd"],' ${file}
sed -i '$a\\t"registry-mirrors":["https://hub-mirror.c.163.com"],' ${file}
sed -i  '$a\\t"insecure-registries":["'"${docker_harbor}"':5000","registry:5000"]' ${file}
# quote var need to use '"${var}"' in sed
echo } >> ${file}
sed  -i '/exec-opt/d'  /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
#load images to localhost

Exists=`docker images | awk 'NR==2{print $1}'`
if [ -z ${Exists} ];then
echo -e '\033[31m there is no images, Start loading images \033[0m'
docker images
read -p 'where is your images  ' img_path
for images in ${img_path}/*.tar.gz
do
docker load -i ${images}
done
else
  echo -e '\033[33m we have images now , no need to loading images\033[0m'
  docker images
fi

#upload images to registry
REPO_PORT="${docker_harbor}:5000"
docker images | awk 'NR>1{print$1}'  >> ORIGIN_IMG.txt
docker images | awk 'NR>1{print$2}'  >> ORIGIN_TAG.txt
awk -F/ '{print $2}'   ORIGIN_IMG.txt >> IMG_NAME.txt
LINES=`sed -n '$=' ORIGIN_IMG.txt`
for num in `seq 1 ${LINES} `
do
ORIGIN_IMG=`sed  -n  "${num}p"  ORIGIN_IMG.txt`
ORIGIN_TAG=`sed  -n  "${num}p"  ORIGIN_TAG.txt`
IMG_NAME=`sed -n "${num}p" IMG_NAME.txt`

docker tag   ${ORIGIN_IMG}:${ORIGIN_TAG}  ${REPO_PORT}/${IMG_NAME}:${ORIGIN_TAG}

docker push  ${REPO_PORT}/${IMG_NAME}:${ORIGIN_TAG}
docker rmi k8s.gcr.io/${IMG_NAME}
#docker rmi  $REPO_PORT/$IMG_NAME:$ORIGIN_TAG
#echo  "  $ORIGIN_IMG:$ORIGIN_TAG  $REPO_PORT/$IMG_NAME:$ORIGIN_TAG"

done

rm -rf ORIGIN_IMG.txt ORIGIN_TAG.txt IMG_NAME.txt
curl ${REPO_PORT}/v2/_catalog

for img_name in `docker images | awk 'NR>1{print$1}' | awk -F/ '{print$2}'`
do
  curl ${REPO_PORT}/v2/${img_name}/tags/list
done