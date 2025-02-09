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
