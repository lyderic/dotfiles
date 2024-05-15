common-version := "202403071022"

alias col := colors
alias geo := geolocate
alias var := variables

_listing:
	@printf "${BLU}{{justfile()}}${NOC}\n"
	@just --no-aliases --unsorted --list \
		--list-heading='' --list-prefix=' • '

# if 'false' updates are unattended
# [up]date distro and config
[no-exit-message]
up *confirm="true":
	#!/bin/bash
	echo -e "\e[34m[chezmoi]\e[0m"
	chezmoi update
	echo -e "\e[34m[chezmoi (root)]\e[0m"
	sudo chezmoi update
	echo -e "\e[34m[distro:{{distro}}]\e[0m"
	[ -x /sbin/apk ] && {
		sudo apk -U upgrade
		sudo apk -v cache clean
	}
	[ -x /usr/bin/apt ] && {
		[ "{{confirm}}" == "true" ] && yes="-y"
		sudo apt-get ${yes} update
		sudo apt-get ${yes} upgrade
		sudo apt-get ${yes} dist-upgrade
		sudo apt-get ${yes} autoremove
		sudo apt-get ${yes} autoclean
		sudo apt-get ${yes} clean
	}
	[ -x /usr/bin/pacman ] && {
		[ "{{confirm}}" == "true" ] || noconfirm="--noconfirm"
			sudo pacman -Syu ${noconfirm}
			sudo paccache -rk 1
			printf "\e[7;93m"
			reviews=$(sudo pacdiff -o)
			orphans=$(sudo pacman -Qtd)
			[ -z "${reviews}" ] || echo -e "*** REVIEWS ***\n${reviews}"
			[ -z "${orphans}" ] || echo -e "*** ORPHANS ***\n${orphans}"
			printf "\e[m"
	}

# remove archlinux orphans
[no-exit-message]
arch-remove-orphans:
	[ -x /usr/bin/pacman ]
	pacman -Qtd
	sudo pacman -Qtdq | sudo pacman -Rns -

# [col] show bigbang colors
colors:
	#!/bin/bash
	header "header: bigbang colors"
	for prefix in "" B G BG ; do
		#printf "[%-3s] " "${prefix}"
		printf "(${prefix}) "
		for color in RED GRN YEL BLU MAG CYA ; do
			colorcode="${prefix}${color}"
			printf "${!colorcode}${color} "
		done | column -t
	done | column -t 
	printf "${NOC}"

# show ANSI codes
ansi:
	#!/bin/bash
	for i in 1 2 3 4 7 9; do
		echo -ne "\e[${i}m  ${i}\e[m "
	done ; echo
	for i in $(seq 30 37) ; do
		echo -ne "\e[${i}m ${i} "
	done ; echo -e "\e[m"
	for i in $(seq 90 97) ; do
		echo -ne "\e[${i}m ${i} "
	done ; echo -e "\e[m"
	for i in $(seq 40 47) ; do
		echo -ne "\e[${i}m ${i} "
	done ; echo -e "\e[m"
	for i in $(seq 100 107) ; do
		echo -ne "\e[${i}m${i} "
	done ; echo -e "\e[m"

# [geo] where am I?
geolocate:
	curl -sf "http://ip-api.com/line/?fields=query,city,country,isp"

# [var] evaluate variables
variables:
	just --evaluate

# DYNAMIC VARIABLES, SETTINGS AND IMPORTS

import? "justfile-host"
distro := `grep ^ID= /etc/os-release | cut -d= -f2`
set shell := ["bash","-uc"]
# vim: ft=make
