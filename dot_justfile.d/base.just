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

# github binaries
ghbin:
	#!/usr/bin/env -S lua -llee
	ghbinaries = {"emd","wait4x"}
	ubuntu_ghbinaries = {"chezmoi","bat","croc","fzf","yq","just"}
	if env("distro") == "ubuntu" then
		for _,i in ipairs(ubuntu_ghbinaries) do
			table.insert(ghbinaries, i)
		end
	end
	data = ea("curl -sL https://lola.lyderic.com/cgi-bin/state")
	state = json.decode(data)
	for _,ghbinary in ipairs(ghbinaries) do
		path = "/usr/local/bin/"..ghbinary
		if not abs(path) then
			x("just base::_deploy_ghbin "..ghbinary) ; goto nxt
		end
		cksum, size = eo("cksum "..path):match("(%d+) (%d+)")
		for _,i in ipairs(state) do
			if i.binary == ghbinary then
				printf("\27[1m%-8.8s  \27[m", ghbinary..":")
				if cksum == i.cksum and size == i.size then
					printf("\27[90mup to date (sum=%s, size=%s)\27[m\n",
					cksum, size)
				else
					print("\27[32mupdate available\27[m")
					x("just base::_deploy_ghbin "..ghbinary)
				end
			end
		end
	::nxt::end

# This recipe installs a binary in /usr/local/bin
# If the binary is found, it is overwritten, which allows for a new
# version to be deployed
# 'binaries' are defined in arch.just or ubuntu.just, as there are
# not the same for each distro
_deploy_ghbin $binary:
	#!/bin/bash
	set -e
	echo -e "\e[7m ${binary} \e[m"
	curl -LO https://lola.lyderic.com/gz/${binary}.gz
	dst="/usr/local/bin/${binary}"
	tmp=$(mktemp)
	gzip -dc ${binary}.gz > "${tmp}"
	sudo mv -v ${tmp}" "${dst}"
	sudo chown -v 0:0 "${dst}"
	sudo chmod -v 0755 "${dst}"

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
