# update ubuntu
update:
	#!/bin/bash
	set -e
	[ $noconfirm == "yes" ] && arg="--yes"
	sudo apt-get ${arg} update
	sudo apt-get ${arg} upgrade
	sudo apt-get ${arg} dist-upgrade
	sudo apt-get ${arg} autoremove
	sudo apt-get ${arg} autoclean
	sudo apt-get ${arg} clean
	exit 0

# (re)bootstrap
boostrap:
	@curl -sL https://lola.lyderic.com/bootstrap | sudo bash
