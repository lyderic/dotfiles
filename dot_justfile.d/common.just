common-version := "202502230655"

alias up  := update

_help:
	@just --list --unsorted --alias-style left --color always \
		--list-heading= --list-prefix='  ' \
		| sed -e "s/\[alias: /\[/"

# if 'false' updates are unattended
# update distro and config
[group('common')]
[no-exit-message]
update:
	#!/bin/bash
	echo -e "\e[34m[chezmoi]\e[0m"
	chezmoi update
	#echo -e "\e[34m[chezmoi (root)]\e[0m"
	#sudo chezmoi update
	echo -e "\e[34m[distro:${distro}]\e[0m"
	just {{distro}}::update {{confirm}}

# show ANSI codes
[group('common')]
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

# used by vim's ansi plugin
_wait:
	#!/bin/bash
	echo -ne "\e[2;3;34mPlease any key to continue...\e[m"
	read -sn 1
	echo

# where am I?
[group('common')]
geolocate:
	curl -sf "http://ip-api.com/line/?fields=query,city,country,isp"

# terminal dimensions
[group('common')]
@dimensions:
	echo "$(tput cols) x $(tput lines)"

# Nice show of services for status
_services:
	#!/bin/bash
	[ -z "${services}" ] && exit 0
	max=0
	for word in ${services}; do
		ln=${#word}
		((ln > max)) && max=$ln
	done
	sc="\e[1m"; up="\e[32m"; down="\e[2m"; nc="\e[m"
	for service in ${services} ; do
		e=$({{sys}} is-enabled "${service}")
		a=$({{sys}} is-active "${service}")
		[ "${e}" == "enabled" ] && ec="${up}" || ec="${down}"
		[ "${a}" == "active" ] && ac="${up}" || ac="${down}"
		printf "${sc}%-*s${nc}   ${ec}%-10.10s${nc} ${ac}%s${nc}\n" \
		$max "${service}" "${e}" "${a}"
	done

# MODULES
# arch commands
[group('common')]
mod? arch
# ubuntu commands
[group('common')]
mod? ubuntu
# alpine commands
[group('common')]
mod? alpine

# DYNAMIC VARIABLES, SETTINGS AND IMPORTS

[private]
v:
	@just --evaluate

confirm := "true"
export distro := `awk -F= '/^ID=/ {print $2}' /etc/os-release`
set shell := ["bash","-uc"]
# vim: ft=just
