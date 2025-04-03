common-version := "202503041508"

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

# github binaries
[group('common')]
ghbin: _install_ghbin
	#!/usr/bin/env lua
	require("lee")
	data = ea("curl -sL https://lola.lyderic.com/state.json")
	items = json.decode(data)
	for _,i in pairs(items) do
		path = "/usr/local/bin/"..i.binary
		if not abs(path) then goto next end
		cksum = eo("sha256sum "..path.." | awk '{print $1}'")
		printf("\27[1m%-8.8s  \27[m", i.binary..":")
		if cksum == i.cksum then
			print("\27[90mup to date\27[m")
		else
			print("\27[32mupdate available\27[m")
			os.remove(path)
			x("just _install_ghbin")
		end
	::next::;end

_install_ghbin:
	#!/bin/bash
	set -e
	for binary in {{ghbinaries}}; do
		[ -x /usr/local/bin/${binary} ] && continue
		echo -ne "\e[7m ${binary} \e[m"
		curl -LO https://lola.lyderic.com/${binary}
		dst="/usr/local/bin/${binary}"
		sudo mv -iv ${binary} "${dst}"
		sudo chown -v 0:0 "${dst}"
		sudo chmod -v 0755 "${dst}"
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

export LUA_PATH := home_dir()/".local/share/lua/?.lua;/usr/share/lua/5.4/?.lua"
confirm := "true"
sys := "sudo -E systemctl"
export distro := `awk -F= '/^ID=/ {print $2}' /etc/os-release`
lbinaries := "emd wait4x"
ghbinaries := if distro == "ubuntu" { lbinaries + " bat croc fzf just yq" } else { lbinaries }
set shell := ["bash","-uc"]
# vim: ft=just
