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

echo '---- next test -----'

## build test for recursive dir
if [ -d "recursive-dir" ]; then
  rm -rf "recursive-dir"
fi

mkdir "recursive-dir"
mkdir -p "recursive-dir/1"
mkdir -p "recursive-dir/2/1"
mkdir -p "recursive-dir/3/1"

## create file for recursive dir
touch "recursive-dir/1/a.txt"
echo "abc" > "recursive-dir/1/a.txt"

touch "recursive-dir/2/1/a.txt"
echo "abc" > "recursive-dir/2/1/a.txt"

touch "recursive-dir/3/1/a.txt"
echo "abc" > "recursive-dir/3/1/a.txt"

## start encrypt
sudo sh src/main.sh -v -p "recursive-dir" -e -o output -a "abc123"
sudo sh src/main.sh -v -p output -d -o "recursive-dir-x" -a "abc123"

recursive1={ export LC_ALL=C;cd "recursive-dir";
          du -0ab | sort -z; # file lengths, including directories (with length 0)
          echo | tr '\n' '\000'; # separator
          find -type f -exec sha256sum {} + | sort -z; # file hashes
          echo | tr '\n' '\000'; # separator
          echo "End of hashed data."; # End of input marker
        } | sha256sum 
recursive2={ export LC_ALL=C;cd "recursive-dir-x/output/recursive-dir";
          du -0ab | sort -z; # file lengths, including directories (with length 0)
          echo | tr '\n' '\000'; # separator
          find -type f -exec sha256sum {} + | sort -z; # file hashes
          echo | tr '\n' '\000'; # separator
          echo "End of hashed data."; # End of input marker
        } | sha256sum


if [ "$recursive1" = "$recursive2" ]; then
  echo 'ok: recursive'
else
  echo 'fail: recursive'
fi
rm -rf "recursive-dir"
echo 'done'