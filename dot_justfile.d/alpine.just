# update alpine
update:
	#!/bin/bash
	sudo apk -U upgrade
	sudo apk -v cache clean
