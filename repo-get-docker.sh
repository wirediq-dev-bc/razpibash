#!/bin/bash

# get-docker.sh: Setup resources for and download docker

KEY_URL='https://download.docker.com/linux/ubuntu/gpg'
LOCAL_KEY='/usr/share/keyrings/docker-archive-keyring.gpg'
DOCKER_SRC='/etc/apt/sources.list.d/docker.list'
DOWNLOAD_URL='https://download.docker.com/linux/ubuntu'

Prog_error () {
	echo $1
	exit 1
}

Cmd_exists () {
	command -v "$@" > /dev/null 2>&1
}

Get_dependencies () {
	sudo apt-get update
	sudo apt-get install ca-certificates curl gnupg lsb-release
}

Get_docker_key () {
	if [ -e "${LOCAL_KEY}" ]; then
		Prog_error 'Docker gpg key already exists locally?'
	fi
	curl -fsSL $KEY_URL | sudo gpg --dearmor -o $LOCAL_KEY || Prog_error 'GPG failed'
}

Get_docker () {
	if Cmd_exists docker; then
		Prog_error 'Is docker alread installed on this machine?'
	fi
	local SRC_DOWNLOAD="${DOWNLOAD_URL}/$(lsb_release -cs) $(lsb_release -rs) stable"
	local APT_REPO="deb [arch=$(dpkg --print-architecture)] signed-by=${LOCAL_KEY} $SRC_DOWNLOAD"
	echo $APT_REPO > $DOCKER_SRC
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io
}

Docker_usergroups () {
	sudo groupadd docker
	sudo usermod -aG docker $USER
	newgrp docker
}

Kernel_compat () {
	local SCRIPT_URL='https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh'
	cd "${HOME}/bin/rpibash" &&
		curl $CHK_SCRIPT > ./check-config.sh &&
		chmod 755 ./check-config.sh && 
		./check-config.sh && 
		cd -
}

Get_docker_key
Get_docker
Docker_usergroups
Kernal_compat

echo 'Test with: `docker run hello-world`'

