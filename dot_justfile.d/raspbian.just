# update ubuntu
update:
	#!/bin/bash
	set -e
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get dist-upgrade
	sudo apt-get autoremove
	sudo apt-get autoclean
	sudo apt-get clean
	exit 0
