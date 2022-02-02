#!/bin/bash

# get-posh.sh: Download and install oh-my-posh and related theme files.

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

# Binary installed here
POSH_BIN='/usr/local/bin/oh-my-posh'
SRC_BINS="https://github.com/JanDeDobbeleer/oh-my-posh/releases/download"
OMP_VERSION="v5.16.3"

# Download correct binary
KERNEL_TYPE="$(uname -s | tr '[A-Z]' '[a-z]')"
HOST_ARCH="$(uname -p)"
[[ "$HOST_ARCH" =~ x86_64 ]] && HOST_ARCH='amd64'

# Get binaries from "https://github.com/JanDeDobbeleer/oh-my-posh/releases/<autofill>"
SRC_BINARIES="$SRC_BINS/$OMP_VERSION/posh-$KERNEL_TYPE-$HOST_ARCH"

# oh-my-posh themes
THEME_URL='https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip'
THEMEDIR="${HOME}/.poshthemes"

# View-Theme string
SHELLY='\nFrom: %b\n%s shelly\n'


Usage () {
    PROGNAME="${0##*/}"
    cat <<- EOF
usage: ${0##*/} OPTION [THEME]

Options:
 --get-omp          Install oh-my-posh from $SRC_BINARIES
 --view [THEME]     View a THEME or print all THEMES from ~/.poshthemes
 --set THEME        Set a theme for terminal. Apply with \`source ~/.bashrc\`

EOF
exit 1
}

Error () {
    echo -e "-${0##*/}: error: ${1}\n" > /dev/stderr
    exit 1
}

command_exists () {
    command -v oh-my-posh > /dev/null 2>&1
}

install_oh_my_posh () {
    if command_exists "$POSH_BIN"; then
        echo -e "\nExists: `command -v oh-my-posh` -> updating_themes"
    else
        perform_install
    fi
    return 0
}

perform_install () {
    sh_c='sudo -E sh -c'
    if ! $sh_c "wget $SRC_BINARIES -O $POSH_BIN && chmod +x $POSH_BIN"; then
        Error 'get binaries failed'
    fi
    sh_c='sh -c'
}

get_themes () {
    make_theme_dir
    clean_themedir
    install_themes
}

make_theme_dir () {
    if [ ! -d "${THEMEDIR}" ]; then
        if ! mkdir $THEMEDIR; then
            Error 'cant create ~/.poshthemes directory?'
        fi
    fi
}

clean_themedir () {
    cd $THEMEDIR || Error "cant \`cd $THEMEDIR\`"
    if [[ "$(ls | grep -E '\.(json|zip)$')" ]]; then
        echo "Cleaning: $THEMEDIR"
        rm ./* || Error "Cant clean $THEMEDIR"
    fi
}

install_themes () {
    { $sh_c "wget $THEME_URL -O $THEMEDIR/themes.zip" && 
        $sh_c "unzip $THEMEDIR/themes.zip -d $THEMEDIR" &&
        $sh_c "chmod u+rw $THEMEDIR/*.json" &&
        $sh_c "rm $THEMEDIR/themes.zip"; } && 
        cd - || Error 'themes fatal'
}

view_themes () {
    command_exists || Error 'oh-my-posh not installed'
    if [ -z "$1" ]; then 
        view_one_theme
    else
        view_all_themes
    fi
    echo -e '\nTHANK YOU\nHAVE NICE DAY\n'
}

view_one_theme () {
    for _style in ~/.poshthemes/*.omp.json; do
        printf "$SHELLY" "$_style" "$(oh-my-posh --config $_style --shell universal)"
    done
}

view_all_themes () {
    THEME_VIEW=~/.poshthemes/${1}.omp.json
    if [ ! -r "$THEME_VIEW" ]; then
        echo "Theme doesn't exist: $1"
    fi
    printf "$SHELLY" "$THEME_VIEW" "$(oh-my-posh --config $THEME_VIEW --shell universal)"
}

set_themes () {
    SED_SEARCH="$(grep -E '^SET_OMP_THEME=' ${HOME}/.bashrc)"
    theme_exists
    set -x
    if [ "$SED_SEARCH" ]; then
        SED_SWITCH="${SED_SEARCH%%=*}=\"$PTHEME\""
        sed -i s/$SED_SEARCH/$SED_SWITCH/ $HOME/.bashrc
    else
        export_posh_theme | tee -a $HOME/.bashrc
    fi
    set +x
    howto_apply
}

theme_exists () {
    if [ ! -r "$THEMEDIR/${PTHEME}.omp.json" ]; then
        Error "PoshTheme: <${PTHEME}> doesnt exist?!"
    fi
}

export_posh_theme () {
    cat <<- EOF
# oh-my-posh-theme
SET_OMP_THEME="$PTHEME"
eval "\$(oh-my-posh --init --shell bash --config ~/.poshthemes/\${SET_OMP_THEME}.omp.json)"
EOF
}

howto_apply () {
    cat <<- 'EOF'
To apply changes do one of the following;
 * Logout and log back in
 * `source ~/.bashrc`
 * `. ~/.bashrc`

EOF
}

OPTION="$1"; shift
PTHEME="$1"
case "$OPTION" in
    --get-omp ) install_oh_my_posh && get_themes;;
    --set ) set_themes;;
    -v | --view ) view_themes;;
    * ) Usage;;
esac

