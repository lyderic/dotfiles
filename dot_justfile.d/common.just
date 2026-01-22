common-version := "20260119-0"

alias up    := base::update
alias vi    := base::vigilax
alias ip    := base::ip
alias ansi  := base::ansi
alias ghbin := base::ghbin
alias h     := _help

_help:
	@just --list --unsorted --alias-style left --color always \
		--list-heading= --list-prefix='  ' \
		| sed -e "s/\[alias: /\[/" | awk 'NF'

# used by vim's ansi plugin
_wait:
	#!/bin/bash
	echo -ne "\e[2;3;34mPlease any key to continue...\e[m"
	read -sn 1
	echo

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

# BAse CONfiguration files
# To use:
# in ~/justfile, create a variable 'baconfiles' e.g.:
# baconfiles := "/path/to/file /path/to/dir /path/to/another"
# When you run 'just _bacon' all these files will be put in
# ~/.bacon.tgz for backup along with the justfile and .env* files
# This is useful for systemd services in /etc/systemd/system and
# and other configuration files
_bacon:
	#!/bin/bash
	[ -z "${baconfiles}" ] && exit 0
	archive="${HOME}/.bacon.tgz"
	[ -f "${archive}" ] || {
		echo -ne "\e[33m${archive} not found. Create? [y/N]? \e[m"
		read yesno ; [[ "${yesno,,}" =~ ^(y|yes)$ ]] || exit 0
		for file in ${baconfiles}; do
			[ -e "${file}" ] || echo -e "\e[31m${file}: file not found!\e[m"
		done
		tar Pczvf "${archive}" ${baconfiles}
	}
	echo -e "\e[34m[tar content]\e[m"
	tar Ptzvf "${archive}"
	echo -e "\e[34m[tar deployment check]\e[m"
	tar Pdzvf "${archive}" && {
		echo -e "\e[32mall deployed ok\e[m"
		exit 0
	}
	echo -ne "\e[33m(re)deploy ${archive}? [y/N]? \e[m"
	read yesno ; [[ "${yesno,,}" =~ ^(y|yes)$ ]] || exit 0
	sudo tar Pxzvwf "${archive}"

# MODULES
# base commands and tools
[group('common')]
mod base
# arch commands
[group('common')]
mod? arch
# debian commands
[group('common')]
mod? debian
# ubuntu commands
[group('common')]
mod? ubuntu
# raspbian commands
[group('common')]
mod? raspbian
# fedora commands
[group('common')]
mod? fedora

# DYNAMIC VARIABLES, SETTINGS AND IMPORTS

[private]
v:
	@just --evaluate

LUA_PATH := home_dir()/".local/share/lua/?.lua;/usr/share/lua/5.4/?.lua"
sys := "sudo -E systemctl"
set shell := ["bash","-uc"]
set export
set dotenv-load
