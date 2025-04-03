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

# refresh or install lyderic's aur
aur:
	#!/bin/bash
	set -e
	[ -d ~/repositories/aur ] && git -C ~/repositories/aur pull && exit 0
	mkdir -pv ~/repositories
	git -C ~/repositories clone https://github.com/lyderic/aur
	sudo pacman -S --needed --noconfirm fakeroot

# install xfce4 accessible by vnc
gui: _check_gui_allowed
	#!/bin/bash
	set -e
	sudo pacman -S --needed xorg-server noto-fonts xfce4 tigervnc
	echo ":0=${USER}" | sudo tee /etc/tigervnc/vncserver.users
	mkdir -v ~/.vnc && cd ~/.vnc
	echo -e "session=openbox\ngeometry=1920x1000\nlocalhost" > config
	[ -f passwd ] || vncpasswd
	echo -e "\e[33mnow start and possibly enable vncserver@:0\e[m"
_check_gui_allowed:
	# no vnc for root
	[ $(id -u) != "0" ]
	# no vnc on wayland
	[ ${XDG_SESSION_TYPE-x} != "wayland" ]
	# no vnc on workstations
	[ ! -f ~/.workstation ]
	# don't reinstall if already there
	[ ! -d ~/.vnc ]

# ghbinaries
@ghbin:
	just _install_ghbin {{ghbinaries}}
	just _ghbin

ghbinaries := "emd wait4x"
