#!/usr/bin/env bash

# Exit if running as root
if [[ $EUID < 1 ]]; then
	echo "Error: Don't run $0 as root. Instead, run it as a user with sudo privileges."
	exit 1
fi

# Install packages
sudo pacman -S --needed - < pkglist.txt

# Install other programs
install() {
	local command=$1
	if [ -x "$(command -v $command)" ]; then
		echo "Warning: $command is already installed -- skipping."
	else
		cd "$HOME"
		install_$command
	fi
}

install_yay() {
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
}

install yay
