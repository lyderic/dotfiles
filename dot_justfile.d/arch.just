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
vnc-xfce4: _check_gui_allowed
	#!/bin/bash
	set -e
	# don't reinstall if already there
	[ -d ~/.vnc ] && exit 0
	sudo pacman -S --needed xorg-server noto-fonts xfce4 tigervnc
	echo ":0=${USER}" | sudo tee /etc/tigervnc/vncserver.users
	mkdir -v ~/.vnc && cd ~/.vnc
	echo -e "session=openbox\ngeometry=1920x1000\nlocalhost" > config
	[ -f passwd ] || vncpasswd
	echo -e "\e[33mnow start and possibly enable vncserver@:0\e[m"

# install xfce4 accessible by RDP
xrdp-xfce4: _check_gui_allowed
	#!/bin/bash
	# don't reinstall if already there
	pacman -Q xrdp && exit 0
	sudo pacman -Syu --needed base-devel xorg-server noto-fonts xfce4
	# https://aur.archlinux.org/packages/xorgxrdp#comment-889055
	gpg -k 61ECEABBF2BB40E3A35DF30A9F72CDBC01BF10EB || {
		gpg --receive-keys 61ECEABBF2BB40E3A35DF30A9F72CDBC01BF10EB 
	}
	mkdir -pv repositories
	for p in xrdp xorgxrdp; do
		pacman -Q $p && continue
		cd repositories
		[ -d $p ] || git clone https://aur.archlinux.org/${p}.git
		makepkg -D $p -si
	done
	[ -f ~/.xinitrc ] || {
		echo "startxfce4" > ~/.xinitrc
		chmod +x ~/.xinitrc
	}

_check_gui_allowed:
	# no remote access for root
	[ $(id -u) != "0" ]
	# no remote access on wayland
	[ ${XDG_SESSION_TYPE-x} != "wayland" ]
	# no remote access on workstations
	[ ! -f ~/.workstation ]

# ghbinaries
@ghbin:
	just _install_ghbin {{ghbinaries}}
	just _ghbin

ghbinaries := "emd wait4x"
