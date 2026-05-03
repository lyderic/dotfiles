# update alpine
update:
	#!/bin/bash
	arg="-i"
	[ $noconfirm == "yes" ] && arg=
	sudo apk -U ${arg} upgrade
	sudo apk -v cache clean
