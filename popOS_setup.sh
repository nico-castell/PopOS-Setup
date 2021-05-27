#!/bin/bash

# MIT License - Copyright (c) 2021 Nicolás Castellán
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

# Set up script variables for later
load_tmp_file=no
persist_at_the_end=no
reboot_enabled=yes

USAGE_MSG () {
	printf "Usage: \e[01m./%s (-f)\e[00m
	-f) Load previous choices
	-d) Disable rebooting\n" "$(basename "$0")"
}

# Process options
while [ -n "$1" ]; do
	case "$1" in
		-f) load_tmp_file=yes ;; # Load from temporary file
		-d) reboot_enabled=no ;; # Stop the script from rebooting
		-h | --help)
		USAGE_MSG >&2
		exit 0
		;;
		*)
		printf "Option \"%s\" not recognized.\n" "$1" >&2
		USAGE_MSG >&2
		exit 1
		;;
esac; shift; done

# Head to the script's directory and store it for later
cd "$(dirname "$0")"
script_location="$(pwd)"

# Find relevant folders and files
MISSING() {
	printf "\e[31mMissing directory or file:\e[00m\n%s\n" "$1"
	exit 1
}

autoresume_file="$HOME/.config/autostart/autoresume_popOS_setup.desktop"
choices_file="$script_location/.tmp_choices.txt"
packages_file="$script_location/packages.txt"
scripts_folder="$script_location/scripts"
postinstall_folder="$script_location/post-install.d"
[ -f "$packages_file"      ] || MISSING "$packages_file"
[ -d "$scripts_folder"     ] || MISSING "$scripts_folder"
[ -d "$postinstall_folder" ] || MISSING "$postinstall_folder"

unset USAGE_MSG MISSING

# Prepare module variables
GNOME_APPEARANCE=no
GNOME_SETTINGS=no
GNOME_EXTENSIONS=no
BUILD_MC_SERVER=no
INSTALL_DUC=no
UPDATE_RECOVERY=no

# Function to draw a line across the width of the console.
Separate () {
	if [ ! -z $1 ]; then tput setaf $1; fi
	printf "\n\n%`tput cols`s\n" |tr " " "="
	tput sgr0
}

# Aquire root privileges now
sudo echo >/dev/null || exit 1

printf "Welcome to \e[01mPop!_OS Setup\e[00m version %s!
Follow the instructions and you should be up and running soon
THE SOFTWARE IS PROVIDED \"AS IS\", read the license for more information\n\n" $(git describe --tags --abbrev=0)

# TODO: Remove this warning
for i in {0..1}; do
	printf "\e[01;31mTHIS BRANCH IS UNDER DEVELOPMENT, USE IT AT YOUR OWN RISK\e[00m\n" >&2
done

#region Prompting the user for their choices
if [ "$load_tmp_file" = "no" ]; then
	# We're about to make a new choices file
	[ -f "$choices_file" ] && rm "$choices_file"

	# List of packages to install, then set up
	printf "Confirm packages to install:\n"

	# Go throught a list of packages asking the user to choose which ones to
	# install
	IFSB="$IFS"
	IFS="$(echo -en "\n\b")"
	for i in $(cat "$packages_file"); do
		read -rp "Confirm: `tput setaf 3``printf %s $i | cut -d ' ' -f 1 | tr '_' ' '``tput sgr0` (Y/n) "
		[ "${REPLY,,}" = "y" ] || [ -z $REPLY ] && \
			TO_APT+=("$(printf %s "$i" | cut -d ' ' -f 2-)")
	done
	IFS="$IFSB"
	unset IFSB

	# Append "essential" packages
	TO_APT+=("ufw" "xclip")

	# Store all selected packages
	echo "TO_APT - ${TO_APT[@]}" >> "$choices_file"
	Separate 4

	printf "Choose some extra scripts to run:\n"
	# Check if a script is present before prompting
	prompt_user() {
		unset Confirmed
		if [ -f "$scripts_folder/$1" ]; then
			read -rp "Do you want to $2 (Y/n) "
			if [ "${REPLY[@]}" = "y" ] || [ -z $REPLY ]; then
				Confirmed=yes
			else Confirmed=no; fi
		else Confirmed=no; fi
	}

	# Start prompting the user
	prompt_user "gnome_appearance.sh" "configure the appearance of gnome"
	GNOME_APPEARANCE=$Confirmed
	[ "$GNOME_APPEARANCE" = "yes" ] && Modules+=("GNOME_APPEARANCE")

	prompt_user "gnome_settings.sh" "modify some of gnome's configurations"
	GNOME_SETTINGS=$Confirmed
	[ "$GNOME_SETTINGS" = "yes" ] && Modules+=("GNOME_SETTINGS")

	prompt_user "gnome_extensions.sh" "install some gnome extensions"
	GNOME_EXTENSIONS=$Confirmed
	[ "$GNOME_EXTENSIONS" = "yes" ] && Modules+=("GNOME_EXTENSIONS")

	if [[ ${TO_APT[@]} == *"default-jre" ]]; then
		prompt_user "mc_server_builder.sh" "build a minecraft server"
		BUILD_MC_SERVER=$Confirmed
		[ "$BUILD_MC_SERVER" = "yes" ] && Modules+=("BUILD_MC_SERVER")
	fi

	prompt_user "duc_noip_install.sh" "install No-Ip's DUC"
	INSTALL_DUC=$Confirmed
	[ "$INSTALL_DUC" = "yes" ] && Modules+=("INSTALL_DUC")

	prompt_user "update_recovery.sh" "update the recovery partition"
	UPDATE_RECOVERY=$Confirmed
	[ "$UPDATE_RECOVERY" = "yes" ] && Modules+=("UPDATE_RECOVERY")

	echo "MODULES - ${Modules[@]}" >> "$choices_file"
	unset prompt_user
	Separate 4

	# TODO: NVIDIA DRIVER SUPPORT
