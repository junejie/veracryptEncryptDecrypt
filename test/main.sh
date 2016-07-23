#/bin/bash

#this file is called from makefile

docker pull junejie/veracrypt:latest
j_pwd=`pwd`
#cd test ; j_pwd=`pwd`;cd ../
{
    docker run --name test-vera -d -v $j_pwd:/data -it ub-veracrypt
} || {
    echo 'failed to run'
    docker stop test-vera
    docker rm test-vera
    docker run --name test-vera -d -v $j_pwd:/data -it ub-veracrypt
}
docker ps
{
    docker exec test-vera sh /data/test/docker-main.sh
} || {
    echo 'failed to execute'
    docker stop test-vera
    docker rm test-vera
}
