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
		"ubuntu" | "debian") ubuntu ;;
		"arch" | "archarm") arch ;;
		*) die "${DISTRO}: only archlinux and ubuntu are supported" ;;
	esac
	echo -e "\e[36mbase packages installed\e[m"
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

ubuntu() {
	ubuntu-packages
	ubuntu-fzf-vim-plugin
}

ubuntu-packages() {
	local packages="${COMMON_PACKAGES} ${UBUNTU_PACKAGES}"
	header "ubuntu packages"
	$sudo apt-get update && $sudo apt-get -y install ${packages}
}

ubuntu-fzf-vim-plugin() {
	header "ubuntu configure fzf"
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

# Packages that are common to arch and ubuntu
COMMON_PACKAGES="
bash bash-completion gdu curl direnv file git htop sudo
tmux vim lua-dkjson
"

# Additional packages for archlinux
ARCH_PACKAGES="
croc diffutils bat duf fzf gdu lua grep just less pacman-contrib \
the_silver_searcher tree which
"

# Additional packages for ubuntu/debian
UBUNTU_PACKAGES="dialog grep less lua5.4 silversearcher-ag tree bsdextrautils"

main ${@}
