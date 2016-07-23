#/bin/bash

#this file is call inside the docker

cd /data
ls -lh
echo '-------'
echo 'pwd: ' `pwd` 
echo '-------'
cd test
sh test.sh