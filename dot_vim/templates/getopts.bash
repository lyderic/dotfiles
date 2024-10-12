#!/bin/bash

# possibly redirect to file
#exec &>>/tmp/$(basename $0).log

DEBUG=true
#set -x

PROG_NAME="$(basename $0)"
CONFIG="${PROG_NAME}.conf"
VERBOSE=false

main() {
	while getopts "vc:" OPTION ; do
		case ${OPTION} in
			v) VERBOSE=true ;;
			c) CONFIG=${OPTARG} ;;
			*) usage ; exit ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	debug "prog starts here"
	debug "VERBOSE=${VERBOSE}"
	debug "CONFIG=${CONFIG}"
	INPUTS=${@}
	debug "INPUTS=${INPUTS[*]}"
}

usage() {
	echo "Usage: ${PROG_NAME}"
}

debug() {
	[ -z ${DEBUG} ] || {
		echo -e "\e[96m${@}\e[m"
	}
}

main ${@}
