#!/bin/bash

# dryrun-setup.sh: 

DRY_RUN=${DRY_RUN:-}
while [ $# -gt 0 ]; do
	case "$1" in
		--mirror)
			mirror="$2"
			shift
			;;
		--dry-run)
			DRY_RUN=1
			;;
		--*)
			echo "Illegal option $1"
			;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done

is_dry_run() {
	if [ -z "$DRY_RUN" ]; then
		return 1
	else
		return 0
	fi
}

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

if command_exists docker; then
	cat >&2 <<-'EOF'
			Warning: the "docker" command appears to already exist on this system.

			If you already have Docker installed, this script can cause trouble, which is
			why we're displaying this warning and provide the opportunity to cancel the
			installation.

			If you installed the current Docker package using this script and are using it
			again to update Docker, you can safely ignore this message.

			You may press Ctrl+C now to abort this script.
		EOF
		( set -x; sleep 20 )
fi

user="$(id -un 2>/dev/null || true)"

sh_c='sh -c'
if [ "$user" != 'root' ]; then
	if command_exists sudo; then
		sh_c='sudo -E sh -c'
	elif command_exists su; then
		sh_c='su -c'
	else
		cat >&2 <<-'EOF'
		Error: this installer needs the ability to run commands as root.
		We are unable to find either "sudo" or "su" available to make this happen.
		EOF
		exit 1
	fi
fi

if is_dry_run; then
	sh_c="echo"
fi


if ! command -v gpg > /dev/null; then
	pre_reqs="$pre_reqs gnupg"
fi

if ! is_dry_run; then
	set -x
fi

$sh_c 'apt-get update -qq >/dev/null'
$sh_c "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $pre_reqs >/dev/null"
$sh_c "curl -fsSL \"$DOWNLOAD_URL/linux/$lsb_dist/gpg\" | gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg"


