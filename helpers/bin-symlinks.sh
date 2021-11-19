#!/bin/bash

# bin-symlinks.sh: 

UBIN="${HOME}/bin"

Link_loader () {
	declare -A LNKS
	# LNKS['']=./

	# Git Config/Workflow Scripts ./gitbash
	LNKS['gituser']=./gitbash/git-users.sh
	LNKS['gitrepo']=./gitbash/git-repos.sh
	LNKS['gitcom']=./gitbash/git-commits.sh

	# Python Runtime Scripts ./pybash
	LNKS['venvpy']=./pybash/venv-mngr.sh
	LNKS['pippy']=./pybash/pip-mngr.sh
	
	# Helper Scripts ./rpibash
	LNKS['bashqwik']=./rpibash/bashqwik.sh
	LNKS['scprpi']=./rpibash/scp-rpi.sh

	cd $UBIN
	for slink in "${!LNKS[@]}"; do
		if [ ! -e "${slink}" ]; then
			echo ">>> ln -s ${LNKS[${slink}]} $slink"
			ln -s ${LNKS[${slink}]} $slink
		fi
	done
}

if [ ! -e "${UBIN}" ]; then
	echo 'Creating ~/bin directory...'
	mkdir $HOME/bin || exit 1
fi

Link_loader
