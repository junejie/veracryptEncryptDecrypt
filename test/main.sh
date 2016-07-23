#/bin/bash

echo "from test"
#docker pull junejie/veracrypt:latest
j_pwd=`pwd`
docker run --name test-vera -d -v $j_pwd:/data -it ub-veracrypt
docker ps
docker stop test-vera
docker rm test-vera

