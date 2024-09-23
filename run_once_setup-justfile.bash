#!/bin/bash

FILE="${HOME}/justfile"

[ -e "${FILE}" ] && exit 0

echo '_default: _help

import? "justfile-host"
import  "justfile-common"

# vim: ft=make' | tee "${FILE}"

echo -e "\e[36mjustfile set\e[0m"
