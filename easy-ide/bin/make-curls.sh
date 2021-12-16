#!/bin/bash

PROGNAME=${0##*/}
FILENAME=${FILENAME:-}
LINK_URLS=${LINK_URLS:-}

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

###
Usage () {
    cat >&2 <<- EOF
usage: bashqwik $PROGNAME [ SAVE_NAME ] SOURCE_URL

Omitting SAVE_NAME prints file without saving.

EOF
}

Error () {
    echo -e "-${PROGNAME%.*} error: $1\n" > /dev/stderr
    exit 1
}

###
validate_filename () {
    if [ -f "$FILENAME" ]; then
        Error "$FILENAME: exists!"
    fi
}

run_curl () {
    if ! $sh_c "curl -fsSL $LINK_URLS"; then
        Error 'curl failed'
    fi
}

###
if [[ "$FILENAME" =~ ^--?h(help?)$ ]]; then
    Usage
elif [ ! "$FILENAME" -a ! "$LINK_URLS" ]; then
    Usage
elif [[ "$FILENAME" && "$LINK_URLS" ]]; then
    LINK_URLS="$LINK_URLS -o $PWD/$FILENAME"
    validate_filename
else
    LINK_URLS="$FILENAME" 
fi

run_curl

