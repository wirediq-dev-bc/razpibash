#!/bin/bash

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

SCRIPT=${FILENAME:-} 
LINK=${LINK_URLS:-}
[ ! "$LINK" ] && LINK="$SCRIPT"

###
Usage () {
    PROGNAME="${0##*/}"
    cat >&2 <<- EOF
usage: $PROGNAME FILENAME <LINK_NAME>

Omitting link name implies using: ~/bin/\${LINK_NAME##*/}

EOF
exit 1
}

Error () {
    echo -e "error: $1\n" > /dev/stderr
    exit 1
}

###
validate_scriptname () {
    if [ ! "$SCRIPT" ]; then
        Error 'no FILENAME given'
    fi
    script_exists
}

script_exists () {
    if [ ! -f "$SCRIPT" ]; then
        Error "$SCRIPT doesn't exist"
    fi
}

validate_linkname () {
    if [ ! -d ~/bin ]; then
        Error 'do `mkdir ~/bin` and retry'
    elif [ -L "$HOME/bin/$LINK" ]; then
        Error "$LINK exists in ~/bin"
    fi
}

make_link () {
    if ! $sh_c "ln -s $SCRIPT_PATH $LINK"; then
        Error "make symlink failed unexpectedly"
    fi
}

###
validate_scriptname
validate_linkname
SCRIPT_PATH="$PWD/$SCRIPT"

if ! cd ~/bin; then
    Error '`cd ~/bin` failed???'
else
    make_link
fi


