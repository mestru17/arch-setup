# arch-setup
Post installation script for Arch Linux. This script installs all of the software that I like to use and configures it to my liking.

## Prerequisites
There are three prerequisites to running this scripts:
1. You must have installed Arch Linux already. See the [Arch Installation Guide](https://wiki.archlinux.org/title/Installation_guide).
2. You must have installed appropriate graphics drivers for Xorg to run. See the wiki [article](https://wiki.archlinux.org/title/Xorg#Driver_installation) about Xorg driver installation.
3. You must have set up a user with sudo privileges. See [Users and groups](https://wiki.archlinux.org/title/Users_and_groups) and [Sudo](https://wiki.archlinux.org/title/Sudo) for instructions - I recommend assigning your user to the *wheel* group and configuring `sudo` to let all *wheel* group members use it.

You do not need to have set anything else up such as a graphical environment, although you will need a working internet connection and [git](https://git-scm.com), which can be installed with:
```bash
sudo pacman -S git
```

## Installation
Simply clone the repository and run the script:
```bash
git clone https://github.com/mestru17/arch-setup.git
cd arch-setup
./arch-setup
```

**NOTE:** It is important that you `cd` into the `arch-setup` directory before running the script (as in the instructions above) as it needs access to the other files in the directory and expects the working directory to be there. Running the script from another directory may have unknown consequences.
