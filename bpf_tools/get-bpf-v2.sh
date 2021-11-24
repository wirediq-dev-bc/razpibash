#!/bin/bash

# get-bpf-tools.sh: A script to build base AMI images.

KERNEL_CHECK='https://github.com/iovisor/bpftrace/blob/master/scripts/check_kernel_features.sh'


Get_bpftrace () {
	# Install `bpftrace` from upstream sources.
	if curl -fsSL $KERNEL_CHECK -o bpf_kern_chk.sh; then
		chmod 755 bpf_kern_chk.sh
		./bpf_kern_chk.sh || exit 1
		rm ./bpf_kern_chk
	fi

	if ! command -v bpftrace; then
		sudo apt-get install -y --no-install-recommends bpftrace
	fi
}

Compile_bcc () {
	# Compile `bcc` (BPF Compiler Collection) from source archive.
	{ git clone https://github.com/iovisor/bcc.git;
		mkdir bcc/build; 
		cd bcc/build;
		cmake ..;
		make;
		sudo make install;
		cmake -DPYTHON_CMD=python3 ..;
		pushd src/python;
		make;
		sudo make install;
		popd;
	} || return 1
}

Build_bcc_toolchain () {
	# Build necessary requirements for to compile bcc
	sudo apt-get install -y --no-install-recommends \
		bison \
		build-essential \
		cmake \
		flex \
		git \
		libedit-dev \
		libllvm7 \
		llvm-7-dev \
		libclang-7-dev \
		python \
		zlib1g-dev \
		libelf-dev \
		libfl-dev \
		python3-distutils || return 1
}

Prepare_host () {
	# Update host and install etckeeper
	sudo apt-get update -y
	sudo apt-get upgrade -y
	sudo apt-get install -y etckeeper

	if apt-cache show amazon-ssm-agent > /dev/null; then
		sudo dpkg -r amazon-ssm-agent 
		sudo snap remove amazon-ssm-agent
	fi

	# Recommended by bcc installer
	sudo apt-get install -y arping netperf iperf

	# Clone latency heat mapping repo from Brenden Gregg's github.
        # Clone Flamegraphs from Brenden Greggs github.
	[ ! -d ~/bin ] && mkdir ~/bin
	if cd ~/bin; then
		git clone 'https://github.com/brendangregg/HeatMap.git'
                git clone 'https://github.com/brendangregg/FlameGraph.git'
		cd -
	fi
}

# Perform operations in ~/tmp directory; remove when finished.
if [ ! -d $HOME/tmp ]; then
	mkdir $HOME/tmp || exit 1
fi

if cd ~/tmp; then
	Check_kernel && 
		Prepare_host && 
		Build_bcc_toolchain && 
		Compile_bcc && 
		Get_bpftrace
        cd ~/tmp && rm -rf ./*
fi

