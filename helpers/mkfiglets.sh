#!/bin/bash

# mkfiglets.sh: Make figlets
# also try: toilet -f term -F border --gay

Parse_args () {
    SET_TEXT=
    local iflag=
    while [ -n "$1" ]; do
        iflag="$1"; shift
        case "$iflag" in 
            -i | --inspect )  showfigfonts; exit ;;
            -f | --font )  SET_FONT=" -f $1" ;;
            -t | --text )  SET_TEXT=" $@" ;;
            * ) echo 'error: cli token'; exit 1 ;; 
        esac
        shift
    done
    
    if [ ! "$SET_TEXT" ]; then
        echo 'error: need text to figlet'
        exit 1
    fi
    
    # small, standard, slant, smslant, big, block
    SET_FONT="${SET_FONT:-slant}"
    { figlet -f $SET_FONT "$SET_TEXT"; echo; } | sed 's/^/# /'
}

if [ -z "$1" ]; then
    echo 'error: null input'; exit 1
else
    Parse_args "$@"
fi


