#!/bin/bash

# get-posh.sh: Download and install oh-my-posh and related theme files.

Usage () {
	cat <<- EOF

usage: ${0##*/} [ --get-omp ] [ --view ] [ --set <theme> ]

Flags:
  --get-omp ) Install oh-my-posh and download themes
  --view ) View all themes stored in ~/.poshthemes
  --set ) Set shell theme from file in ~/.poshthemes

EOF
exit 1
}

Cmd_exists () {
	command -v oh-my-posh > /dev/null 2>&1
}

Install_oh_my_posh () {
	# Find your distro-pkg @ https://github.com/JanDeDobbeleer/oh-my-posh/releases/tag/v5.16.3
	local ARM64_bin='https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v5.16.3/posh-linux-arm64'
	local POSH_BIN='/usr/local/bin/oh-my-posh'
	if Cmd_exists; then
		oh-my-posh --help
		return
	else
		sudo wget $ARM64_bin -O $POSH_BIN
		sudo chmod +x $POSH_BIN
		return 0
	fi
}

Get_themes () {
	# TODO `find ~/.poshthemes -newer` -> update
	local THEME_URL='https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip'
	local POSH="${HOME}/.poshthemes"
	mkdir $POSH
	wget $THEME_URL -O $POSH/themes.zip
	unzip $POSH/themes.zip -d $POSH
	chmod u+rw $POSH/*.json
	rm $POSH/themes.zip
}

View_themes () {
	if Cmd_exists; then
		for style in ~/.poshthemes/*.omp.json; do
			echo -e "${style}\n$(oh-my-posh --config $style --shell universal)\n"
		done
	fi
}

Set_themes () {
	local SET_THEME="${HOME}/.poshthemes/${1}.omp.json"
	if [ ! -r "${SET_THEME}" ]; then
		echo "${SET_THEME} doesnt exist!"
	else
		printf -v OMP '"$(oh-my-posh --init --shell bash --config %s)"' "$SET_THEME"
		echo "eval $OMP" >> $HOME/.bashrc
		source "${HOME}/.bashrc"
	fi
}

case "${1}" in
	--get-omp )  Install_oh_my_posh && Get_themes ;;
	--view )  View_themes ;;
	--set )  shift; Set_themes "$1" ;;
	* ) Usage ;;
esac



