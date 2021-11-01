#!/bin/bash

# docker-convenience.sh: Download docker convenience script

GET_DOCKER='https://get.docker.com'
INSTALLER='get-docker.sh'

if [ ! -r $INSTALLER ]; then 
	curl -fsSL $GET_DOCKER -o $INSTALLER
	chmod 755 $INSTALLER
fi