fi
#endregion

#region Loading choices from file
if [ "$load_tmp_file" = "yes" ]; then
	# Error if there aren't previous choices
	if [ -f "$choices_file" ]; then
		printf "\e[01mLoading previous choices\e[00m\n"
	else
		printf "\e[31mERROR: No previous choices file.\e[00m\n" >&2
		exit 1
	fi

	# Load apt packages
	TO_APT=$(cat "$choices_file" | grep "TO_APT")
	TO_APT=${TO_APT/"TO_APT - "/""}

	# TODO: NVIDIA DRIVER SUPPORT

	# Load scripts to run
	Modules=$(cat "$choices_file" | grep "MODULES")
	Modules=${Modules/"MODULES - "/""}
	[[ "$Modules" == *"GNOME_APPEARANCE"* ]] && GNOME_APPEARANCE=yes
	[[ "$Modules" == *"GNOME_SETTINGS"*   ]] && GNOME_SETTINGS=yes
	[[ "$Modules" == *"GNOME_EXTENSIONS"* ]] && GNOME_EXTENSIONS=yes
	[[ "$Modules" == *"BUILD_MC_SERVER"*  ]] && BUILD_MC_SERVER=yes
	[[ "$Modules" == *"INSTALL_DUC"*      ]] && INSTALL_DUC=yes
	[[ "$Modules" == *"UPDATE_RECOVERY"*  ]] && UPDATE_RECOVERY=yes

	Separate 4
fi
#endregion

# The script start working now

# Set BIOS time to UTC
sudo timedatectl set-local-rtc 0

# Ensure these hidden folders are present and have the right permissions
# Normal folders
for i in mydock icons themes; do
	[ ! -d ~/.$i ] && [ -d ~/$i ] && mv ~/$i ~/.$i
	[ ! -d ~/.$i ] && mkdir ~/.$i
	chmod 755 ~/.$i
done

# Secret folders
for i in ssh safe; do
	[ ! -d ~/.$i ] && [ -d ~/$i ] && mv ~/$i ~/.$i
	[ ! -d ~/.$i ] && mkdir ~/.$i
	chmod 700 ~/.$i
done

# Back up the following files if present
for i in .bashrc .clang-format .zshrc .vimrc; do
	[ ! -f ~/$i-og ] && [ -f ~/$i ] && cp ~/$i ~/$i-og
	# "-og" stands for original
done

# Create an "empty file" template
[ -f ~/Templates/Empty ] || touch ~/Templates/Empty

# Test for an internet connection and exit if none is found.
ping -c 1 google.com &>/dev/null
if [ ! $? -eq 0 ]; then
	printf "\e[31mERROR: No internet\e[00m\n" >&2
	exit 1
fi

# TODO: Check if updates are available
# TODO: NVIDIA DRIVER SUPPORT

# Stop GNOME's packagekit to avoid problems while the package manager is in use.
sudo systemctl stop packagekit

# Set up extra sources now
sudo apt-get install apt-transport-https -y &>/dev/null

