# update fedora
update:
	#!/bin/bash
	sudo dnf upgrade

dkjson:
	#!/bin/bash
	path="${HOME}/.local/share/lua/dkjson.lua"
	[ -e "${path}" ] && exit 0
	curl -s -L -o "${path}" https://lola.lyderic.com/lua/dkjson.lua

