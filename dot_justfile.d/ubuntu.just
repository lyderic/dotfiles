# update ubuntu
update $confirm="true":
	#!/bin/bash
	set -e
	[ "${confirm}" == "true" ] && yes="-y"
	sudo apt-get update
	sudo apt-get ${yes} upgrade
	sudo apt-get ${yes} dist-upgrade
	sudo apt-get ${yes} autoremove
	sudo apt-get ${yes} autoclean
	sudo apt-get ${yes} clean
	[ -x /usr/bin/snap ] && {
		sudo snap refresh
	}
	exit 0

# ghbinaries
@ghbin:
	just _install_ghbin {{ghbinaries}}
	just _ghbin

ghbinaries := "emd wait4x bat croc fzf just yq"
