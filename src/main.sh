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

OPTIND=1

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
getCurrentFolder(){
    IFS='/ ' read -r -a array <<< "$1"
    currentFolder=""
    for element in "${array[@]}"
    do
        currentFolder=$element
    done
}

# create dir for output
createOutputDir(){
    if [[ "$output" = /* ]]; then
        ## using abs path
        # 1. get folder name of encrypted dir
        # 2. create new folder inside output
        # 3. folder name if encrypted dir

        mkdir -p "$output/$currentFolder"

        ## update out.txt
        # need to update it.
        # restore from dir value WILL BE REPLACED by output dir
        # restoreFrom = "/x/y/z" outputDir = "/a/b/c"
        # result = /a/b/c
        sudo cp out.txt "out-rm.txt"
        cat out.txt | while read line
        do
            if [ -f "$line" ]; then
                echo "$line" >> file.txt
            else

                #bug on using abs dir
                echo "$line" >> "file-dir.txt"

            fi
        done

        sed -i "s#$encrypt_dir#$output/$currentFolder#g" "file-dir.txt" && echo 'done sed'
        ## create dir only
        cat "file-dir.txt" | while read line
            do
                mkdir -p "$line"
            done

    else
        # possible bug when using abs dir
        mkdir -p "$output/$encrypt_dir"

        cat out.txt | while read line
        do
            if [ -f "$line" ]; then
                echo "$line" >> file.txt
            else

                #bug on using abs dir
                mkdir -p "$output/$line"
            fi
        done
    fi
}

startEncrypt(){

    COUNTER=0
    TOTALFILES=`cat file.txt | wc -l`
    echo 'TOTALFILES: ' $TOTALFILES

    if [[ "$output" = /* ]]; then

        cat file.txt | while read line; do
            COUNTER=$((COUNTER+1))
            P=`echo "$COUNTER*100/$TOTALFILES"|bc`
            VOLUMESIZE=$((`ls -s --block-size=1048576 "$line" | cut -d' ' -f1`  +2))"M"
            echo "------------------------$P %----------------------------"
            echo "filename: $line"
            tobeEncrypt=`echo $line | sed "s#$encrypt_dir#$output/$currentFolder#g"`
            echo "tobeEncrypt: $tobeEncrypt"
            echo "CREATE VOLUME: $output/$line"
            echo "VOLUME SIZE: " $VOLUMESIZE
            sudo veracrypt -t -f -c "$tobeEncrypt" --size=$VOLUMESIZE \
            --password=$password --hash="sha-512" --encryption="AES" \
            --filesystem="NTFS" --non-interactive -v || exit 1

            ##mount
            echo 'MOUNTING...'
            sudo veracrypt -t -f --mount "$tobeEncrypt" --password=$password \
            --non-interactive "$MOUNTPOINT" -v || exit 1
            sudo cp "$line" "$MOUNTPOINT/" || exit 1

            ##unmount
            echo 'UNMOUNTING...'
            sudo veracrypt -t -f -d "$tobeEncrypt" -v || exit 1
        done

    else

        cat file.txt | while read line; do
            COUNTER=$((COUNTER+1))
            P=`echo "$COUNTER*100/$TOTALFILES"|bc`
            VOLUMESIZE=$((`ls -s --block-size=1048576 "$line" | cut -d' ' -f1`  +2))"M"
            echo "------------------------$P %----------------------------"
            echo "CREATE VOLUME: $output/$line"
            echo "VOLUME SIZE: " $VOLUMESIZE
            sudo veracrypt -t -f -c "$output/$line" --size=$VOLUMESIZE \
            --password=$password --hash="sha-512" --encryption="AES" \
            --filesystem="NTFS" --non-interactive -v || exit 1

            ##mount
            echo 'MOUNTING...'
            sudo veracrypt -t -f --mount "$output/$line" --password=$password \
            --non-interactive "$MOUNTPOINT" -v || exit 1
            sudo cp "$line" "$MOUNTPOINT/" || exit 1

            ##unmount
            echo 'UNMOUNTING...'
            sudo veracrypt -t -f -d "$output/$line" -v || exit 1
        done

    fi

    sudo chmod 777 "$output" -R
}

# initialized
getCurrentFolder "$encrypt_dir"
MOUNTPOINT=/media/`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5`
init1(){
    {
        sudo veracrypt  -t -dv
        sudo mkdir -p "$MOUNTPOINT"
        sudo chmod 777 "$MOUNTPOINT" -R
        ls /media
        echo $MOUNTPOINT
    } || {
        echo 1
    }
}

cleanup(){
    sudo rm -rf $MOUNTPOINT

    if [ -f out.txt ]; then
        sudo rm out.txt
    fi

    if [ -f file.txt ]; then
        sudo rm file.txt
    fi

    if [ -f "file-dir.txt" ]; then
        sudo rm "file-dir.txt"
    fi

    if [ -f "out-rm.txt" ]; then
        sudo rm "out-rm.txt"
    fi

    if [ -f enc_restore.txt ]; then
        sudo rm enc_restore.txt
    fi

    if [ -f restoreList.txt ]; then
        sudo rm restoreList.txt
    fi
}

init1

echo "FROM: $encrypt_dir"
echo "TO: $output"

if [ "$enc_action" = "e" ]; then

    sudo rm -rf $output
    sudo mkdir $output

    if [ -f file.txt ]; then
        sudo rm file.txt
    fi

    if [ -f "file-dir.txt" ]; then
        sudo rm "file-dir.txt"
    fi
    
    ls -R "$encrypt_dir" | awk '
    /:$/&&f{s=$0;f=0}
    /:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
    NF&&f{ print s"/"$0 }' > out.txt
    echo "DIR LIST: out.txt"

    ### read list of dir and file
    # out.txt will be replace if using abs path
    createOutputDir

    #encrypting files
    startEncrypt

else

    ls -R "$encrypt_dir" | awk '
    /:$/&&f{s=$0;f=0}
    /:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
    NF&&f{ print s"/"$0 }' > restoreList.txt

    if [ -f enc_restore.txt ]; then
        sudo rm enc_restore.txt
    fi

    touch enc_restore.txt
    if [[ "$output" = /* ]]; then
        
        mkdir -p "$output/$currentFolder"
        outdir="$output/$currentFolder"

        cat restoreList.txt | while read toberestored
        do
            if [ -f "$toberestored" ]; then
                echo $toberestored >> enc_restore.txt
            else
                #new folder for output
                #folder is recursive
                newoutputDir=`echo "$toberestored" | sed "s#$encrypt_dir##g"`
                mkdir -p "$outdir$newoutputDir"
            fi
        done

    else
        echo 'no using remote dir'
        cat restoreList.txt | while read toberestored
            do
                if [ -f "$toberestored" ]; then
                    echo $toberestored >> enc_restore.txt
                else
                    # some directory is not consider by ls
                    # need to create it by force
                    # issue if no sub directory on main dir
                    mkdir -p "$output/$toberestored"
                fi
            done
    fi

    ## start mouting thes files
    if [[ "$output" = /* ]]; then
        cat enc_restore.txt | while read filerestore; do
            echo "MOUNTING: $filerestore"
            copyTo=`echo "$filerestore" | sed "s#$encrypt_dir#$output/$currentFolder#g"`
            sudo veracrypt -t -f --mount "$filerestore" --password=$password \
            --non-interactive "$MOUNTPOINT" -v || exit 1
            sudo cp "$MOUNTPOINT"/* "$copyTo" -v
            
            echo 'UNMOUNTING...'
            sudo veracrypt -t -f -d "$filerestore" -v || exit 1
            echo '---------------------'
        done

    else
        cat enc_restore.txt | while read filerestore; do
            echo "MOUNTING: $filerestore"
            sudo veracrypt -t -f --mount "$filerestore" --password=$password \
            --non-interactive "$MOUNTPOINT" -v || exit 1
            sudo cp "$MOUNTPOINT"/* "$output/$filerestore" -v
            
            echo 'UNMOUNTING...'
            sudo veracrypt -t -f -d "$filerestore" -v || exit 1
            echo '---------------------'
        done
    fi

    sudo chmod 777 "$output" -R
fi

cleanup
### end proc ###
shift $((OPTIND-1))

[ "$1" = "--" ] && shift
echo "verbose=$verbose,enc_action=$enc_action, encrypt_dir='$encrypt_dir', Leftovers: $@"