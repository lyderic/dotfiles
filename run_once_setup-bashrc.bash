#!/bin/bash

main() {
	[ -e "${HOME}/.bigbang" ] || die "no .bigbang found!"
	grep --quiet ".bigbang" "${HOME}/.bashrc" || {
		echo "source \$HOME/.bigbang" | tee -a "${HOME}/.bashrc"
	}
	cyan ".bashrc set"
}

# DISPLAY
cyan() { echo -e "${CYA}${@}${NOC}" ; }
header() { echo -e "${BLU}[${@}]${NOC}" ; }
ok() { echo -e "${GRN}${@}${NOC}" ; }
warn() { echo -e "${YEL}${@}${NOC}" ; }
die() { echo -e "${RED}${@}${NOC}" ; exit 42 ; }
export RED="\e[0;31m" GRN="\e[0;32m" YEL="\e[0;33m"
export BLU="\e[0;34m" MAG="\e[0;35m" CYA="\e[0;36m"
export NOC="\e[0m"

main ${@}
