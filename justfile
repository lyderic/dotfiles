version := "202403041315"

alias up  := machine-update
alias ve  := version
alias col := colors
alias geo := geolocate

_listing:
	@printf "${BLU}{{justfile()}}${NOC}\n"
	@just --unsorted --list --list-heading='' --list-prefix=' • ' \
		| grep -v 'alias for'

# [up]date distribution and configuration
[no-exit-message]
machine-update: 
	#!/bin/bash
	chezmoi update
	blue "distro: {{distro}}"
	[ -x /usr/bin/apt ] && {
		sudo apt-get -y update
		sudo apt-get -y upgrade
		sudo apt-get -y dist-upgrade
		sudo apt-get -y autoremove
		sudo apt-get -y autoclean
		sudo apt-get -y clean
	}
	[ -x /usr/bin/flatpak ] && flatpak update
	[ -x /usr/bin/snap ] && sudo snap refresh
	[ -x /usr/bin/pacman ] && {
			sudo pacman -Syu
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

# [geo] where am I?
geolocate:
	curl -sf "http://ip-api.com/line/?fields=query,city,country,isp"

# [ve]rsion of this script
version:
	# {{version}}

# DYNAMIC VARIABLES & SETTINGS

distro := `grep ^ID= /etc/os-release | cut -d= -f2`

set shell := ["bash","-uc"]
# vim: ft=make
