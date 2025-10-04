base-version := "20251003.0"

_help:
	@just --list --unsorted --alias-style left --color always \
		--list-heading= --list-prefix='  ' \
		| sed -e "s/\[alias: /\[/" | awk 'NF'

# update distro and config
[no-exit-message]
update:
	#!/bin/bash
	echo -e "\e[34m[chezmoi]\e[0m"
	chezmoi update
	echo -e "\e[34m[chezmoi (root)]\e[0m"
	sudo chezmoi update
	echo -e "\e[34m[distro:${distro}]\e[0m"
	just {{distro}}::update

# check machine uptime, disk space, updates needed, etc.
vigilax:
	@~/.justfile.d/vigilax.lua | yq -P 

# install single binaries from github
ghbin:
	@~/.justfile.d/ghbin.lua

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

# used by vim's ansi plugin
_wait:
	#!/bin/bash
	echo -ne "\e[2;3;34mPlease any key to continue...\e[m"
	read -sn 1
	echo

# where am I?
geolocate:
	curl -sf "http://ip-api.com/line/?fields=query,city,country,isp"

# terminal dimensions
@dimensions:
	echo "$(tput cols) x $(tput lines)"

# IPv4 addresses
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
leedoc:
	@lua -l lee -e "leedoc()"

export distro := `awk -F= '/^ID=/ {print $2}' /etc/os-release`
