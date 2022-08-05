#!/usr/bin/env bash

# Exit if running as root
if [[ $EUID < 1 ]]; then
	echo "Error: Don't run $0 as root. Instead, run it as a user with sudo privileges."
	exit 1
fi

################
# Define utils #
################
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
	printf "${yellow} %s${reset}\n" "$@"
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

confirm() {
	printf "\n${bold}$@${reset}"
	read -p " (y/n) " -n 1 -r
	echo # move to a new line after read
	[[ $REPLY =~ ^[Yy]$ ]]
}

########################
# Print driver warning #
########################
print_warning "Warning: This script requires that you have already installed Xorg drivers for your hardware."
if ! confirm "Have you installed the Xorg drivers?"; then
	print_underline "Please install the Xorg driver(s) before running this script again."
	print_underline "Visit https://wiki.archlinux.org/title/Xorg for more information."
	exit
fi

#########################
# Set up error handling #
#########################
on_error_exit() {
	local command=$BASH_COMMAND
	print_error "Error: Failed to run '$command' on line $(caller)"
}

set -eEo pipefail
trap "on_error_exit $LINENO" ERR

####################
# Install packages #
####################
print_header "Installing standard packages"
sudo pacman -S --needed - < pkglist.txt

##########################
# Install other programs #
##########################
WORKING_DIR="$PWD"
install() {
	local command=$1
	if [ -x "$(command -v $command)" ]; then
		print_warning "Warning: $command is already installed -- skipping."
	else
		cd "$HOME"
		install_$command
		print_success "Installed $command."
		cd "$WORKING_DIR"
	fi
}

install_yay() {
	rm -rf yay
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
}

install_dwm() {
	rm -rf dwm
	git clone https://github.com/mestru17/dwm-flexipatch.git
	cd dwm-flexipatch
	sudo make clean install

	# Install logo
	local icon_dir="$HOME/.local/share/icons"
	mkdir -p "$icon_dir"
	cp dwm.png "$icon_dir/dwm.png"
}

install_dmenu() {
	rm -rf dmenu-flexipatch
	git clone https://github.com/mestru17/dmenu-flexipatch.git
	cd dmenu-flexipatch
	sudo make clean install
}

print_header "Installing other packages"
install yay
install dwm
install dmenu

########################
# Install AUR packages #
########################
print_header "Installing AUR packages"
readarray -t aur_pkgs < pkglist_aur.txt
for pkg in "${aur_pkgs[@]}"; do
	if pacman -Q "$pkg" &> /dev/null; then
		print_warning "Warning: $pkg is already installed -- skipping."
	else
		yay -S "$pkg"
		print_success "Installed $pkg."
	fi
done

########################
# Install config files #
########################
print_header "Configuring system and programs"

# TODO: Some directories might not exist when copying like this. Need to find a better way to do this.
sudo cp -r root/* /
print_success "Installed system level config files."

# Install dotfiles
curl -H "Cache-Control: no-cache" -Ls https://raw.githubusercontent.com/mestru17/arch-dotfiles/master/install_dotfiles | bash

###################
# Enable services #
###################
enable_service() {
	local service=$1
	if systemctl is-enabled "$service" 1> /dev/null; then
		print_warning "Warning: $service is already enabled -- skipping."
	else
		sudo systemctl enable "$service"
		print_success "Enabled $service"
	fi
}

print_header "Enabling services"
enable_service lightdm.service

#########################
# Print success message #
#########################
echo
print_success "Successfully ran $0."
