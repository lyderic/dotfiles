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

# lua posix for ubuntu 22.04
luaposix22:
	#!/bin/bash
	[ "$(lsb_release -sr)" == "22.04" ] || exit 77
	[ -d /usr/local/lib/lua/5.4/posix ] && {
		echo -e "\e[33mluaposix already installed\e[m"
		exit 33
	}
	read -p "Really install luaposix from source [yN]? " yesno
	[[ "${yesno,,}" =~ ^(y|yes)$ ]] || exit 11
	sudo apt-get install lua5.4 liblua5.4 git gcc
	mkdir -p ~/repositories
	cd ~/repositories
	[ -d luaposix ] || git clone https://github.com/luaposix/luaposix.git
	cd ~/repositories/luaposix
	./build-aux/luke
	sudo ./build-aux/luke install
