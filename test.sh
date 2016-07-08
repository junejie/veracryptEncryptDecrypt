#!/bin/bash

sudo sh src/main.sh -v -p simpletest -e -o output -a "abc123"
sudo sh src/main.sh -v -p output -d -o simpletestx -a "abc123"

test1={ export LC_ALL=C;cd simpletest;
          du -0ab | sort -z; # file lengths, including directories (with length 0)
          echo | tr '\n' '\000'; # separator
          find -type f -exec sha256sum {} + | sort -z; # file hashes
          echo | tr '\n' '\000'; # separator
          echo "End of hashed data."; # End of input marker
        } | sha256sum 
test2={ export LC_ALL=C;cd simpletestx/output/simpletest;
          du -0ab | sort -z; # file lengths, including directories (with length 0)
          echo | tr '\n' '\000'; # separator
          find -type f -exec sha256sum {} + | sort -z; # file hashes
          echo | tr '\n' '\000'; # separator
          echo "End of hashed data."; # End of input marker
        } | sha256sum



if [ "$test1" = "$test2" ]; then
  echo 'ok: simpletest'
else
  echo 'fail: simpletest'
fi

sudo rm simpletestx -rf