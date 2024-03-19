common-version := "202403071022"

alias col := colors
alias geo := geolocate
alias var := variables

_listing:
	@printf "${BLU}{{justfile()}}${NOC}\n"
	@just --unsorted --list --list-heading='' --list-prefix=' • ' \
		| grep -v 'alias for'

# if 'false' updates are unattended
# [up]date distro and config
[no-exit-message]
up *confirm="true":
	#!/bin/bash
	echo -e "\e[34m[chezmoi]\e[0m"
	chezmoi update
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
	}

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
	for i in $(seq 1 4) ; do
		echo -ne "\e[${i}m ${i}\e[m "
	done
	# we don't display 5 & 6, as they are blinking
	# which is annoying to the eye
	echo -e " 5  6 \e[7m 7\e[m"
	for i in $(seq 31 37) ; do
		echo -ne "\e[${i}m${i} "
	done ; echo -e "\e[m"
	for i in $(seq 91 97) ; do
		echo -ne "\e[${i}m${i} "
	done ; echo -e "\e[m"
	for i in $(seq 41 47) ; do
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
