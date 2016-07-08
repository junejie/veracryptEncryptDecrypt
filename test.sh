#!/bin/bash

f_simpletest() {
  
  sudo sh src/main.sh -v -p simpletest -e -o output -a "abc123"
  sudo sh src/main.sh -v -p output -d -o simpletestx -a "abc123"

  test1=`{ 
  export LC_ALL=C;cd simpletest;
  du -0ab | sort -z; # file lengths, including directories (with length 0)
  echo | tr '\n' '\000'; # separator
  find -type f -exec sha256sum {} + | sort -z; # file hashes
  echo | tr '\n' '\000'; # separator
  echo "End of hashed data."; # End of input marker
  } | sha256sum`

  test2=`{ 
  export LC_ALL=C;cd simpletestx/output/simpletest;
  du -0ab | sort -z; # file lengths, including directories (with length 0)
  echo | tr '\n' '\000'; # separator
  find -type f -exec sha256sum {} + | sort -z; # file hashes
  echo | tr '\n' '\000'; # separator
  echo "End of hashed data."; # End of input marker
  } | sha256sum`
  sudo rm simpletestx -rf

}

f_recursivetest() {
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

  r1=`{
    export LC_ALL=C;cd "recursive-dir";
    du -0ab | sort -z; # file lengths, including directories (with length 0)
    echo | tr '\n' '\000'; # separator
    find -type f -exec sha256sum {} + | sort -z; # file hashes
    echo | tr '\n' '\000'; # separator
    echo "End of hashed data."; # End of input marker
  } | sha256sum`

  r2=`{
    export LC_ALL=C;cd "recursive-dir-x/output/recursive-dir";
    du -0ab | sort -z; # file lengths, including directories (with length 0)
    echo | tr '\n' '\000'; # separator
    find -type f -exec sha256sum {} + | sort -z; # file hashes
    echo | tr '\n' '\000'; # separator
    echo "End of hashed data."; # End of input marker
  } | sha256sum`

  rm -rf "recursive-dir"

}

f_dirwithspace() {
  echo '---- next test -----'
  ## build test for recursive dir
  if [ -d "space dir" ]; then
    rm -rf "space dir"
  fi

  mkdir "space dir"
  mkdir -p "space dir/1"
  mkdir -p "space dir/2/1"
  mkdir -p "space dir/3/1"

  ## create file for recursive dir
  touch "space dir/1/a.txt"
  echo "abc" > "space dir/1/a.txt"

  touch "space dir/2/1/a.txt"
  echo "abc" > "space dir/2/1/a.txt"

  touch "space dir/3/1/a.txt"
  echo "abc" > "space dir/3/1/a.txt"

  ## start encrypt
  sudo sh src/main.sh -v -p "space dir" -e -o output -a "abc123"
  sudo sh src/main.sh -v -p output -d -o "space dir-x" -a "abc123"

  spacedir1=`{
    export LC_ALL=C;cd "space dir";
    du -0ab | sort -z; # file lengths, including directories (with length 0)
    echo | tr '\n' '\000'; # separator
    find -type f -exec sha256sum {} + | sort -z; # file hashes
    echo | tr '\n' '\000'; # separator
    echo "End of hashed data."; # End of input marker
  } | sha256sum`

  spacedir2=`{
    export LC_ALL=C;cd "space dir-x/output/space dir";
    du -0ab | sort -z; # file lengths, including directories (with length 0)
    echo | tr '\n' '\000'; # separator
    find -type f -exec sha256sum {} + | sort -z; # file hashes
    echo | tr '\n' '\000'; # separator
    echo "End of hashed data."; # End of input marker
  } | sha256sum`

  rm -rf "space dir"
}

runTest(){

  if [ "$r1" = "$r2" ]; then
    echo 'ok: recursive'
  else
    echo 'fail: recursive'
  fi

  if [ "$test1" = "$test2" ]; then
    echo 'ok: simpletest'
  else
    echo 'fail: simpletest'
  fi

  if [ "$spacedir1" = "$spacedir2" ]; then
    echo 'ok: simpletest'
  else
    echo 'fail: spacedir'
  fi

}

f_simpletest
f_recursivetest
f_dirwithspace
runTest
echo 'done'