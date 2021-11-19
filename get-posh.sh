#!/bin/bash

# get-posh.sh: Download and install oh-my-posh and related theme files.

Usage () {
	cat <<- EOF

usage: ${0##*/} [ --get-omp ] [ --view <theme> ] [ --set <theme> ]

Flags:
  --get-omp ) 
    Get oh-my-posh binaries and download/update themesets

  --view ) 
    See how a theme will look applied on your terminal.
	If no arg passed to stdin, all themes in ~/.poshthemes are printed.
	Single theme must already exist in ~/.poshthemes to apply.

  --set ) 
    Set oh-my-posh theme for shell environment

EOF
exit 1
}

Cmd_exists () {
	command -v oh-my-posh > /dev/null 2>&1
}

Install_oh_my_posh () {
	# Find pkg @ "https://github.com/JanDeDobbeleer/oh-my-posh/releases"
	local POSH_BIN='/usr/local/bin/oh-my-posh'
	local OMP_VERSION="v5.16.3/posh-linux-arm64"
	local SRC_BINARIES="https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/$OMP_VERSION"

	if [ Cmd_exists -o -e "$POSH_BIN" ]; then
		echo -e "\nUpdatingThemesUsedBy: `command -v oh-my-posh`"
		return 0
	fi

	sudo wget $SRC_BINARIES -O $POSH_BIN
	sudo chmod +x $POSH_BIN
	return 0
}

Get_themes () {
	# TODO `find ~/.poshthemes -newer` -> update
	local THEME_URL='https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip'
	local POSHDIR="${HOME}/.poshthemes"

	if [ ! -d "${POSHDIR}" ]; then
		mkdir $POSHDIR || exit 1
	fi

	cd $POSHDIR || exit 1
	if [[ "$(ls | grep -E '\.(json|zip)$')" ]]; then
		echo "Cleaning: `pwd`"
		rm ./*
	fi

	wget $THEME_URL -O $POSHDIR/themes.zip
	unzip $POSHDIR/themes.zip -d $POSHDIR
	chmod u+rw $POSHDIR/*.json
	rm $POSHDIR/themes.zip
	cd -
}

View_themes () {
	Cmd_exists || exit 1
	local SHELLY='\nFrom: %b\n%s shelly\n'
	
	if [ -z "${1}" ]; then 
		for _style in ~/.poshthemes/*.omp.json; do
			printf "$SHELLY" "$_style" "$(oh-my-posh --config $_style --shell universal)"
		done
	else
		THEME_VIEW=~/.poshthemes/${1}.omp.json
		if [ -r "$THEME_VIEW" ]; then
			printf "$SHELLY" "$THEME_VIEW" "$(oh-my-posh --config $THEME_VIEW --shell universal)"
		else
			echo "Theme doesn't exist: $1"
		fi
	fi
	echo -e '\nTHANK YOU\nHAVE NICE DAY\n'
}

Export_posh_theme () {
	cat <<- EOF
	# oh-my-posh-theme
	SET_OMP_THEME="$1"
	eval "\$(oh-my-posh --init --shell bash --config ~/.poshthemes/\${SET_OMP_THEME}.omp.json)"

	EOF
}

Set_themes () {
	local SED_SEARCH="$(grep -E '^SET_OMP_THEME=' ${HOME}/.bashrc)"

	if [ ! -r "${HOME}/.poshthemes/${1}.omp.json" ]; then
		echo "Theme: <${1}> doesnt exist?!"; exit 1

	elif [ -z "${SED_SEARCH}" ]; then
		Export_posh_theme "$1" | tee -a $HOME/.bashrc

	else
		local SED_SWITCH="${SED_SEARCH%%=*}=\"${1}\""
		sed -i s/$SED_SEARCH/$SED_SWITCH/ $HOME/.bashrc
	fi
	cat <<- 'EOF'
	To apply changes do one of the following;

	   * Logout and log back in
	   * `source ~/.bashrc`
	   * `. ~/.bashrc`

	EOF
}

case "${1}" in
	--get-omp )  
		Install_oh_my_posh && Get_themes 
		;;
	--set )  
		shift; Set_themes "$1" 
		;;
	-v | --view )  
		shift; View_themes "$1"
		;;
	* ) 
		Usage 
		;;
esac



