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

    sh test.sh
