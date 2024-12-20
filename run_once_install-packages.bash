#!/bin/bash

main() {
	[ -e /etc/os-release ] && {
		DISTRO=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2)
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
			sudo sed -i -e "s/^#${item}/${item}/" /etc/pacman.conf
			warn "${item} uncommented in /etc/pacman.conf"
		}
	done
	header "arch packages"
	sudo pacman -S --noconfirm --needed ${packages}
}

ubuntu() {
	local packages="${COMMON_PACKAGES} ${UBUNTU_PACKAGES}"
	header "ubuntu packages"
	sudo apt-get update && sudo apt-get -y install ${packages}
	# As of 22.04, just is not in ubuntu's repos :(
	[ -x /usr/local/bin/just ] || {
		curl -sL --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh |
			sudo bash -s -- --to /usr/local/bin && ok "just successfully installed"
	}
	# bat is in ubuntu's repo but gets installed as 'batcat'
	[ -x /usr/bin/bat ] || sudo ln -s /usr/bin/batcat /usr/bin/bat
}

# DISPLAY
header() { echo -e "\e[34m${@}\e[m"; }
ok() { echo -e "\[32m${@}\e[m"; }
warn() { echo -e "\e[33m${@}\e[m"; }
die() {
	echo -e "\e[31m${@}\e[m"
	exit 42
}

# Packages that are common to arch and ubuntu
COMMON_PACKAGES="
bash
bash-completion
bat
curl
direnv
file
git
grep
htop
less
sudo
tmux
tree
vim
"

# Packages present only on archlinux
ARCH_PACKAGES="
croc
diffutils
duf
fzf
gdu
just
pacman-contrib
the_silver_searcher
which
"

# Packages present only on ubuntu
UBUNTU_PACKAGES="
silversearcher-ag
"

main ${@}
