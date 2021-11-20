#!/bin/bash

# get-bpf-tools.sh: 


Get_bpftrace () {
	# Install bpftrace from upstream sources
	sudo apt-get install -y libbpffcc-dev
}

Compile_bcc () {
	# Compile BPF Compiler Collection (bcc) from source archive.
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
	sudo apt-get update -qq > /dev/null
	sudo apt-get upgrade -qq > /dev/null
	if ! command -v etckeeper; then
		sudo apt-get install -y etckeeper
	fi
	if apt-cache show amazon-ssm-agent > /dev/null; then
		sudo dpkg -r amazon-ssm-agent || sudo snap remove amazon-ssm-agent
	fi
}

Prepare_host && Build_bcc_toolchain && Compile_bcc && Get_bpftrace

