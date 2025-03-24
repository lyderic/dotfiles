#!/bin/bash

# CONFIGURATION
binurl="https://github.com/marcosnils/bin/releases/download/v0.20.0/bin_0.20.0_linux_amd64"
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
	ubuntu-packages
	ubuntu-binaries
	ubuntu-configure
}

ubuntu-packages() {
	local packages="${COMMON_PACKAGES} ${UBUNTU_PACKAGES}"
	header "ubuntu packages"
	$sudo apt-get update && $sudo apt-get -y install ${packages}
}

ubuntu-binaries() {
	header "ubuntu binaries"
	local pbin="$(command -v bin)"
	[ -x "${pbin}" ] || {
		pbin=/dev/shm/bin;
		curl -L -o $pbin "${binurl}";
		chmod -v +x $pbin
		sudo chmod -v 777 /usr/local/bin
	}
	declare -A binaries
	binaries[bin]="https://github.com/marcosnils/bin"
	binaries[just]="https://github.com/casey/just"
	binaries[fzf]="https://github.com/junegunn/fzf"
	binaries[croc]="https://github.com/schollz/croc"
	binaries[bat]="https://github.com/sharkdp/bat"
	binaries[gdu]="https://github.com/dundee/gdu"
	for binary in "${!binaries[@]}"; do
		[ -x "/usr/local/bin/$binary" ] && {
			warn "$binary found"
			continue
		}
		$pbin install "${binaries[$binary]}"
	done
}

ubuntu-configure() {
	header "ubuntu configure fzf"
	[ -f "${vimdir}/plugin/fzf.vim" ] && return
	cd /dev/shm
	[ -d fzf ] && rm -rf fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git
	cd /dev/shm/fzf ; ./install --bin
	sudo cp -uv /dev/shm/fzf/plugin/fzf.vim ${vimdir}/plugin
	sudo cp -uv /dev/shm/fzf/doc/fzf.txt ${vimdir}/doc
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
bash bash-completion curl direnv file git htop sudo
tmux vim
"

# Additional packages for archlinux
ARCH_PACKAGES="
croc diffutils bat duf fzf gdu grep just less pacman-contrib \
the_silver_searcher tree which
"

# Additional packages for ubuntu/debian
UBUNTU_PACKAGES="dialog grep less silversearcher-ag tree"

# Additional packages for alpine
ALPINE_PACKAGES="
croc diffutils fzf gdu just the_silver_searcher which
"

main ${@}
