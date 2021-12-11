#!/bin/bash

STD_PATTERN='^(\.|\_)?([[:alnum:]]+|\-*)+(\.sh)?$'
PY_PATTERN='^[a-zA-Z]([[:alnum:]]+|\_*)+.py$'

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

PERMS="${PERMS:-755}"
OPEN_VIM=
CURLS_URL=

FILENAME="${1:-qwik-script}"; shift


Usage () {
    PROGNAME="${0##*/}"
    cat <<- EOF
usage: ${PROGNAME%.*} FILENAME [OPTIONS]

Options:
 -c, --curl         Use curl to download a script from the internet.
 -p, --perms        Set r/w/x permissions. Default 755.
 -q, --vim          Dont open script in vim after saving.
 -h, --help         Display this help message and exit.

Examples:
 $PROGNAME bash-script.sh
 $PROGNAME shelly.sh -p 600
 $PROGNAME [FILENAME] --curl https://url.com/source.sh
 $PROGNAME housekeep.(sh|py) --vim

$PROGNAME [FILENAME] --curl URL [OPTIONS]
> If name omitted only print script to stdout.

EOF
exit 1
}

Error () {
    echo -e "error: $1\n" > /dev/stderr
    exit 1
}

###
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

main () {
    echo 'foobar'
}

EOF
}

python_template () {
    cat <<- EOF
# $FILENAME

def main():
    pass

if __name__ in "__main__":
    # unit_test()
    main()

EOF
}

check_py () {
    if [[ "$FILENAME" =~ ^.*\.py$ ]]; then
        return 0
    else
        return 1
    fi
}

###
parse_args () {
    while [ -n "$1" ]; do
        case "$1" in
            -c | --curl ) shift; CURLS_URL="$1";;
            -p | --perms ) shift; PERMS="$1";;
            -v | --vim ) OPEN_VIM=1;;
            * )  Usage ;;
        esac
        shift
    done
}

main () {
    check_py && STD_PATTERN=$PY_PATTERN
    validate_filename
    if [ ! "$CURLS_URL" ]; then
        local_file_gen
    else
        run_curl_with_save
    fi
    set_permissions
    try_vim
}

###
validate_filename () {
    if [ -f "$FILENAME" ]; then
        Error "$FILENAME: exists!" 
    fi
    regex_filename
}

regex_filename () {
    if [[ ! "$FILENAME" =~ $STD_PATTERN ]]; then
        Error "name( '$FILENAME' ) != match( '$PATTERN' )"
    fi
}

###
local_file_gen () {
    if check_py; then
        python_template > "$FILENAME"
    else
        bash_template > "$FILENAME"
    fi
}

###
run_curl_with_save () {
    CURLS_URL="$CURLS_URL -o $PWD/$FILENAME"
    run_curl
}

run_curl () {
    if ! $sh_c "curl -fsSL $CURLS_URL"; then
        Error 'curl failed'
    fi
}

###
set_permissions () {
    if ! $sh_c "chmod $PERMS $FILENAME"; then
        Error 'chmod failed'
    fi
}

try_vim () {
    [ "$OPEN_VIM" ] && $sh_c "vim $FILENAME"
    exit 0
}

###
if [[ "$FILENAME" =~ ^--?h(elp)?$ ]]; then
    Usage
elif [[ "$FILENAME" =~ ^--?c(url)?$ ]]; then
    CURLS_URL="$1" 
    run_curl
else
    parse_args "$@"
    main
fi

