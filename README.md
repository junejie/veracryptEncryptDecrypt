execute
=======
    encrypt
        sudo sh src/main.sh -v -p test -e -o output -a "abc123"


    decrypt
        sudo sh src/main.sh -v -p output -d -o test -a "abc123"


how to execute the test validity
    sh test.sh
