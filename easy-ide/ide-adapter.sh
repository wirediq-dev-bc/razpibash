#!/bin/bash

PROGNAME=${0##*/}
LOCATED=~/bin/razpibash/easy-ide
BASHBIN=$LOCATED/bin

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

LINK_URLS=
OPEN_VIM=
PERMS="${PERMS:-755}"

EXE_MODE="$1"; shift
EXECUTE=$BASHBIN/make-$EXE_MODE.sh
FILENAME="$1"; shift


###
Usage () {
    cat >&2 <<- EOF
usage: $PROGNAME HELPER [OPTIONS]... NAME

Helpers:
 bash               Create bash script templates.
 python             Create python script templates.
 curl               Use curl to download and save scripts.
 links              Create pwd/file symlinks to ~/bin.
 help               Print this help message and exit.

Options:
 -p, --perms        Set r/w/x permissions. Default 755.
 -q, --vim          Open script in Vim after creating it. 

EOF
exit 1
}

Error () {
    echo -e "-${PROGNAME%.*} error: $1\n" > /dev/stderr
    ls -l $BASHBIN > /dev/stderr
    exit 1
}

###
validate_filename () {
    if [[ ! $EXE_MODE =~ ^links$ ]]; then
        ignores_links
    fi
}

ignores_links () {
    if [ -f "$FILENAME" ]; then
        Error "$FILENAME: exists!"
    fi
}

find_helper () {
    if [ ! -x $EXECUTE ]; then
        Error "$EXECUTE: doesnt exist"
    fi
}

run_helper () {
    find_helper
    if ! $EXECUTE $ARGS; then
        Error "$EXECUTE: failed"
    fi
}

###
set_permissions () {
    if [ -f "$FILENAME" ]; then
        if ! $sh_c "chmod $PERMS $FILENAME"; then
            Error 'chmod failed'
        fi
    fi
}

try_vim () {
    if [ "$OPEN_VIM" ]; then
        $sh_c "vim $FILENAME"
    else
        exit 0
    fi
}

###
parse_args () {
    while [ -n "$1" ]; do
        case "$1" in
            -p | --perms ) shift; PERMS="$1";;
            -v | --vim ) OPEN_VIM=1;;
            -* | --* ) Usage;;
            * )  LINK_URLS="$1";;
        esac
        shift
    done
    export ECHO FILENAME LINK_URLS
}

main () {
    validate_filename
    run_helper
    if [[ ! ${EXECUTE##*/} =~ ^make-links\.sh$ ]]; then
        set_permissions
        try_vim
    fi
}

###
if [[ "$EXE_MODE" =~ ^--?h(elp)?$ ]]; then
    Usage
else
    parse_args "$@"
    main
fi