REPOS_ADDED=no
DOTNET_ADDED=no
for i in ${TO_APT[@]}; do
case $i in
	spotify-client)
	REPOS_ADDED=yes
	printf "Preparing \e[01mSpotify\e[00m source...\n"
	curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - &>/dev/null
	printf "deb http://repository.spotify.com stable non-free\n" | sudo tee /etc/apt/sources.list.d/spotify.list &>/dev/null
	;;

	brave-browser)
	REPOS_ADDED=yes
	printf "Preparing \e[01mBrave Browser\e[00m source...\n"
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg &>/dev/null
	printf "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main\n" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list &>/dev/null
	;;

	google-chrome-stable)
	REPOS_ADDED=yes
	printf "Preparing \e[01mGoogle Chrome\e[00m source...\n"
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &>/dev/null
	# Configure apt to prefer this repo to Pop's PPA
	printf "# Prefer Google Chrome from the google repository\n" | sudo tee    /etc/apt/preferences.d/google-chrome-settings >/dev/null
	printf "Package: google-chrome-stable\n"                     | sudo tee -a /etc/apt/preferences.d/google-chrome-settings >/dev/null
	printf "Pin: origin dl.google.com\n"                         | sudo tee -a /etc/apt/preferences.d/google-chrome-settings >/dev/null
	printf "Pin-Priority: 1002\n"                                | sudo tee -a /etc/apt/preferences.d/google-chrome-settings >/dev/null
	;;

	code)
	REPOS_ADDED=yes
	printf "Preparing \e[01mVisual Studio Code\e[00m source...\n"
	wget -qO - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/packages.microsoft.gpg &>/dev/null
	printf "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main\n" | sudo tee /etc/apt/sources.list.d/vscode.list &>/dev/null
	# Configure apt to prefer this repo to Pop's PPA
	printf "# Prefer vscode from the microsoft repo\n" | sudo tee    /etc/apt/preferences.d/vscode-settings >/dev/null
	printf "Package: code\n"                           | sudo tee -a /etc/apt/preferences.d/vscode-settings >/dev/null
	printf "Pin: origin packages.microsoft.com\n"      | sudo tee -a /etc/apt/preferences.d/vscode-settings >/dev/null
	printf "Pin-Priority: 1002\n"                      | sudo tee -a /etc/apt/preferences.d/vscode-settings >/dev/null
	;;

	signal-desktop)
	REPOS_ADDED=yes
	printf "Preparing \e[01mSignal Desktop\e[00m source...\n"
	curl -sS https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add - &>/dev/null
	printf "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main\n" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list &>/dev/null
	;;

	vivaldi)
	REPOS_ADDED=yes
	printf "Preparing \e[01mVivaldi\e[00m source...\n"
	wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add - &>/dev/null
	printf 'deb https://repo.vivaldi.com/archive/deb/ stable main\n' | sudo tee -a /etc/apt/sources.list.d/vivaldi.list &>/dev/null
	;;

	dotnet*)
	REPOS_ADDED=yes
	if [ "$DOTNET_ADDED" = "no" ]; then
		DOTNET_ADDED=yes
		wget -q https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb -O .packages-microsoft-prod.deb &>/dev/null
		sudo dpkg -i .packages-microsoft-prod.deb &>/dev/null
		rm .packages-microsoft-prod.deb &>/dev/null
	fi
	;;
esac
done

[ "$REPOS_ADDED" = "yes" ] && Separate 4
unset REPOS_ADDED DOTNET_ADDED

# Update all repositories.
printf "Updating repositories...\n"
sudo apt update

Separate 4

# Install user-selected packages now:
printf "Installing user-selected packages...\n"
sudo apt install ${TO_APT[@]}

# Source the post-installation scripts for the packages we've installed
if [ $? -eq 0 ]; then
	for i in $(ls "$postinstall_folder" | grep \.sh$); do
		[[ "${TO_APT[@]}" == *"${i/".sh"/""}"* ]] && \
			. "$postinstall_folder/$i"
	done
fi

# Run extra scripts
if [ "$GNOME_APPEARANCE" = "yes" ];then
	Separate 4; printf "Running \e[01mGNOME Appearance\e[00m module...\n"
	"$scripts_folder/gnome_appearance.sh"
fi
if [ "$GNOME_SETTINGS" = "yes"   ];then
	Separate 4; printf "Running \e[01mGNOME Settings\e[00m module...\n"
	"$scripts_folder/gnome_settings.sh"
fi
if [ "$GNOME_EXTENSIONS" = "yes" ];then
	Separate 4; printf "Running \e[01mGNOME Extensions\e[00m module...\n"
	"$scripts_folder/gnome_extensions.sh"
fi
if [ "$BUILD_MC_SERVER" = "yes"  ];then
	Separate 4; printf "Running \e[01mBuild Minecraft Server\e[00m module...\n"
	"$scripts_folder/mc_server_builder.sh"
fi
if [ "$INSTALL_DUC" = "yes"      ];then
	Separate 4; printf "Running \e[01mInstall No-Ip's DUC\e[00m module...\n"
	"$scripts_folder/duc_noip_install.sh" -e
fi
if [ "$UPDATE_RECOVERY" = "yes"  ]; then
	Separate 4; printf "Running \e[01mUpdate Recovery\e[00m module...\n"
	"$scripts_folder/update_recovery.sh"
fi

Separate 4

# Clean up after we're done
[ -f "$autoresume_file" ] && rm "$autoresume_file"
[ -f "$choices_file"    ] && rm "$choices_file"
sudo apt-get --purge autoremove &>/dev/null
sudo apt-get autoclean &>/dev/null

# Restart GNOME's packagekit after we're done with the package manager
sudo systemctl restart packagekit

[ "$persist_at_the_end" = "yes" ] && read -rp "Press any key to finish. " -n 1

printf "\e[01;32mFinished!\e[00m your system has been set up.\n"
exit 0
# Thanks for downloading, and enjoy!
