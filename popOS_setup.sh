#!/bin/bash

# MIT License - Copyright (c) 2021 Nicolás Castellán
# SPDX License identifier: MIT
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

# Set up script variables for later
load_tmp_file=no
run_as_root=no

USAGE_MSG () {
	printf "Usage: \e[01m./%s (-f)\e[00m
	-f) Load previous choices
	-s) Run as root (not recommended)\n" "$(basename "$0")"
}

# Process options
while [ -n "$1" ]; do
	case "$1" in
		-f) load_tmp_file=yes ;; # Load from temporary file
		-s) run_as_root=yes   ;; # Don't stop if run as root
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

# Prepare and test filepaths in variables
autoresume_file="$HOME/.config/autostart/autoresume_popOS_setup.desktop"
choices_file="$script_location/.tmp_choices.txt"

packages_file="$script_location/packages.txt"
flatpaks_file="$script_location/flatpaks.txt"
remove_file="$script_location/remove.txt"

scripts_folder="$script_location/scripts"
postinstall_folder="$script_location/post-install.d"
sources_folder="$script_location/sources.d"

[ -f "$packages_file"      ] || MISSING "$packages_file"
[ -f "$flatpaks_file"      ] || MISSING "$flatpaks_file"
[ -f "$remove_file"        ] || MISSING "$remove_file"
[ -d "$scripts_folder"     ] || MISSING "$scripts_folder"
[ -d "$postinstall_folder" ] || MISSING "$postinstall_folder"
[ -d "$sources_folder"     ] || MISSING "$sources_folder"

unset USAGE_MSG MISSING

# Function to draw a line across the width of the console.
Separate () {
	if [ ! -z $1 ]; then tput setaf $1; fi
	printf "\n\n%`tput cols`s\n" |tr " " "="
	tput sgr0
}

# The script should not be run as root
if [ $(id -u) == 0 -a "$run_as_root" = "no" ]; then
	printf "\e[31mThe script should not be run as root, as some things might break\e[00m
Instead, run it as your user and let the script ask for root privileges
To force the script to run as root, use the -s flag\n" >&2
	exit 1
fi

# Aquire root privileges now
sudo echo >/dev/null || exit 1

# Give the welcome message and license disclaimer
commit="$(git log -1 --format='%h' 2>/dev/null)"
version="$(git describe --tags --abbrev=0 2>/dev/null)"
[ -n "$version" ] && \
	version=" version $version"
[ -z "$version" -a -n "$commit" ] && \
	version=" at commit $commit"

printf "Welcome to \e[36;01mPop!_OS Setup\e[00m%s!
Follow the instructions and you should be up and running soon
THE SOFTWARE IS PROVIDED \"AS IS\", read the license for more information\n\n" "$version"
unset version commit

