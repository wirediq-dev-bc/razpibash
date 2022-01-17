#!/bin/bash

# RESET('1'): page-cache (safe)
# RESET('2'): dentries & inodes
# RESET('3'): page-cache & dentries & inodes
RESET_DESCRIPTOR=1
DROP_CACHE_PATH=/proc/sys/vm/drop_caches
sh_c=

Error () {
    PROGNAME=${0##*/}
    echo -e "${PROGNAME} error: " >&2
    exit 1
}

clean_view () {
    SPLITTER=
    for ((i=0; i<80; i++)); do 
        SPLITTER+='#'; 
    done
    SPLITTER="\033[38;5;26m${SPLITTER}\033[00m"
}

ram_view () {
    echo -e "\n$SPLITTER\n$(free -h)\n$SPLITTER\n"
}

get_current_user () {
    if [ "$(id)" == 0 ]; then
        sh_c='sh -c'
    else
        sh_c='sudo -E sh -c'
    fi
}

drop_cache_gigadump () {
    if ! $sh_c "sync; echo $RESET_DESCRIPTOR > $DROP_CACHE_PATH"; then
        Error '`drop_cache_gigadump` failed'
    fi
}

download_ram () {
    ram_view
    drop_cache_gigadump
    ram_view
}

main () {
    clean_view
    get_current_user
    download_ram
}

main

