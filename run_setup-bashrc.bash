#!/bin/bash

[ -e "${HOME}/.bigbang" ] || {
	echo -e "\e[31mno .bigbang found!\e[0m"
	exit 42
}
grep -qxF "source \$HOME/.bigbang" "${HOME}/.bashrc" || {
	warn "bigbang not sourced in ~/.bashrc, fixing..."
	echo "source \$HOME/.bigbang" | tee -a "${HOME}/.bashrc"
	ok ".bashrc set"
}
