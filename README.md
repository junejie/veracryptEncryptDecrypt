Requirements
===========
    
    docker
    veracrypt

update docker
=============

    1. pull the junejie/veracrypt docker
    2. run it

        docker run -it junejie/veracrypt

    3. do the update
    4. do the docker commit

        docker commit hash junejie/veracrypt

    5. do push

        docker push 

execute
=======

    encrypt
        sudo /bin/bash src/main.sh -v -p test -e -o output -a "abc123"
        sudo /bin/bash src/main.sh -v -p "/tmp/remote-dir" -e -o "/tmp/output" -a "abc123"

        

    decrypt
        sudo /bin/bash src/main.sh -v -p output -d -o test -a "abc123"
        sudo /bin/bash src/main.sh -v -p "/tmp/output/remote-dir" -d -o "/tmp/remote-dir-x" -a "abc123"

test
====

    cd test/
    sh test.sh
