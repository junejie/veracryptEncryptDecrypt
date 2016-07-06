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

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
encrypt_dir=""
verbose=0

while getopts "h?vd:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  verbose=1
        ;;
    d)  encrypt_dir=$OPTARG
        ls -R $encrypt_dir | awk '
        /:$/&&f{s=$0;f=0}
        /:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
        NF&&f{ print s"/"$0 }' > out.txt
        echo 1
        cat out.txt | while read line
        do
          echo "---"
          echo "---$line"
          echo "---"
        done
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "verbose=$verbose, encrypt_dir='$encrypt_dir', Leftovers: $@"
