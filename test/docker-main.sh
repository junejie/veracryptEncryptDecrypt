#/bin/bash

#this file is call inside the docker

cd /data
echo '-------'
echo 'pwd: ' `pwd` 
echo '-------'
sh test/test.sh