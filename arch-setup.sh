#!/usr/bin/env bash

# Exit if running as root
if [[ $EUID < 1 ]]; then
	echo "Error: Don't run $0 as root. Instead, run it as a user with sudo privileges."
	exit 1
fi

######################
# Define color utils #
######################
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
purple=$(tput setaf 5)

print_header() {
	printf "\n${bold}${purple}==========  %s  ==========${reset}\n" "$@"
}

print_success() {
	printf "${green}✔ %s${reset}\n" "$@"
}

print_warning() {
	printf "${yellow}➜ %s${reset}\n" "$@"
}

print_error() {
	printf "${red}✖ %s${reset}\n" "$@"
}

print_underline() {
	printf "${underline}${bold}%s${reset}\n" "$@"
}

print_bold() {
	printf "${bold}%s${reset}\n" "$@"
}

print_note() {
	printf "${underline}${bold}${blue}Note:${reset}  ${blue}%s${reset}\n" "$@"
}

#########################
# Set up error handling #
#########################
on_error_exit() {
	local command=$BASH_COMMAND
	print_error "Error: Failed to run $command"
}

set -eo pipefail
trap on_error_exit ERR

####################
# Install packages #
####################
print_header "Installing standard packages"
sudo pacman -S --needed - < pkglist.txt

##########################
# Install other programs #
##########################
install() {
	local command=$1
	if [ -x "$(command -v $command)" ]; then
		print_warning "Warning: $command is already installed -- skipping."
	else
		cd "$HOME"
		install_$command
		print_success "Installed $command."
	fi
}

install_yay() {
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
}

print_header "Installing other packages"
install yay
