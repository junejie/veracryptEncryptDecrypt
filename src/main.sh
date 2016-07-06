#!/bin/bash

#######################################
# steps
#     encryption
#
#         param 
#             1. dir to encrypt
#
#         1. get list of dir
#         2. map the dir.
#         3. save to txt file the map
#         4. create encrypted dir match to non encrypted dir
#
#     decyption
#         param
#             1. target to decrypt
#             2. encrypted file or dir
#######################################

## show help
usage="$(basename "$0") [-h] [-s n] -- program to calculate the answer to life, the universe and everything
where:
    -h  show this help text
    -e  encrypt
    -d  decrypt
    -p  path to encrypt or decrypt"

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
encrypt_dir=""
verbose=0
enc_action=""

while getopts "h?vedp:" opts; do
    case "$opts" in
    h|\?)
        echo "$usage"
        exit 0
        ;;
    v)  verbose=1
        ;;

    # enc_action [e,d] encrypt,decrypt 
    e)  
        enc_action=e
        echo 'start encryption....'
        rm -rf output
        mkdir output
        echo 'saving to output folder...'
        ;;
    d)  
        enc_action=d
        ;;
    p)  
        encrypt_dir=$OPTARG
        ;;
    esac
done

### start process ###
ls -R $encrypt_dir | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$0 }' > out.txt
cat out.txt | while read line
    do
        if [ -f "$line" ]; then 
            echo "file: $line"
        else
            mkdir -p output/$line
            echo "dir: $line"
        fi

    done

### end proc ###


shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "verbose=$verbose,enc_action=$enc_action, encrypt_dir='$encrypt_dir', Leftovers: $@"
