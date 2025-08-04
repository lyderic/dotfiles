common-version := "20250804-0"

alias up    := base::update
alias vi    := base::vigilax
alias ip    := base::ip
alias ansi  := base::ansi
alias ghbin := base::ghbin
alias h     := _help
alias hh    := _full_help

_help:
	@just --list --unsorted --alias-style left --color always \
		--list-heading= --list-prefix='  ' \
		| sed -e "s/\[alias: /\[/" | awk 'NF'

_full_help: _help
	#!/bin/bash
	for module in base ${distro}; do
	echo -e "  \e[1;94m[${module} module]\e[m"
		just --list "${module}" --unsorted --alias-style left \
			--color always --list-heading= --list-prefix='  ' \
			| sed -e "s/\[alias: /\[/" | awk 'NF'
	done

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

# MODULES
# base commands and tools
[group('common')]
mod base
# arch commands
[group('common')]
mod? arch
# ubuntu commands
[group('common')]
mod? ubuntu

# DYNAMIC VARIABLES, SETTINGS AND IMPORTS

[private]
v:
	@just --evaluate

LUA_PATH := home_dir()/".local/share/lua/?.lua;/usr/share/lua/5.4/?.lua"
sys := "sudo -E systemctl"
distro := `awk -F= '/^ID=/ {print $2}' /etc/os-release`
set shell := ["bash","-uc"]
set export
set dotenv-load
# vim: ft=just
