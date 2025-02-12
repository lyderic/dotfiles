# update archlinux
update $confirm="true":
	#!/bin/bash
	[ "${confirm}" == "true" ] || noconfirm="--noconfirm"
	sudo pacman -Syu ${noconfirm}
	sudo paccache -rk 1
	printf "\e[7;93m"
	reviews=$(sudo pacdiff -o)
	orphans=$(sudo pacman -Qtd)
	[ -z "${reviews}" ] || echo -e "*** REVIEWS ***\n${reviews}"
	[ -z "${orphans}" ] || echo -e "*** ORPHANS ***\n${orphans}"
	printf "\e[m"

# remove archlinux orphans
[no-exit-message]
orphans:
	pacman -Qtd
	sudo pacman -Qtdq | sudo pacman -Rns -

# deep clean archlinux cache
deep-clean:
	sudo paccache -ruk0
	sudo pacman -Sc --noconfirm

# install xfce4 accessible by vnc
gui:
	#!/bin/bash
	set -e
	[ $(id -u) == "0" ] && die no vnc for root
	[ -d ~/.vnc ] && die vnc already installed for ${USER}
	sudo pacman -S --needed xorg-server noto-fonts xfce4 tigervnc
	echo ":0=${USER}" | sudo tee /etc/tigervnc/vncserver.users
	mkdir -v ~/.vnc && cd ~/.vnc
	echo -e "session=openbox\ngeometry=1920x1000\nlocalhost" > config
	[ -f passwd ] || vncpasswd
	echo -e "\e[33mnow start and possibly enable vncserver@:0\e[m"
