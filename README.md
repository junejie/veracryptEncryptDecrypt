execute: 
    encrypt
        sudo sh src/main.sh -v -p test -e -o output -a "abc123"


    decrypt
        sudo sh src/main.sh -v -p output -d -o test -a "abc123"


how to execute the test validity
    sudo sh src/main.sh -v -p test -e -o output -a "abc123"
    sudo sh src/main.sh -v -p output -d -o testx -a "abc123"

    there should have no result 
        diff --brief -Nr  test testx/output/test

    the hash should be the same
        
        { export LC_ALL=C;cd test;
          du -0ab | sort -z; # file lengths, including directories (with length 0)
          echo | tr '\n' '\000'; # separator
          find -type f -exec sha256sum {} + | sort -z; # file hashes
          echo | tr '\n' '\000'; # separator
          echo "End of hashed data."; # End of input marker
        } | sha256sum 
        { export LC_ALL=C;cd testx/output/test;
          du -0ab | sort -z; # file lengths, including directories (with length 0)
          echo | tr '\n' '\000'; # separator
          find -type f -exec sha256sum {} + | sort -z; # file hashes
          echo | tr '\n' '\000'; # separator
          echo "End of hashed data."; # End of input marker
        } | sha256sum
