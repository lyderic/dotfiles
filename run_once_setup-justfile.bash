#!/bin/bash

FILE="${HOME}/justfile"

[ -e "${FILE}" ] && exit 0

echo 'import "justfile-common"
_default: _help' | tee "${FILE}"

echo -e "\e[36mjustfile set\e[0m"
