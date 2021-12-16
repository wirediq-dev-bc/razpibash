#!/bin/bash

PY_PATTERN='^(\_){0,2}[a-zA-Z]([[:alnum:]]+|\_*)+.py$'

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
    if [[ ! "$FILENAME" =~ $PY_PATTERN ]]; then
        Error "bad filename: $FILENAME"
    fi
}

python_template () {
    cat <<- EOF

def main():
    pass

if __name__ in "__main__":
    main()

EOF
}

###
if [[ "$FILENAME" =~ ^--?h(elp)?$ ]]; then
    Usage
else
    check_py_regex
    python_template > "$FILENAME"
fi

