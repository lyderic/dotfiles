#!/bin/bash

DISTRO=$(grep -E '^ID=' /etc/*-release | cut -d'=' -f2)

main() {
	echo -e "Distribution: ${YEL}${DISTRO}${NOC}"
	case "${DISTRO}" in
		"ubuntu"|"debian") ubuntu ;;
		"arch"|"archarm")  arch   ;;
		"alpine")          alpine ;;
		*) die "${DISTRO}: only archlinux and ubuntu are supported" ;;
	esac
	cyan "base packages installed"
}

arch() {
	local packages="${COMMON_PACKAGES} ${ARCH_PACKAGES}"
	header "pacman setup"
	grep '^ParallelDownloads' /etc/pacman.conf || {
		sudo sed -i -e 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
		warn "ParallelDownloads uncommented in /etc/pacman.conf"
	}
	header "arch packages"
	sudo pacman -S --noconfirm --needed ${packages}
}

ubuntu() {
	local packages="${COMMON_PACKAGES} ${UBUNTU_PACKAGES}"
	header "ubuntu packages"
	sudo apt-get update && sudo apt-get -y install ${packages}
	# As of 22.04, just is not in ubuntu's repos :(
	[ -x /usr/local/bin/just ] || {
	curl -sL --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
		| sudo bash -s -- --to /usr/local/bin && ok "just successfully installed"
	}
	# bat is in ubuntu's repo but gets installed as 'batcat'
	[ -x /usr/bin/bat ] || sudo ln -s /usr/bin/batcat /usr/bin/bat
}

alpine() {
	local packages="${COMMON_PACKAGES} ${ALPINE_PACKAGES}"
	header "alpine packages"
	sudo apk update
	sudo apk add ${packages}
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

# Packages that are common to arch and ubuntu
read -r -d '' COMMON_PACKAGES << \
----------------------------------------------------------------
bash
bash-completion
bat
curl
file
git
grep
htop
less
sudo
tmux
tree
vim
----------------------------------------------------------------

# Packages present only on archlinux
read -r -d '' ARCH_PACKAGES << \
----------------------------------------------------------------
croc
diffutils
duf
fzf
gdu
just
pacman-contrib
the_silver_searcher
which
----------------------------------------------------------------

# Packages present only on ubuntu
read -r -d '' UBUNTU_PACKAGES << \
----------------------------------------------------------------
silversearcher-ag
----------------------------------------------------------------

# Packages present only on alpine
read -r -d '' ALPINE_PACKAGES << \
----------------------------------------------------------------
croc
diffutils
fzf
gdu
just
the_silver_searcher
vimdiff
which
----------------------------------------------------------------

main ${@}
