#!/bin/bash
set -e
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
    -p  path to encrypt or decrypt
    -o  path to output
    -a  password of encrypted file"

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
encrypt_dir=""
verbose=0
enc_action=""

while getopts "h?vedp:a:o:" opts; do
    case "$opts" in
    h|\?)
        echo "$usage"
        exit 0
        ;;
    v)  verbose=1
        ;;

    # enc_action [e,d] encrypt,decrypt 
    e)  
        enc_action="e"
        echo 'start encryption....'
        ;;
    d)  
        enc_action="d"
        ;;
    p)  
        encrypt_dir=$OPTARG
        ;;
    o)  
        output=$OPTARG
        ;;
    a)  
        password=$OPTARG
        ;;
    esac
done

### start process ###

{
    sudo veracrypt  -t -d
    sudo rm -rf /media/veracrypt4
} || {
    exit 1
}


echo "action: $enc_action"

if [ "$enc_action" = "e" ]; then
    
    sudo rm -rf $output
    sudo mkdir $output
    sudo rm -rf file.txt
    sudo rm -rf out.txt

    echo "saving to $output folder..."

    ls -R "$encrypt_dir" | awk '
    /:$/&&f{s=$0;f=0}
    /:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
    NF&&f{ print s"/"$0 }' > out.txt
    echo "file saved to out.txt"

    ### read list of dir and file
    mkdir -p "$output/$encrypt_dir"
    cat out.txt | while read line
        do
            if [ -f "$line" ]; then
                echo $line >> file.txt
            else
                mkdir -p "$output/$line"
            fi
        done

    #### read list of file only
    COUNTER=0
    TOTALFILES=`cat file.txt | wc -l`
    echo 'total files: ' $TOTALFILES
    
    cat file.txt | while read line; do
        COUNTER=$((COUNTER+1))
        P=`echo "$COUNTER*100/$TOTALFILES"|bc`
        VOLUMESIZE=$((`ls -s --block-size=1048576 "$line" | cut -d' ' -f1`  +1))"M"
        echo "------------------------$P %----------------------------"
        echo "create volume to $output/$line"
        echo "filesize: " $VOLUMESIZE
        sudo veracrypt -t -f -c "$output/$line" --size=$VOLUMESIZE \
        --password=$password --hash="sha-512" --encryption="AES" \
        --filesystem="NTFS" --non-interactive -v || exit 1

        ##mount
        echo 'mounting ...'
        sudo veracrypt -t -f --mount "$output/$line" --password=$password \
        --non-interactive /media/veracrypt4 -v || exit 1
        sudo cp "$line" /media/veracrypt4/ -v || exit 1
        sudo ls -lh /media/veracrypt4/ || exit 1
        sudo du -h /media/veracrypt4/ || exit 1

        ##unmount
        echo 'unmounting....'
        sudo veracrypt -t -f -d "$output/$line" -v || exit 1
        sudo rm -rf /media/veracrypt4
    done

    sudo rm file.txt
    sudo rm out.txt
    sudo chmod 777 "$output" -R
else
    echo 'd'
    echo "restore from: $encrypt_dir folder..."
    echo "storing to: $output folder..."

    sudo rm enc_restore.txt

    ls -R "$encrypt_dir" | awk '
    /:$/&&f{s=$0;f=0}
    /:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
    NF&&f{ print s"/"$0 }' > restoreList.txt
    echo "file saved to restoreList.txt"
    
    echo "create dir for $output"
    mkdir -p "$output"
    rm -rf enc_restore.txt
    touch enc_restore.txt
    cat restoreList.txt | while read toberestored
        do
            if [ -f "$toberestored" ]; then
                echo $toberestored "-file"
                echo $toberestored >> enc_restore.txt
            else
                echo $toberestored "-dir"
                mkdir -p "$output/$toberestored"
            fi
        done

    ##delete restorelist
    sudo rm -rf restoreList.txt

    ## start mouting thes files
    echo 'start mounting file tobe restore'
    cat enc_restore.txt | while read filerestore; do
        echo "mounting : $filerestore"
        sudo veracrypt -t -f --mount "$filerestore" --password=$password \
        --non-interactive /media/veracrypt4 -v || exit 1

        ls -lh /media/veracrypt4
        sudo cp /media/veracrypt4/* "$output/$filerestore" -v

        ##unmount
        echo 'unmounting....'
        sudo veracrypt -t -f -d "$filerestore" -v || exit 1
        sudo rm -rf /media/veracrypt4
        sudo chmod 777 "$output/$filerestore"
        #exit 1
    done
    sudo rm enc_restore.txt

fi

### end proc ###


shift $((OPTIND-1))

[ "$1" = "--" ] && shift
echo "verbose=$verbose,enc_action=$enc_action, encrypt_dir='$encrypt_dir', Leftovers: $@"