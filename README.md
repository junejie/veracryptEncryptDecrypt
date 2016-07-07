execute
=======

    encrypt
        sudo sh src/main.sh -v -p test -e -o output -a "abc123"


    decrypt
        sudo sh src/main.sh -v -p output -d -o test -a "abc123"

test
====

    sh test.sh
