#!/usr/bin/bash 

# Executes `ssh-host-ips.awk` script

AWK_SCRIPT=${0%/*}/elastic-ssh-task.awk

Usage () {
    PROGNAME=${0##*/}
    cat >&2 <<- EOF

usage: $PROGNAME [-h][-I][-Q] -u NEW_VAL 

Where:
 -f | --file )
  * Valid ssh/<filename> to modify.

 -h | --host )
  * SSH config header records: Host <host>
  * Defaults to 'Host ec2'

 -r | --record )
  * Host <host> subfield key, (Hostname, ProxyCommand, etc)
  * Defaults to Hostname

 -u | --updates ) 
  * Switch value <record current> with <record updates>
  * Does not have a default, program terminates if unspecified.

 -I | --inplace )
  * awk include '-i inplace' plugin.
  * Dry run is default mode, file prints to /dev/stdout
  * Use -I flag to commit changes to file.

 -Q | --quiet )
  * Quiet awks.script default '> /dev/stderr' info msg.
  
 * ) /filename/
  * Must be existing file.
  * Can be passed anywhere in CLI string with [-f|--file] flag.
  * If positional, place filename at end of command string.

EOF
exit 1
}

Check_dependencies () {
    if [ ! -f $AWK_SCRIPT ]; then
        echo "Required AWK_SCRIPT doesnt exist (see upstream repo)"
        return 1
    elif [ ! -x $AWK_SCRIPT ]; then
        echo '- AWK_SCRIPT does not have execute permissions -'
        echo 'Find script @ $AWK_SCRIPT & \`chmod +x ssh-host-ips.awk\`'
        return 1
    fi
}

Valid_text_file () {
    if [ -r "$1" ]; then
        TEXT_FILE="$1"
    else
        echo 'fatal: bad text file input'
        exit 1
    fi
}

Chk_kwargs () {
    if [[ -z "$2" || "$2" =~ ^(\-){1,2}[[:alpha:]]* ]]; then
        echo "Invalid optional argument: -v ${1}${2}"
        exit 1
    elif [ -f "$2" ]; then
        echo "Filenames must be last positional or as [ -f | --file ] $2"
        echo "Current view: [ \$1:${1} \$2:${2} ]"
        exit 1
    else
        KWARGS+="-v ${1}${2} "
    fi
}

Parse_args () {
    declare -a KWARGS
    local iflag=
    TEXT_FILE=

    while [ -n "$1" ]; do
        iflag="$1"; shift
        case "$iflag" in
            -f | --file )  Valid_text_file "$1" ;;
            -h | --host )  Chk_kwargs 'host=' "${1:-ec2}" ;;
            -r | --record )  Chk_kwargs 'record=' "${1:-Hostname}" ;;
            -u | --updates )  Chk_kwargs 'updates=' "$1" ;;
            -I | --include )  KWARGS+='-i inplace '; continue ;;
            -Q | --quiet )  KWARGS+='-v quiet=1 '; continue ;;
            -* | --* )  Usage ;;
            * )  Valid_text_file "$iflag"; continue ;;
        esac
        shift
    done
    set -x

    if [ -z "$TEXT_FILE" ]; then
        if [ -e ~/.ssh/config ]; then
            TEXT_FILE=~/.ssh/config || Usage
        else 
            echo 'fatal: no working file'
        fi
    fi
    $sh_c "awk -f ${AWK_SCRIPT} ${KWARGS[@]}${TEXT_FILE}"
    set +x
}

sh_c='sh -c'
if [ -z "$1" ]; then
    echo 'No command line input given'
    exit 1
elif Check_dependencies; then
    Parse_args "$@" 
fi



