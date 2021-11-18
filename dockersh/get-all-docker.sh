#!/bin/bash

# get-docker.sh: Setup resources for and download docker
# TODO why `get.docker.com/.sh` doesn't install containerd.io?

KEY_URL='https://download.docker.com/linux/ubuntu/gpg'
LOCAL_KEY='/usr/share/keyrings/docker-archive-keyring.gpg'
DOCKER_SRC='/etc/apt/sources.list.d/docker.list'

Prog_error () {
	echo $1
	exit 1
}

Proceed () {
	read -p 'Proceed: '
	case "${REPLY}" in
		y | yes ) 
			return 0
			;;
		* )
			exit 1
			;;
	esac
}

Cmd_exists () {
	command -v "$@" > /dev/null 2>&1
}

Get_dependencies () {
	# Not sure this is needed?
	sudo apt-get update -qq > /dev/null
	sudo apt-get install ca-certificates curl gnupg lsb-release
}

Get_docker_key () {
	if [ -e "${LOCAL_KEY}" ]; then
		echo -e '\nDocker gpg key already exists on this machine\n'
		return 0
	fi
	curl -fsSL $KEY_URL | sudo gpg --dearmor -o $LOCAL_KEY
}

Get_docker () {
	# Adds docker upstream repos, downloads 
	# docker-ce: docker client
	# docker-ce-cli: docker client command line interface
	# containerd.io: container abstraction layer
	if Cmd_exists docker; then
		Prog_error 'Is docker alread installed on this machine?'
	fi

	# Include docker upstream sources to /etc/apt/sources.list file
	# [ `cat /etc/debian_version` != `lsb_release -cs`] ???
	local DOWNLOAD_URL='https://download.docker.com/linux/ubuntu'
	local SRC_DOWNLOAD="${DOWNLOAD_URL} $(lsb_release -cs) stable"
	local APT_REPO="deb [arch=$(dpkg --print-architecture) signed-by=${LOCAL_KEY}] $SRC_DOWNLOAD"
	echo "$APT_REPO" | sudo tee "$DOCKER_SRC" > /dev/null

	# Quiet update, docker install output not redirected
	sudo apt-get -y -qq update > /dev/null
	sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io
}

Docker_usergroups () {
	sudo groupadd docker
	sudo usermod -aG docker $USER
	newgrp docker
}

Kernel_compat () {
	local SCRIPT_URL='https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh'
	cd "${HOME}/bin/rpibash" && {
		curl -fsSL $SCRIPT_URL -o ./check-config.sh &&
		chmod 755 ./check-config.sh && 
		./check-config.sh && 
		cd -; 
	} || return 1
}

case "${1}" in
	--install )
		echo "Get_docker_key && Get_docker && Docker_usergroups"
		;;
	--validate )
		Kernel_compat
		;;
	* ) 
		Prog_error 'unknown option token'
		;;
esac


