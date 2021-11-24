#!/bin/bash

# ubuntu-docker.sh: Download docker for Ubuntu-20.04.

# Adapted from the script found at "get.docker.com".
# I suggest looking at it before running this script.
# This only covers Ubuntu-20.04 running on arm64 or x86_64.
# Debian based so it may cover Kali distros too, no guaruntees.
# If you run anything else I doubt this will work.


PROGNAME=${0##*/}
VALIDATOR='https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh'
KEY_URL='https://download.docker.com/linux/ubuntu/gpg'
LOCAL_KEY='/usr/share/keyrings/docker-archive-keyring.gpg'
DOCKER_SRC='/etc/apt/sources.list.d/docker.list'


Usage () {
    cat <<- EOF

Installer script for host machines running Ubuntu-20.04 LTS (Server)

---------------------------------------------------
usage: $PROGNAME

 DRY_RUN=1 ./$PROGNAME --install
  - Run installer script and validate install (see footer).
  - Performs kernel-check during install.

 ./$PROGNAME --install
  - Perform dry-run install with kernel-check.
  - If the docker command exists installer exits early.

 ./$PROGNAME --kernel-check
  - Validate kernel config for docker compatability.
  - Note this runs automatically when docker is installed.
  - Requires root for the report to print w/o random errors.

---------------------------------------------------
* INSTALL WILL FAIL FAST WITHOUT ROOT PRIVILIGES *

Gaining root can be achieved multiple ways:
 1) Prefix command with sudo
 2) $USER belongs to 'sudo' usergroup
 3) Run in root shell (Use with caution)

Alternatively try rootless install if none of the above are allowed.

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
    cat <<- "EOF"

Please verify docker isn't already installed on this machine.

This can be done with:
   * which docker
   * command -v docker
   * docker --help

Exiting installer

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
    Check_kernel_config 
    read -p "Proceed with install? "
    if [[ ! "$REPLY" =~ ^(Y|Yes|yes|y)$ ]]; then
        echo "Goodbye Friend" && return 1
    elif Cmd_exists docker; then
        Docker_exists
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
        Prepare_host 
        ;;
    --kernel-check )
        Check_kernel_config 
        ;;
    --* )
        Prog_error "UnknownToken: $1" 
        ;;
esac

