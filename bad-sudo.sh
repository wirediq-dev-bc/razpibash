#!/bin/bash

# bad-sudo.sh: Find out why sudo doesnt prompt for password

sudo grep -HRn NOPASSWD /etc/sudoers.d/

