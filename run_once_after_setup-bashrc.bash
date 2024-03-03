#!/bin/bash

main() {
	[ -e "${HOME}/.bigbang" ] || die "no .bigbang found!"
	for name in bigbang workstation ; do
		[ -e "${HOME}/.${name}" ] || continue
		grep --quiet "${name}" "${HOME}/.bashrc" || {
			echo "source \$HOME/.${name}" | tee -a "${HOME}/.bashrc"
		}
	done
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
