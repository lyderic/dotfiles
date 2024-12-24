#!/bin/bash

[ -e "${HOME}/.bigbang" ] || {
	echo -e "\e[31mno .bigbang found!\e[0m"
	exit 42
}
grep -qxF "source \$HOME/.bigbang" "${HOME}/.bashrc" || {
	echo -e "\e[1;33mbigbang not sourced in ~/.bashrc, fixing...\e[m"
	echo "source \$HOME/.bigbang" | tee -a "${HOME}/.bashrc"
	echo -e "\e[1;32m.bashrc set\e[m"
}
