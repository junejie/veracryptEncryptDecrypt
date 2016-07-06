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
enc_action=""

while getopts "h?vedp:" opts; do
    case "$opts" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  verbose=1
        ;;

    # enc_action [e,d] encrypt,decrypt 
    e)  
        enc_action=e
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
echo $enc_action
ls -R $encrypt_dir | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$0 }' > out.txt
echo 1
cat out.txt | while read line
    do
      echo "---"
    done

### end proc ###


shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "verbose=$verbose,enc_action=$enc_action, encrypt_dir='$encrypt_dir', Leftovers: $@"
