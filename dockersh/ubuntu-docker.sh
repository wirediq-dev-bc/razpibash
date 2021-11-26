#!/bin/bash

# ubuntu-docker.sh: Download docker for Ubuntu-20.04.
#
# Install framework adapted from the script found at "get.docker.com".
# I suggest looking at it before running this script.
# This only covers Ubuntu-20.04 running on arm64 or x86_64.
# Debian friendly commands, so may cover Kali distros, zero guaruntees.
# Any other distro you should probably run `rsnapshot` first.
#
# Kernel configuration check written by Moby project developers.
# Downloads and executes w/o modifications.
# Running without root priviliges causes inaccurate output.
#
# Moby Project GitHub: https://github.com/moby/moby
# Script Source: https://github.com/moby/moby/blob/master/contrib/check-config.sh


PROGNAME=${0##*/}
VALIDATOR='https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh'
KEY_URL='https://download.docker.com/linux/ubuntu/gpg'
LOCAL_KEY='/usr/share/keyrings/docker-archive-keyring.gpg'
DOCKER_SRC='/etc/apt/sources.list.d/docker.list'


Usage () {
    cat <<- EOF

Installer script for host machines running Ubuntu-20.04 LTS (Server)
usage: 
  ./$PROGNAME --check-kernel 
  ./$PROGNAME --install [ --quiet ]

 $PROGNAME --kernel-check
  * Validate kernel config for docker compatability.
  * Note this runs automatically when docker is installed.
  * Requires root for the report to print w/o random errors.

 DRY_RUN=1 $PROGNAME --install
  * Perform dry-run install to see commands that will be run.

 $PROGNAME --install [ --quiet ]
  * Performs kernel-check before install and prompts user to proceed.
  * QUIET ENABLED ONLY IF [ --quiet ] IS LAST ARGUMENT.
  * Sanity test install with 'docker run -rm hello-world'.

---------------------------------------------------
* INSTALL WILL FAIL FAST IF DOCKER COMMAND EXISTS *
---------------------------------------------------
* INSTALL WILL FAIL FAST WITHOUT ROOT PRIVILIGES *
---------------------------------------------------

This can be achieved multiple ways:

1) Prefix command with sudo.
   * sudo ./$PROGNAME --install [ --quiet ]

2) If user($USER) is member of 'sudo group'.
   * id -Gn == $USER is member of
   * id -Gn > $(id -Gn)

3) Run in root shell (Use with caution).
   * This script uses ~/tmp. Use 'sudo cmd'.

Alternatively try rootless install (corporate/enterprise systems).
You should have root privileges on your own hardware.

EOF
exit 1
}

Need_root () {
    cat <<- EOF

This installer needs root privilages to execute properly.
Fallback methods to gain required privilages under [ $user ] failed.
Return if you have admin privilages otherwise look into rootless installs.

EOF
exit 1
}

Docker_exists () {
    cat <<- EOF

Please verify docker isn't already installed on this machine.

Docker executable @ $(which docker)

This can be checked on the command line with:
   * which docker
   * command -v docker
   * docker --help

>>> Halting Install <<<

EOF
exit 1
}

Prog_error () {
    echo -e "error: $1\n"
    exit 1
}

Cmd_exists () {
    command -v "$@" > /dev/null 2>&1
}

Docker_usergroups () {
    local MADE_CHANGES=
    if ! grep -qE 'docker' /etc/group; then
        $sh_c 'groupadd docker' && MADE_CHANGES=1
    fi
    if ! id | grep 'docker' > /dev/null; then
        $sh_c "usermod -aG docker $USER" && MADE_CHANGES=1
    fi
    [ $MADE_CHANGES ] && $sh_c 'newgrp docker'
}

Get_docker () {
    # Add docker upstream sources to /etc/apt/sources.list.d/ directory.
    local SRC_DOWNLOAD="https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    local APT_REPO="deb [arch=$(dpkg --print-architecture) signed-by=${LOCAL_KEY}] $SRC_DOWNLOAD"
    $sh_c "echo \"$APT_REPO\" | tee $DOCKER_SRC > /dev/null"

    # docker-ce: docker client
    # docker-ce-cli: docker client command line interface
    # containerd.io: container abstraction layer
    $sh_c 'apt-get update -y > /dev/null'
    $sh_c 'apt-get install -y docker-ce docker-ce-cli containerd.io'
}

Get_docker_key () {
    # Get docker GPG key and add to keyring.
    if [ ! -f "${LOCAL_KEY}" ]; then
        $sh_c "curl -fsSL $KEY_URL | gpg --dearmor -o $LOCAL_KEY"
    else
        echo -e '\nDockers gpg key already exists on this machine.'
        echo -e "Find key @ $LOCAL_KEY"
        echo -e 'Skipping: get_docker_gpg_key\n'
    fi
}

Check_kernel_config () {
    # Check kernel configuration for docker compatability.
    # Download script into ~/tmp and remove when finished.
    # See $VALIDATOR global variable at top of script.
    if [ ! -d ~/tmp ]; then 
        mkdir ~/tmp || Prog_error "No $USER/tmp!?!"
    fi

    # Update and run docker kernel config check script.
    cd ~/tmp
    local VSCRIPT='check-config.sh'
    [ -f $VSCRIPT ] && rm ./$VSCRIPT
    if $sh_c "curl -fsSL $VALIDATOR -o ./$VSCRIPT"; then
        $sh_c "chmod 755 ./$VSCRIPT; ./$VSCRIPT; rm ./$VSCRIPT"
    fi
    cd - > /dev/null
}

Prepare_host () {
    # Check kernel configuration for compatability with docker engine
    # Prompt user unless --install flag is followed by --quiet.
    Check_kernel_config 

    if [[ ! "$1" =~ ^--quiet$ ]]; then
        read -p "Proceed with install? (y/n): "
      
        if [[ ! "$REPLY" =~ ^(Y|Yes|yes|y)$ ]]; then
            echo "Goodbye Friend" && return 1
        
        elif Cmd_exists docker; then
            Docker_exists
        fi
    fi

    $sh_c 'apt-get update -y'
    $sh_c 'apt-get upgrade -y'
    $sh_c 'apt-get install -y ca-certificates curl gnupg lsb-release'

    Get_docker_key && Get_docker && Docker_usergroups
}

Check_privs () {
    user="$(id -un 2> /dev/null || true)"
    if [ "$user" == 'root' ]; then
        sh_c='sh -c'
    elif Cmd_exists sudo; then
        sh_c='sudo -E sh -c'
    else
        Need_root "$user"
        return 1
    fi
    return 0
}


DRY_RUN=${DRY_RUN:-}
if [ -n "$DRY_RUN" ]; then
    sh_c='echo'; unset 'DRY_RUN'
elif [ -n "$1" ]; then
    Check_privs
else
    Usage
fi

case "$1" in
    --install ) 
        shift; Prepare_host "$1"
        ;;
    --kernel-check )
        Check_kernel_config 
        ;;
    -h | --help )
        Usage
        ;;
    --* )
        Prog_error "UnknownToken: $1" 
        ;;
esac

