# update fedora
update:
	#!/bin/bash
	[ $noconfirm == "yes" ] && arg="-y"
	sudo dnf upgrade ${arg}
	sudo dnf clean packages

