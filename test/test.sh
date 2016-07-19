#!/bin/bash

if [ -f out.txt ]; then
  sudo rm "test-output.txt"
fi

sudo touch "test-output.txt"
f_simpletest() {

  mkdir simpletest
  touch 1.txt
  echo "1" > "simpletest/1.txt"
  touch 2.txt
  echo "2" > "simpletest/2.txt"
  touch 3.txt
  echo "3" > "simpletest/3.txt"
  
  sudo /bin/bash ../src/main.sh -v -p simpletest -e -o output -a "abc123"
  sudo /bin/bash ../src/main.sh -v -p output -d -o simpletestx -a "abc123"

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
  rm simpletest -rf
  rm simpletestx -rf
  rm output -rf

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
  sudo /bin/bash ../src/main.sh -v -p "recursive-dir" -e -o output -a "abc123"
  sudo /bin/bash ../src/main.sh -v -p output -d -o "recursive-dir-x" -a "abc123"

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
  sudo /bin/bash ../src/main.sh -v -p "space dir" -e -o output -a "abc123"
  sudo /bin/bash ../src/main.sh -v -p output -d -o "space dir-x" -a "abc123"

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


f_dirremotedir() {
  echo '---- next test -----'
  ## build test for recursive dir
  if [ -d "/tmp/remote-dir" ]; then
    rm -rf "/tmp/remote-dir"
  fi

  if [ -d "/tmp/output" ]; then
    rm -rf "/tmp/output"
  fi

  if [ -d "/tmp/remote-dir-x" ]; then
    rm -rf "/tmp/remote-dir-x"
  fi

  mkdir "/tmp/remote-dir"
  mkdir -p "/tmp/remote-dir/1"
  mkdir -p "/tmp/remote-dir/2/1"
  mkdir -p "/tmp/remote-dir/3/1"

  ## create file for recursive dir
  touch "/tmp/remote-dir/1/a.txt"
  echo "abc" > "/tmp/remote-dir/1/a.txt"

  touch "/tmp/remote-dir/2/1/a.txt"
  echo "abc" > "/tmp/remote-dir/2/1/a.txt"

  touch "/tmp/remote-dir/3/1/a.txt"
  echo "abc" > "/tmp/remote-dir/3/1/a.txt"

  ## start encrypt
  sudo /bin/bash ../src/main.sh -v -p "/tmp/remote-dir" -e -o "/tmp/output" -a "abc123"
  sudo /bin/bash ../src/main.sh -v -p "/tmp/output" -d -o "/tmp/remote-dir-x" -a "abc123"

  remotedir1=`{
    export LC_ALL=C;cd "/tmp/remote-dir";
    du -0ab | sort -z; # file lengths, including directories (with length 0)
    echo | tr '\n' '\000'; # separator
    find -type f -exec sha256sum {} + | sort -z; # file hashes
    echo | tr '\n' '\000'; # separator
    echo "End of hashed data."; # End of input marker
  } | sha256sum`

  remotedir2=`{
    export LC_ALL=C;cd "/tmp/remote-dir-x/output/remote-dir";
    du -0ab | sort -z; # file lengths, including directories (with length 0)
    echo | tr '\n' '\000'; # separator
    find -type f -exec sha256sum {} + | sort -z; # file hashes
    echo | tr '\n' '\000'; # separator
    echo "End of hashed data."; # End of input marker
  } | sha256sum`

  if [ -d "/tmp/remote-dir" ]; then
    sudo rm -rf "/tmp/remote-dir"
  fi

  if [ -d "/tmp/output" ]; then
    sudo rm -rf "/tmp/output"
  fi

  if [ -d "/tmp/remote-dir-x" ]; then
    sudo rm -rf "/tmp/remote-dir-x"
  fi
}


f_dirremotespacedir() {
  echo '---- next test -----'
  ## build test for recursive dir
  if [ -d "/tmp/remote dir" ]; then
    rm -rf "/tmp/remote dir"
  fi

  if [ -d "/tmp/output 1" ]; then
    rm -rf "/tmp/output 1"
  fi

  if [ -d "/tmp/remote dir-x" ]; then
    rm -rf "/tmp/remote dir-x"
  fi

  mkdir "/tmp/remote dir"
  mkdir -p "/tmp/remote dir/1"
  mkdir -p "/tmp/remote dir/2/1"
  mkdir -p "/tmp/remote dir/3/1"

  ## create file for recursive dir
  touch "/tmp/remote dir/1/a.txt"
  echo "abc" > "/tmp/remote dir/1/a.txt"

  touch "/tmp/remote dir/2/1/a.txt"
  echo "abc" > "/tmp/remote dir/2/1/a.txt"

  touch "/tmp/remote dir/3/1/a.txt"
  echo "abc" > "/tmp/remote dir/3/1/a.txt"

  ## start encrypt
  sudo /bin/bash ../src/main.sh -v -p "/tmp/remote dir" -e -o "/tmp/output 1" -a "abc123"
  sudo /bin/bash ../src/main.sh -v -p "/tmp/output 1" -d -o "/tmp/remote dir-x" -a "abc123"

  remotedirspace1=`{
    export LC_ALL=C;cd "/tmp/remote dir";
    du -0ab | sort -z; # file lengths, including directories (with length 0)
    echo | tr '\n' '\000'; # separator
    find -type f -exec sha256sum {} + | sort -z; # file hashes
    echo | tr '\n' '\000'; # separator
    echo "End of hashed data."; # End of input marker
  } | sha256sum`

  remotedirspace2=`{
    export LC_ALL=C;cd "/tmp/remote dir-x/output 1/remote dir";
    du -0ab | sort -z; # file lengths, including directories (with length 0)
    echo | tr '\n' '\000'; # separator
    find -type f -exec sha256sum {} + | sort -z; # file hashes
    echo | tr '\n' '\000'; # separator
    echo "End of hashed data."; # End of input marker
  } | sha256sum`


  if [ -d "/tmp/remote dir" ]; then
    sudo rm -rf "/tmp/remote dir"
  fi

  if [ -d "/tmp/output 1" ]; then
    sudo rm -rf "/tmp/output 1"
  fi

  if [ -d "/tmp/remote dir-x" ]; then
    sudo rm -rf "/tmp/remote dir-x"
  fi
}

runTest(){
  if [ -f "test-output.txt" ]; then
    sudo rm -rf "test-output.txt"
  fi

  if [ "$r1" = "$r2" ]; then
    echo 'ok: recursive' >> "test-output.txt"
  else
    echo 'fail: recursive'  >> "test-output.txt"
  fi

  if [ "$test1" = "$test2" ]; then
    echo 'ok: simpletest' >> "test-output.txt"
  else
    echo 'fail: simpletest' >> "test-output.txt"
  fi

  if [ "$spacedir1" = "$spacedir2" ]; then
    echo 'ok: spacedir' >> "test-output.txt"
  else
    echo 'fail: spacedir' >> "test-output.txt"
  fi

  if [ "$remotedir1" = "$remotedir2" ]; then
    echo 'ok: remotedir' >> "test-output.txt"
  else
    echo 'fail: remotedir' >> "test-output.txt"
  fi

  if [ "$remotedirspace1" = "$remotedirspace2" ]; then
    echo 'ok: remotedirspace' >> "test-output.txt"
  else
    echo 'fail: remotedirspace' >> "test-output.txt"
  fi
  
  echo "--result--"
  cat "test-output.txt"
  echo "--result--"
}

# f_simpletest
# f_recursivetest
# f_dirwithspace
# f_dirremotedir
f_dirremotespacedir
runTest
