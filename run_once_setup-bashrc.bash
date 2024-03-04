#!/bin/bash

[ -e "${HOME}/.bigbang" ] || {
	echo -e "\e[31mno .bigbang found!\e[0m"
	exit 42
}
grep --quiet "bigbang" "${HOME}/.bashrc" || {
	echo "source \$HOME/.bigbang" | tee -a "${HOME}/.bashrc"
}
echo -e "\e[36m.bashrc set\e[0m"
