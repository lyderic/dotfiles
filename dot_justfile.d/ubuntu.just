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

# install/update croc
croc:
	curl https://getcroc.schollz.com | sudo bash

# install/update fzf
fzf:
	#!/bin/bash
	cd /dev/shm
	[ -d fzf ] && rm -rf fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git
	cd /dev/shm/fzf ; ./install --bin
	sudo cp -uv /dev/shm/fzf/bin/fzf {{lbin}}
	sudo cp -uv /dev/shm/fzf/plugin/fzf.vim {{vimdir}}/plugin
	sudo cp -uv /dev/shm/fzf/doc/fzf.txt {{vimdir}}/doc

# update just
just:
	sudo mv -v {{lbin}}/just {{lbin}}/just.old
	curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin

lbin := "/usr/local/bin"
vimdir := "/usr/share/vim/vim91"
