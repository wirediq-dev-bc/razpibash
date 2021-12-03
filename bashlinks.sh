#!/bin/bash

# 

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

SCRIPT="$1" 
LINK=${2:-}
[ ! "$LINK" ] && LINK="$SCRIPT"


Usage () {
    PROGNAME="${0##*/}"
    cat >&2 <<- EOF
usage: $PROGNAME FILENAME <LINK_NAME>

Create symbloic links to ~/bin: 
 ~/bin must already exist. 
 This script will not create it.

FILENAME
 Must be regular file.
 FILENAME must exist in $CWD.

LINK_NAME 
 If LINK_NAME unset FILENAME is used. 
 LINK_NAME cannot already exist in ~/bin.

Example:
========
> \`$PROGNAME long_informative_filename.sh easyname\`
> ls ~/bin
~/bin/easyname -> $CWD/long_informative_filename.sh

EOF
}

Error () {
    if [ "$1" ]; then
        echo -e "error: $1\n" > /dev/stderr
    fi
    Usage > /dev/stderr
    exit 1
}

validate_scriptname () {
    if [ ! "$SCRIPT" ]; then
        Error 'no FILENAME given'
    elif [ ! -f "$SCRIPT" ]; then
        Error "$SCRIPT doesn't exist"
    fi
}

validate_linkname () {
    TEST_LINK='^[[:alnum:]](\-|\_|\.|[[:alnum:]])*[A-Za-z0-9]$'
    if [ ! -d ~/bin ]; then
        Error 'do `mkdir ~/bin` and retry'

    elif [[ ! "$LINK" =~ $TEST_LINK ]]; then
        Error "$LINK failed regex test"
    
    elif [ -L "$HOME/bin/$LINK" ]; then
        Error "$LINK exists in ~/bin"
    fi
}


validate_scriptname
validate_linkname
SCRIPT_PATH="$PWD/$1"

if ! cd ~/bin; then
    Error '`cd ~/bin` failed???'
fi

if ! $sh_c "ln -s $SCRIPT_PATH $LINK"; then
    Error "make symlink failed unexpectedly"
fi

