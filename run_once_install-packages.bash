#!/bin/bash

set -e

# CONFIGURATION
vimdir="/usr/share/vim/vim91"

main() {
	[ $(id -u) -eq 0 ] || sudo="sudo"
	[ -e /etc/os-release ] && {
		DISTRO=$(awk -F= '/^ID=/ {print $2}' /etc/os-release)
	}
	echo -e "Distribution: \e[33m${DISTRO}\e[m"
	case "${DISTRO}" in
		"alpine") alpine ;;
		"debian" | "ubuntu" | "raspbian") debian ;;
		"arch" | "archarm") arch ;;
		"fedora") fedora ;;
		*) die "${DISTRO}: only alpine, archlinux, debian, ubuntu and raspbian are supported" ;;
	esac
	echo -e "\e[36mbase packages installed\e[m"
}

alpine() {
	local packages="${COMMON_PACKAGES}"
	header "alpine packages"
	$sudo apk add "${COMMON_PACKAGES}"
}

arch() {
	local packages="${COMMON_PACKAGES} ${ARCH_PACKAGES}"
	header "pacman setup"
	for item in ParallelDownloads Color; do
		grep "^${item}" /etc/pacman.conf || {
			$sudo sed -i -e "s/^#${item}/${item}/" /etc/pacman.conf
			warn "${item} uncommented in /etc/pacman.conf"
		}
	done
	header "arch packages"
	$sudo pacman -S --noconfirm --needed ${packages}
}

debian() {
	debian-packages
	debian-base
}

fedora() {
	local packages="${COMMON_PACKAGES} ${FEDORA_PACKAGES}"
	header "fedora packages"
	$sudo dnf --assumeyes install ${packages}
	# dkjson is missing from fedora repositories
	# $sudo cp -uv dkjson.lua /usr/share/lua/5.4/dkjson.lua
	$sudo curl -L -o /usr/share/lua/5.4/dkjson.lua \
		"https://dkolf.de/dkjson-lua/dkjson-2.8.lua"
}

debian-packages() {
	local packages="${COMMON_PACKAGES} ${DEBIAN_PACKAGES}"
	header "debian packages"
	$sudo apt-get update && $sudo apt-get -y install ${packages}
}

debian-base() {
	header "configure fzf"
	[ -d "${vimdir}" ] || { warn "${vimdir} not found"; return; }
	[ -f "${vimdir}/plugin/fzf.vim" ] && return
	cd /dev/shm
	git clone --depth 1 https://github.com/junegunn/fzf.git
	sudo cp -uv fzf/plugin/fzf.vim ${vimdir}/plugin
	sudo cp -uv fzf/doc/fzf.txt ${vimdir}/doc
	rm -rf fzf
}

# DISPLAY
header() { echo -e "\e[34m${@}\e[m"; }
fail()   { echo -e "\e[31m${@}\e[m"; }
ok()     { echo -e "\e[32m${@}\e[m"; }
warn()   { echo -e "\e[33m${@}\e[m"; }
die()    { fail "${@}"; exit 42; }

# Packages that are common to arch and debian
COMMON_PACKAGES="
bash bash-completion gdu curl direnv file git htop tmux sudo tree
"

# Additional packages for archlinux
ARCH_PACKAGES="
bat croc diffutils duf fzf gdu lua lua-dkjson grep just less pacman-contrib \
the_silver_searcher tree which fakeroot go-yq vim
"

# Additional packages for ubuntu/debian
DEBIAN_PACKAGES="
dialog grep less lua5.4 lua-dkjson silversearcher-ag tree bsdextrautils vim
"

# Additional packages for fedora
FEDORA_PACKAGES="
just lua vim-enhanced
"

main ${@}
