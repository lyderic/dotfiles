#!/bin/bash

main() {
	[ $(id -u) -eq 0 ] || sudo="sudo"
	[ -e /etc/os-release ] && {
		DISTRO=$(awk -F= '/^ID=/ {print $2}' /etc/os-release)
	}
	echo -e "Distribution: \e[33m${DISTRO}\e[m"
	case "${DISTRO}" in
		"ubuntu" | "debian") ubuntu ;;
		"arch" | "archarm") arch ;;
		"alpine") alpine ;;
		*) die "${DISTRO}: only archlinux, ubuntu and alpine are supported" ;;
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
	local packages="${COMMON_PACKAGES} ${UBUNTU_PACKAGES}"
	header "ubuntu packages"
	$sudo apt-get update && $sudo apt-get -y install ${packages}
	curl --proto '=https' --tlsv1.2 -sSf \
		https://just.systems/install.sh \
		| $sudo bash -s -- --to /usr/local/bin
	# bat is in ubuntu's repo but gets installed as 'batcat'
	[ -x /usr/bin/bat ] || $sudo ln -s /usr/bin/batcat /usr/bin/bat
}

alpine() {
	local packages="${COMMON_PACKAGES} ${ALPINE_PACKAGES}"
	header "alpine packages"
	$sudo apk -U upgrade
	$sudo apk add ${packages}
}

# DISPLAY
header() { echo -e "\e[34m${@}\e[m"; }
ok() { echo -e "\[32m${@}\e[m"; }
warn() { echo -e "\e[33m${@}\e[m"; }
die() {
	echo -e "\e[31m${@}\e[m"
	exit 42
}

# Packages that are common to arch, ubuntu and alpine
COMMON_PACKAGES="
bash bash-completion bat curl direnv file git htop sudo
tmux vim
"

# Additional packages for archlinux
ARCH_PACKAGES="
croc diffutils duf fzf gdu grep just less pacman-contrib \
the_silver_searcher tree which
"

# Additional packages for ubuntu/debian
UBUNTU_PACKAGES="grep less silversearcher-ag tree"

# Additional packages for alpine
ALPINE_PACKAGES="
croc diffutils fzf gdu just the_silver_searcher which
"

main ${@}
