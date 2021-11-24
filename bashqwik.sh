#!/bin/bash

# shtemplate.sh: Generate basic shell script with 755 permissions

Usage () {
    PROGNAME="${0##*/}"
    cat <<- EOF

There are 2 usage modes: 

----- make_script (default) ----- 

${PROGNAME} [ -n | --name ] FILENAME [ -p | --perm ] OCTAL
 * Make bash.sh template FILENAME, with OCTAL permissions
 * FILENAME defaults to 'shtest.sh' for make script.

----- curl_script ----- 

$PROGNAME --curl CURLS_URL [ -p | --perm ] OCTAL [ -n | --name ] SAVE_AS 
 * Download file from CURLS_URL.
 * If name omitted only print script to stdout.

Examples:
 
 $PROGNAME 
 $PROGNAME script.sh
 $PROGNAME -p 600 -n shelly.sh
 $PROGNAME [-n] save-as.sh  --curl https://source-url.com save-as.sh

-------------------------------------------
* Note the .sh file extension not required.
----------------------------------------------------------
* Filename Regex: ^(\\.|\\_)?([[:alnum:]]+|\\-*)+(\\.sh)?$
----------------------------------------------------------
* Permissions Regex: ^[0-7]{3}$
-------------------------------
Defaults:
 FILENAME == shtest.sh
 OCTAL == 755

EOF
exit 1
}

Curl_file () {
    local CURL_STRING="$CURLS_URL"
    if [ -n "$FILENAME" ]; then
        if [[ "$FILENAME" =~ ^url$ ]]; then
            FILENAME="${CURLS_URL##*/}"
        fi
        CURL_STRING="$CURLS_URL -o ~/tmp/$FILENAME"
    fi

    if $sh_c "curl -fsSL $CURL_STRING" && [ "$FILENAME" ]; then
        if [ "$FILENAME" ]; then
            $sh_c "chmod $PERMS ~/tmp/$FILENAME"
            [ ! -f "$FILENAME" ] && $sh_c "mv ~/tmp/$FILENAME ."
        fi
    fi
}

Mk_file () {
    FILENAME="${FILENAME:-shtest.sh}"
    if $sh_c "set -C; echo '#!/bin/bash' > $FILENAME"; then
        $sh_c "echo \"\n# $FILENAME: \n\" >> $FILENAME"
        $sh_c "chmod $PERMS $FILENAME"
        $sh_c "vim $FILENAME"
    fi
}

Validate_input () {
    if [[ ! "${FILENAME}" =~ ^(\.|\_)?([[:alnum:]]+|\-*)+(\.sh)?$ ]]; then
        echo "Filename Regex Failed: $FILENAME"
        Usage
    elif [[ ! "$PERMS" =~ ^[0-7]{3}$ ]]; then
        echo "Permissions Regex Failed: $PERMS"
        Usage
    elif [ "$CURLS_URL" ]; then
        Curl_file
    else
        Mk_file
    fi
}


if [ ! -d ~/tmp ]; then 
    mkdir ~/tmp || exit 1301
fi

FILENAME="${FILENAME:-}"
PERMS="${PERMS:-755}"
CURLS_URL=
sh_c='sh -c'

while [ -n "$1" ]; do
    case "$1" in
        --dry-run )  sh_c='echo' ;;
        -C | --curl )  shift; CURLS_URL="$1" ;;
        -n | --name )  shift; FILENAME="$1" ;;
        -p | --perms )  shift; PERMS="$1" ;;
        -h | --help )  Usage ;;
        -* | --* )  Usage ;;
        * )  FILENAME="$1" ;;
    esac
    shift
done

Validate_input

