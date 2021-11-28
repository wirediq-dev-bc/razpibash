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

===========================================
# Note the .sh file extension not required.
===========================================================
# FilenameRegex:  ^(\\.|\\_)?([[:alnum:]]+|\\-*)+(\\.sh)?$
===========================================================

EOF
exit 1
}

Curl_file () {
    # Download and assign permissions to a script.
    local CURL_STRING="$CURLS_URL"
    if [ -n "$FILENAME" ]; then
        if [[ "$FILENAME" =~ ^url$ ]]; then
            FILENAME="${CURLS_URL##*/}"
        fi
        CURL_STRING="$CURLS_URL -o ~/tmp/$FILENAME"
    fi

    # If not $FILENAME, print curl to stdout w/o saving.
    if $sh_c "curl -fsSL $CURL_STRING" && [ "$FILENAME" ]; then
        # If $FILENAME set custom or url slice then proceed.
        if [ "$FILENAME" ]; then
            $sh_c "chmod $PERMS ~/tmp/$FILENAME"
            [ ! -f "$FILENAME" ] && $sh_c "mv ~/tmp/$FILENAME ."
        fi
    fi
}

Mk_file () {
    # Create bash script template w/ permissions.
    FILENAME="${FILENAME:-qwik-script}"
    QWIK_TMP="$HOME/tmp/$FILENAME.$RANDOM.$RANDOM"

    if $sh_c "set -C; { echo '#!/bin/bash'; echo; } > $QWIK_TMP"; then
        # If `figlet` exists, place one at top of script.
        if command -v figlet > /dev/null; then
            echo -e "$(figlet -f slant "${FILENAME%.*}")" | 
                sed 's/^/#  /' | 
                $sh_c "tee -a $QWIK_TMP"
        fi
        $sh_c "echo \"\n# $FILENAME: \n\" >> $QWIK_TMP"
        $sh_c "chmod $PERMS $QWIK_TMP"
        $sh_c "mv $QWIK_TMP $PWD/$FILENAME"
    fi
}

Validate_input () {
    if [[ ! "${FILENAME}" =~ ^(\.|\_)?([[:alnum:]]+|\-*)+(\.sh)?$ ]]; then
        echo "Filename Regex Failed: $FILENAME"
        Usage
    elif [ -f "$FILENAME" ]; then
        echo 'error: raised: protect-no-clobber'
        Usage
    elif [ "$CURLS_URL" ]; then
        Curl_file
    else
        Mk_file
    fi

    [ "$OPEN_VIM" ] && $sh_c "vim $FILENAME"
}


if [ ! -d ~/tmp ]; then 
    mkdir ~/tmp || exit 1301
fi

FILENAME="${FILENAME:-}"
PERMS="${PERMS:-755}"
OPEN_VIM=1
CURLS_URL=
sh_c='sh -c'

while [ -n "$1" ]; do
    case "$1" in
        -C | --curl )  shift; CURLS_URL="$1" ;;
        -n | --name )  shift; FILENAME="$1" ;;
        -p | --perms )  shift; PERMS="$1" ;;
        -d | --dry-run )  sh_c='echo' ;;
        -q | --quiet-vim )  OPEN_VIM= ;;
        -h | --help )  Usage ;;
        -* | --* )  Usage ;;
        * )  FILENAME="$1" ;;
    esac
    shift
done

Validate_input

