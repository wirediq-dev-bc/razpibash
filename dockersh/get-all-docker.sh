#!/bin/bash

# get-docker.sh: Setup resources for and download docker
# TODO Why `get.docker.com/.sh` doesn't install containerd.io?
# TODO [ `cat /etc/debian_version` != `lsb_release -cs`] ???

PROGNAME=${0##*/}
VALIDATOR='https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh'
KEY_URL='https://download.docker.com/linux/ubuntu/gpg'
LOCAL_KEY='/usr/share/keyrings/docker-archive-keyring.gpg'
DOCKER_SRC='/etc/apt/sources.list.d/docker.list'


Usage () {
	cat <<- EOF

Installer script for host machines running Ubuntu-20.04 LTS (Server)

Usage:

  $PROGNAME --install )
    - Run installer script and validate install.

  $PROGNAME --kernel-check )
    - Validate kernel config for docker compatability.
	- Note this runs automatically when docker is installed.

EOF
unset VALIDATOR KEY_URL LOCAL_KEY DOCKER_SRC PROGNAME
exit 1
}

Prog_error () {
	echo -e "error: $1\n"
	exit 1
}

Cmd_exists () {
	command -v "$@" > /dev/null 2>&1
}

Get_dependencies () {
	# Not sure this func needed for ubuntu builds?
	# Aren't these default installs? 
	$sh_c 'sudo apt-get update -y > /dev/null'
	$sh_c 'sudo apt-get install -y ca-certificates curl gnupg lsb-release'
}

Get_docker_key () {
	# Get docker GPG key and add to keyring.
	if [ -e "${LOCAL_KEY}" ]; then
		echo -e '\nDocker gpg key already exists on this machine\n'
		return 0
	fi
	$sh_c "curl -fsSL $KEY_URL | sudo gpg --dearmor -o $LOCAL_KEY"
}

Get_docker () {
	# Adds docker upstream source, and installs following;
	#  docker-ce: docker client
	#  docker-ce-cli: docker client command line interface
	#  containerd.io: container abstraction layer
	if Cmd_exists docker; then
		Prog_error 'Is docker alread installed on this machine?'
	fi

	# Add docker upstream sources to /etc/apt/sources.list.d
	local SRC_DOWNLOAD="https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	local APT_REPO="deb [arch=$(dpkg --print-architecture) signed-by=${LOCAL_KEY}] $SRC_DOWNLOAD"
	$sh_c "echo \"$APT_REPO\" | sudo tee $DOCKER_SRC > /dev/null"

	# Quiet update; docker install to stdout
	$sh_c 'sudo apt-get update -y > /dev/null'
	$sh_c 'sudo apt-get install -y docker-ce docker-ce-cli containerd.io' 
}

Docker_usergroups () {
	local MADE_CHANGES=
	if ! grep -qE 'docker' /etc/group; then
		$sh_c 'sudo groupadd docker' && MADE_CHANGES=1
	fi
	if ! id | grep 'docker' > /dev/null; then
		$sh_c "sudo usermod -aG docker $USER" && MADE_CHANGES=1
	fi
	[ $MADE_CHANGES ] && $sh_c 'newgrp docker'
}

Check_kernel_config () {
	# Check kernel configuration for docker compatability.
	# Download script into ~/tmp and remove when finished.
	# See $VALIDATOR global variable at top.
	local VSCRIPT='check-config.sh'
	[ ! -d ~/tmp ] && { mkdir ~/tmp || Prog_error 'No ~/tmp!?!'; }
	
	cd ~/tmp
	[ -f $VSCRIPT ] && rm ./$VSCRIPT
	if curl -fsSL $VALIDATOR -o ./$VSCRIPT; then
		chmod 755 ./$VSCRIPT && sudo ./$VSCRIPT
		rm ./$VSCRIPT
	fi
	cd - > /dev/null
}

Parse_args () {
	local KERN_CHK=
	while [ -n "$1" ]; do
		case "$1" in
			--install )
				KERN_CHK=1
				Get_docker_key && Get_docker && Docker_usergroups 
				;;
			--kernel-check )  
				KERN_CHK=1 
				;;
			--* )  
				Prog_error "UnknownToken: $1" 
				;;
		esac
		shift
	done
	[ "$KERN_CHK" ] && Check_kernel_config
}

sh_c='echo'
RUN_LIVE=${RUN_LIVE:-}
if [ -n "$RUN_LIVE" ]; then
	#sh_c='sh -c'
	echo 'RUNNING'
elif [ -z "$@" ]; then
	Prog_error 'Null command line input'
fi
Parse_args "$@"

