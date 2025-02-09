# update ubuntu
update $confirm="true":
	#!/bin/bash
	[ "${confirm}" == "true" ] && yes="-y"
	sudo apt-get ${yes} update
	sudo apt-get ${yes} upgrade
	sudo apt-get ${yes} dist-upgrade
	sudo apt-get ${yes} autoremove
	sudo apt-get ${yes} autoclean
	sudo apt-get ${yes} clean
	[ -x /usr/bin/snap ] && {
		sudo snap refresh
	}
