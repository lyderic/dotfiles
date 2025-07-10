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

ghbinaries := "emd wait4x bat croc fzf just yq"
# ghbinaries
@ghbin:
	just _install_ghbin {{ghbinaries}}
	just _ghbin