#region Prompting the user for their choices
if [ "$load_tmp_file" = "no" ]; then
	# We're about to make a new choices file
	[ -f "$choices_file" ] && rm "$choices_file"

	# Configure IFS and umask
	IFSB="$IFS"
	IFS="$(echo -en "\n\b")"
	MASK=$(umask)
	umask 077

	# Use the following file in memory
	MEMFILE=/tmp/$$-line

	# Go through a list of packages asking the user to choose which ones to remove
	printf "Confirm packages to remove:\n"
	for i in $(cat "$remove_file"); do
		echo "$i" > $MEMFILE && chmod u-w $MEMFILE

		read -rp "$(printf "Confirm: \e[31m%s\e[00m (y/N) " "$(cut -d' ' -f1 $MEMFILE | tr '_' ' ')" )"
		[ "${REPLY,,}" == "y" ] && \
			TO_REMOVE+=($(cut -d' ' -f2- $MEMFILE))

		chmod u+w $MEMFILE
	done
	TO_REMOVE=($(echo ${TO_REMOVE[@]} | tr ' ' '\n' | sort -u))
	echo "TO_REMOVE - ${TO_REMOVE[@]}" >> "$choices_file"

	# Go through a list of packages asking the user to choose which ones to install
	printf "Confirm packages to install:\n"
	for i in $(cat "$packages_file"); do
		echo "$i" > $MEMFILE && chmod u-w $MEMFILE

		# Detect category and user choice to skip or not skip
		if [ -n "$(awk '$0 ~ /^\S/' $MEMFILE)" ]; then
			read -rp "$(printf "Do you want to install \e[01;33m%s\e[00m software? (%s) (Y/n) > " "$(awk '{print $1}' $MEMFILE | tr '_' ' ')" "$(cut -d' ' -f2- $MEMFILE)")"
			[ "${REPLY,,}" == 'y' -o -z "$REPLY" ] && SKIP_CATEGORY=no || SKIP_CATEGORY=yes
		fi
		# Process apps in a category
		if [ -n "$(awk '$0 ~ /\t/' $MEMFILE)" -a "$SKIP_CATEGORY" = 'no' ]; then
			read -rp "$(printf "  Confirm: \e[33m%s\e[00m (Y/n) " "$(awk '{print $1}' $MEMFILE | tr '_' ' ')")"
			[ "${REPLY,,}" == 'y' -o -z "$REPLY" ] && \
				TO_DNF+=($(cut -d' ' -f2- $MEMFILE))
		fi

		chmod u+w $MEMFILE
	done
	# Append essential packages, sort, and write
	TO_APT+=(ufw xclip pixz)
	TO_APT=($(echo ${TO_APT[@]} | tr ' ' '\n' | sort -u))
	echo "TO_APT - ${TO_APT[@]}" >> "$choices_file"

	# Go through a list of flatpaks asking the user to choose which ones to install
	printf "Confirm flatpaks to install:\n"
	for i in $(cat "$flatpaks_file"); do
		echo "$i" > $MEMFILE && chmod u-w $MEMFILE

		read -rp "$(printf "Confirm: \e[36m%s\e[00m (Y/n) " "$(cut -d' ' -f1 $MEMFILE | tr '_' ' ')")"
		[ "${REPLY,,}" == "y" -o -z "$REPLY" ] && \
			TO_FLATPAK+=($(cut -d' ' -f2- $MEMFILE))

		chmod u+w $MEMFILE
	done
	TO_FLATPAK=($(echo ${TO_FLATPAK[@]} | tr ' ' '\n' | sort -u))
	echo "TO_FLATPAK - ${TO_FLATPAK[@]}" >> "$choices_file"

	# Remove MEMFILE and return IFS and umask to normal
	rm $MEMFILE
	IFS="$IFSB"
	umask $MASK
	unset IFSB MASK MEMFILE

	# Choose an NVIDIA driver
	CHOSEN_DRIVER=none
	if lspci | grep "NVIDIA" &>/dev/null; then
		DRIVERS+=("system76-driver-nvidia")
		DRIVERS+=("nvidia-driver-470")
		DRIVERS+=("nvidia-driver-440")
		DRIVERS+=("nvidia-driver-390")
		DRIVERS+=("nvidia-driver-360")
		DRIVERS+=("none")
		select i in ${DRIVERS[@]}; do
		case $i in
			none) break ;;
			*)
			if [ $REPLY -lt 0 ] || [ $REPLY -gt ${#DRIVERS[@]} ]; then
				printf "Wrong\n" >&2
				continue
			else CHOSEN_DRIVER="$i"; fi
			;;
		esac
		break
		done
		Separate 4
	fi

	# Store chosen driver
	echo "CHOSEN_DRIVER - $CHOSEN_DRIVER" >> "$choices_file"
	unset DRIVERS

	# Let the user choose extra scripts to run
	printf "Choose some extra scripts to run:\n"
	for i in $(ls "$scripts_folder" | grep \.sh$); do
		read -rp "$(printf "Do you want to run the \e[01m%s\e[00m extra script? (Y/n) " "${i/".sh"/""}")"
		[ "${REPLY,,}" = "y" -o -z "$REPLY" ] && \
			SCRIPTS+=("$i")
	done

	# Store selected scripts
	echo "SCRIPTS - ${SCRIPTS[@]}" >> "$choices_file"
	unset prompt_user
	Separate 4
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

	# Load packages to remove
	TO_REMOVE=$(cat "$choices_file" | grep "TO_REMOVE")
	TO_REMOVE=${TO_REMOVE/"TO_REMOVE - "/""}

	# Load packages to install
	TO_APT=$(cat "$choices_file" | grep "TO_APT")
	TO_APT=${TO_APT/"TO_APT - "/""}

	# Load flatpaks to install
	TO_FLATPAK=$(cat "$choices_file" | grep "TO_FLATPAK")
	TO_FLATPAK=${TO_FLATPAK/"TO_FLATPAK - "/""}

	# Load chosen NVIDIA driver
	CHOSEN_DRIVER=$(cat "$choices_file" | grep "CHOSEN_DRIVER")
	CHOSEN_DRIVER=${CHOSEN_DRIVER/"CHOSEN_DRIVER - "/""}

	# Load scripts to run
	SCRIPTS=$(cat "$choices_file" | grep "SCRIPTS")
	SCRIPTS=${SCRIPTS/"SCRIPTS - "/""}

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

# Stop GNOME's packagekit to avoid problems while the package manager is in use.
sudo systemctl stop packagekit

# Install this package to make apt support https
sudo apt-get install apt-transport-https -y &>/dev/null

# Source all the files containing extra sources now
for i in $(ls "$sources_folder" | grep \.sh$); do
	[[ "${TO_APT[@]}" == *"${i/".sh"/""}"* ]] && \
		source "$sources_folder/$i"
done

[[ "${REPOS_CONFIGURED[@]}" ]] && Separate 4
unset REPOS_CONFIGURED URL KEY

# Update all repositories.
printf "Updating repositories...\n"
sudo apt update

# Remove user-selected packages:
if [ -n "$TO_REMOVE" ]; then
	Separate 4
	printf "Removing user-selected packages...\n"
	sudo apt --purge remove ${TO_REMOVE[@]}
	Separate 4
fi

# Install the NVIDIA driver
if [ "$CHOSEN_DRIVER" != "none" ]; then
	Separate 4
	printf "Installing the NVIDIA driver: \e[01m%s\e[00m\n" $CHOSEN_DRIVER
	sudo apt install $CHOSEN_DRIVER
	Separate 4
fi

# Upgrade packages
let UPGRADABLE=$(apt list --upgradable 2>/dev/null | wc -l)
let UPGRADABLE--
if [ $UPGRADABLE -gt 0 ]; then
	printf "%i packages can be upgraded\n" $UPGRADABLE
	read -rp "Do you want to upgrade them now? (Y/n) "
	if [ "${REPLY,,}" = "y" ] || [ -z $REPLY ]; then
		sudo apt upgrade -y
	fi
fi
unset UPGRADABLE

Separate 4

# Install user-selected packages:
printf "Installing user-selected packages...\n"
sudo apt install ${TO_APT[@]}

# Install user-selected flatpaks:
if [ -n "$TO_FLATPAK" ]; then
	Separate 4
	flatpak --user remote-delete flathub &>/dev/null
	flatpak --system remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo &>/dev/null
	printf "Installing user-selected flatpaks...\n"
	printf "Which type of installation do you want to do?\n"
	select i in "system" "user"; do
	case $i in
		system) flatpak --system install ${TO_FLATPAK[@]}    ;;
		user)   flatpak --user   install ${TO_FLATPAK[@]}    ;;
		*) printf "You must choose a valid option"; continue ;;
	esac; break; done
	Separate 4
fi

# Source the post-installation scripts for the packages we've installed
if [ $? -eq 0 ]; then
	for i in $(ls "$postinstall_folder" | grep \.sh$); do
		[[ "${TO_APT[@]}" == *"${i/".sh"/""}"* ]] && \
			source "$postinstall_folder/$i"
	done
fi

# Run extra scripts
for i in ${SCRIPTS[@]}; do
	Separate 4
	printf "Running \e[01m%s\e[00m extra script...\n" "${i/".sh"/""}"
	"$scripts_folder/$i"
done

Separate 4

# Clean up after we're done
printf "Cleaning up...\n"
[ -f "$autoresume_file" ] && rm "$autoresume_file"
[ -f "$choices_file"    ] && rm "$choices_file"
sudo apt-get autoremove -y &>/dev/null
sudo apt-get autoclean -y &>/dev/null

# Restart GNOME's packagekit after we're done with the package manager
sudo systemctl restart packagekit

printf "\e[01;32mFinished!\e[00m your system has been set up.\n"
exit 0
# Thanks for downloading, and enjoy!
