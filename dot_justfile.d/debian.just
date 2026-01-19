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
	[ -x /usr/bin/snap ] && {
		sudo snap refresh
	}
	exit 0

# (re)bootstrap
boostrap:
	@curl -sL https://lola.lyderic.com/bootstrap | sudo bash
