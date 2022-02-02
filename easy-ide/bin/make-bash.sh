#!/bin/bash

BASH_PATTERN='^(\.|\_)?([[:alnum:]]+|\-*)+(\.sh)?$'

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

FILENAME="${FILENAME:-qwik-script}"; shift


###
Usage () {
    cat >&2 <<- EOF
usage: bashqwik bash FILENAME
EOF
exit 1
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
    regex_filename
}

regex_filename () {
    if [[ ! "$FILENAME" =~ $BASH_PATTERN ]]; then
        Error "bad filename: $FILENAME"
    fi
}

bash_template () {
    cat <<- 'EOF'
#!/bin/bash

WHEREAMI=$(readlink -f $0)
PROGNAME=${WHEREAMI##*/}

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

#Usage () {
#    cat >&2 <<- EOF
#usage: $PROGNAME
#EOF
#}

Error () {
    echo -e "-${PROGNAME%.*} error: $1\n" > /dev/stderr
    exit 1
}

main () {
    echo 'foobar'
}

EOF
}

###
if [[ "$FILENAME" =~ ^--?h(elp)?$ ]]; then
    Usage
else
    validate_filename
    bash_template > "$FILENAME"
fi

