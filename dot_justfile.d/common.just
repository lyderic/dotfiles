common-version := "202507081041"

alias up  := update

_help:
	@just --list --unsorted --alias-style left --color always \
		--list-heading= --list-prefix='  ' \
		| sed -e "s/\[alias: /\[/" | awk 'NF'

# update distro and config
[group('common')]
[no-exit-message]
update:
	#!/bin/bash
	echo -e "\e[34m[chezmoi]\e[0m"
	chezmoi update
	echo -e "\e[34m[chezmoi (root)]\e[0m"
	sudo chezmoi update
	echo -e "\e[34m[distro:${distro}]\e[0m"
	just {{distro}}::update

# deploy/update github binaries
[group('common')]
ghbin:
	just {{distro}}::ghbin

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

# IPv4 addresses
[group('common')]
ip:
	#!/usr/bin/lua
	require("lee")
	data = json.decode(ea("ip -j -4 address")); buf = {}
	for i = 1, #data do
		addresses = data[i]["addr_info"]
		for _, a in pairs(addresses) do
			if a["label"] == "lo" then goto next end
			table.insert(buf, f("%s %s\n", a["label"], a["local"]))
		::next::;end
	end
	x(f('echo "%s" | column -t', table.concat(buf)))

# lee lua module doc
[group('common')]
leedoc:
	@lua -l lee -e "leedoc()"

# check machine uptime, disk space, updates needed, etc.
[group('common')]
vigilax:
	@~/.justfile.d/vigilax.lua | yq -P 

# github binaries
# _install_ghbin and _ghbin depend on the distro, hence
# they are called in arch.just and ubuntu.just
_ghbin: _install_ghbin
	#!/usr/bin/env lua
	require("lee")
	data = ea("curl -sL https://lola.lyderic.com/cgi-bin/state")
	items = json.decode(data)
	for _,i in pairs(items) do
		path = "/usr/local/bin/"..i.binary
		if not abs(path) then goto next end
		bits = {}
		for bit in eo("cksum "..path):gmatch("%S+") do
			table.insert(bits, bit)
		end
		cksum = bits[1] ; size = bits[2]
		printf("\27[1m%-8.8s  \27[m", i.binary..":")
		if cksum == i.cksum and size == i.size then
			printf("\27[90mup to date (sum=%s, size=%s)\27[m\n", cksum, size)
		else
			print("\27[32mupdate available\27[m")
			x("sudo rm -v "..path)
			x("just _install_ghbin "..i.binary)
		end
	::next::;end

_install_ghbin *$binaries:
	#!/bin/bash
	set -e
	for binary in ${binaries}; do
		[ -x /usr/local/bin/${binary} ] && continue
		echo -e "\e[7m ${binary} \e[m"
		curl -LO https://lola.lyderic.com/gz/${binary}.gz
		dst="/usr/local/bin/${binary}"
		sudo sh -c "gzip -dc ${binary}.gz > ${dst}"
		sudo chown -v 0:0 "${dst}"
		sudo chmod -v 0755 "${dst}"
		sudo rm -v "${binary}.gz"
	done

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

# DYNAMIC VARIABLES, SETTINGS AND IMPORTS

[private]
v:
	@just --evaluate

LUA_PATH := home_dir()/".local/share/lua/?.lua;/usr/share/lua/5.4/?.lua"
sys := "sudo -E systemctl"
distro := `awk -F= '/^ID=/ {print $2}' /etc/os-release`
set shell := ["bash","-uc"]
set export
# vim: ft=just
