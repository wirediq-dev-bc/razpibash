#!/bin/bash

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

PERMS="${PERMS:-755}"
OPEN_VIM=
CURLS_URL=

FILENAME="${1:-qwik-script}"; shift


####
Usage () {
    PROGNAME="${0##*/}"
    cat <<- EOF
usage: ${PROGNAME%.*} FILENAME [OPTIONS]

Options:
 -c, --curl         Use curl to download a script from the internet.
 -p, --perms        Set r/w/x permissions. Default 755.
 -q, --vim          Dont open script in vim after saving.
 -d, --dry-run      Echo command calls. Useful for debugging. 
 -h, --help         Display this help message and exit.

Examples:
 $PROGNAME bash-script.sh
 $PROGNAME shelly.sh -p 600
 $PROGNAME [<save_name>] --curl https://source-url.com
 $PROGNAME housekeeper.sh --vim


\`$PROGNAME [FILENAME] --curl URL [OPTIONS]\`
> If name omitted only print script to stdout.

EOF
exit 1
}

Error () {
    echo -e "error: $1\n" > /dev/stderr
    exit 1
}

###
validate_filename () {
    STD_PATTERN='^(\.|\_)?([[:alnum:]]+|\-*)+(\.sh)?$'
    PY_PATTERN='^[a-zA-Z]([[:alnum:]]+|\_*)+.py$'

    if [ -f "$FILENAME" ]; then
        Error "$FILENAME: exists!" 
    elif [[ "$FILENAME" =~ ^.*.py$ ]]; then
        STD_PATTERN=$PY_PATTERN
    fi
    
    regex_filename
}

regex_filename () {
    if [[ ! "$FILENAME" =~ $STD_PATTERN ]]; then
        Error "name( '$FILENAME' ) != Regex( '$PATTERN' )"
    else
        return 0
    fi
}

###
make_bash () {
    validate_filename
    bash_template > $FILENAME
    set_permissions
}

bash_template () {
    cat <<- 'EOF'
#!/bin/bash

PROGNAME=${0##*/}

#Usage () {
#    cat >&2 <<- EOF
#usage: $PROGNAME
#EOF
#}

Error () {
    echo -e "-${PROGNAME%.*} error: $1\n" > /dev/stderr
    exit 1
}

EOF
}

###
save_curl () {
    CURLS_URL="$CURLS_URL -o $PWD/$FILENAME"
    validate_filename
    run_curl
    set_permissions
}

run_curl () {
    if ! $sh_c "curl -fsSL $CURLS_URL"; then
        Error 'curl failed'
    fi
}

####
set_permissions () {
    if ! $sh_c "chmod $PERMS $FILENAME"; then
        Error 'chmod failed'
    fi
}

####
if [[ "$FILENAME" =~ ^--?c(url)?$ ]]; then
    CURLS_URL="$1" run_curl; exit
fi

iflag=
while [ -n "$1" ]; do
    iflag="$1"; shift
    case "$iflag" in
        -c | --curl ) CURLS_URL="$1" ;;
        -p | --perms ) PERMS="$1" ;;
        -v | --vim ) OPEN_VIM=1; continue;;
        * )  Usage ;;
    esac
    shift
done


if [ "$CURLS_URL" ]; then
    save_curl
else
    make_bash
fi

if [ "$OPEN_VIM" ]; then
    $sh_c "vim $FILENAME"
else
    exit 0
fi

