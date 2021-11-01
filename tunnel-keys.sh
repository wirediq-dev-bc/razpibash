#!/bin/bash

# tunnel-keys.sh: Pass ssh keys to remote host

Usage () {
	cat <<- EOF

usage: ${0##*/} <remote_username> <remote_ip_addr>

EOF
exit 1
}

Key_check () {
	if [[ -e $HOME/.ssh/id_rsa && -e $HOME/.ssh/id_rsa.pub ]]; then
		return 0
	else
		ssh-keygen -t rsa
	fi
}
	
Pass_key () {
	[[ ! "${1}" || ! "${2}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && 
		Usage

	local UNAME="${1}" HOSTIP="${2}"
	ssh-copy-id -n $UNAME@$HOSTIP
	read -p 'PassKey? (y/n): '
	case "${REPLY}" in
		y | yes )  ssh-copy-id -i ~/.ssh/id_rsa$UNAME@$HOSTIP ;;
		* )  exit 1 ;;
	esac
}

Key_check && Pass_key "$1" "$2"

