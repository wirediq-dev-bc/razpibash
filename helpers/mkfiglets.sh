#!/bin/bash

# mkfiglets.sh: Make figlets
# also try: toilet -f term -F border --gay

FIGFONT="${FIGFONT:-}"

Usage () {
    PROGNAME="${0##*/}"
    cat >&2 <<- EOF
usage: $PROGNAME [-i|--inspect] [-f|--font [FONT]] [-t|--text] TEXT

Make figlets for scripts with # comment delimiter.

Options:
 -i, --inspect      Show all figlet FONTS on host machine.
 -f, --font         Use FONT. Run inspect to see all.
 -t, --text         Make figlet from TEXT.
 -h, --help         Show this help message and exit.

EOF
exit 1
}

Parse_args () {
    local iflag=
    while [ -n "$1" ]; do
        iflag="$1"; shift
        case "$iflag" in 
            -i | --inspect )  showfigfonts; exit ;;
            -f | --font )  FIGFONT="$1" ;;
            -t | --text )  FIGTEXT=" $@"; break ;;
            -h | --help )  Usage ;;
            * )  Usage ;; 
        esac
        shift
    done
    [ -z "$FIGTEXT" ] && Usage
}

Make_figlet () {
    # small, standard, slant, smslant, big, block
    FIGFONT="${FIGFONT:-small}"
    { sh -c "figlet -f $FIGFONT $FIGTEXT"; echo; } | sed 's/^/# /'
}

[ -z "$1" ] && Usage

FIGTEXT=
Parse_args "$@"
Make_figlet

