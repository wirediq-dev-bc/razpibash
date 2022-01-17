#!/bin/bash

PY_PATTERN='^(\_){0,2}[a-zA-Z]([[:alnum:]]+|\_*)+.py$'
INIT_PATTERN='^__init__\.py$'

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

FILENAME="${FILENAME:-qwik-script}"; shift

###
Error () {
    echo -e "-${PROGNAME%.*} error: $1\n" > /dev/stderr
    exit 1
}

###
check_filename () {
    if [ -f "$FILENAME" ]; then
        Error "$FILENAME: exists"
    fi
}

check_py_regex () {
    local PATTERN="$1"
    if [[ ! "$FILENAME" =~ $PATTERN ]]; then
        return 1
    else
        return 0
    fi
}

init_file () {
    touch ./__init__.py
}

python_template () {
    touch "$FILENAME"
}

###
if [[ "$FILENAME" =~ ^--?h(elp)?$ ]]; then
    Usage

elif check_py_regex "$INIT_PATTERN"; then
    init_file

elif check_py_regex "$PY_PATTERN"; then
    python_template

else
    Error "bad filename: $FILENAME"

fi

