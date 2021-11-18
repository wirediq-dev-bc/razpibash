#!/bin/bash

# get-tools.sh: apt-get helpful stuff

# Networking
View_toolbox () {
	cat <<- 'EOF'
	
# Backups (AND RECOVERY?)
	 etckeeper (single initial install, log all following changes)
	 rsnapshot | bacula

# Meta-Zuckerburgs

# Development
	 binutils (gcc, make, ...)
	 golang-go
	 build-essentials (debian policy manual)

# Networking
	 dnsutils
	 inetutils

	 net-tools
	 netstat
	 nmap 
	 ncat 
	 ndiff 
	 apache2
	 apache2-utils

# Logging and Monitoring
	 nagios3 nagios-nrpe-plugin
	 nagios-nrpe-server
	 munin
	 munin-node
	 logwatch
	 sysstat

# Mail services
	 dovecot-imapd dovecot-pop3d (mail delivery agent)
	 sendmail | exim4 | postfix (mail transfer agent)

# VM's & Containers
	 qemu/kvm
	 libvirt
	 OpenStack (MicroStack ubuntu)
	 VirtualBox?
	 lxd | lxc

# Misc
	 tree 
	 natalius 
	 neofech 
	 parallel 
	 aspell
	 wamerican-large 
	 outguess
	 unzip 

# Scripted Installs
     gh (github-cli)
	 docker 
	 oh-my-{posh,zsh} 

# Rpi-Specific
	 libraspbi-config
	 vcgencmd

EOF
}




