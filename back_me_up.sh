#!/bin/bash
# A script to back up user files.

# MIT License - Copyright (c) 2021 Nicolás Castellán <cnicolas.developer@gmail.com>
# SPDX License identifier: MIT
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

DRIVE="Data & BackUps" # Destination drive
KEEP=3                 # Maximum number of backups to keep

##############################################################################

USAGE_MSG() {
	printf "\e[01mThis script creates a backup of your files in a secondary drive
\e[00mOptions:
	\e[01m-m\e[00m) Backup .minecraft folder.
	\e[01m-v\e[00m) Backup virtual machines.
	\e[01m-s\e[00m) Backup ~/.ssh and ~/.safe folders.
	\e[01m-r\e[00m) Replace last backup.
	\e[01m-k\e[00m) Override numbers of backups to keep.
	\e[01m-d\e[00m) Override backup drive.
	\e[01m-h\e[00m) Display a usage message.\n"
}

EXTENDED_MSG() {
	printf "\nDefaults:
	- Backup drive   : \"%s\"
	- Backups to keep: %i
To change the defaults, edit the variables \e[35m\$DRIVE\e[00m and \e[35m\$KEEP\e[00m at
the top of the script.

Examples:
	./$(basename "$0")
	./$(basename "$0") -m -k 4
	./$(basename "$0") -m -r
	./$(basename "$0") -m -v -k 4 -d \"Storage drive\"\n" "$DRIVE" "$KEEP"
}

backup_minecraft=no
backup_vms=no
replace_latest=no
backup_safe_dirs=no

# Process arguments
while [ -n "$1" ]; do
case "$1" in
	-m) backup_minecraft=yes ;;
	-v) backup_vms=yes       ;;
	-r) replace_latest=yes   ;;
	-s) backup_safe_dirs=yes ;;
	-k) KEEP="$2"; shift     ;;
	-d) DRIVE="$2"; shift    ;;
	-h | --help)
	USAGE_MSG >&2
	EXTENDED_MSG >&2
	exit 0
	;;
	*)
	printf "\e[31mUnknown option:\e[00m %s\n" $1 >&2
	USAGE_MSG >&2
	exit 1
	;;
esac; shift; done
unset USAGE_MSG EXTENDED_MSG

# The list of things to back up
LIST+=("Desktop")
LIST+=("Documents")
LIST+=("Development")
LIST+=("Projects")
LIST+=("Templates")
LIST+=("Pictures")
LIST+=("Music")
LIST+=("Videos")
LIST+=("GIMP")
LIST+=(".mydock")
LIST+=(".zshrc")
LIST+=(".zsh_aliases")
LIST+=(".zshrc.d")
LIST+=(".bashrc")
LIST+=(".bash_aliases")
LIST+=(".bashrc.d")
LIST+=(".vimrc")
LIST+=(".gitconfig")
LIST+=(".clang-format")
[ "$backup_minecraft" = "yes" ] && LIST+=(".minecraft")
[ "$backup_vms" = "yes"       ] && LIST+=(".vms" "VirtualBox VMs")
[ "$backup_safe_dirs" = "yes" ] && LIST+=(".safe" ".ssh")

# The pretty animation to display
Animate() {
	CICLE=('|' '/' '-' '\')
	while true; do
		for i in ${CICLE[@]}; do
			printf "$1 %s\r" $i
			sleep 0.2
		done
	done
}

# Testing if the drive is connected.
if [ -d "/run/media/$USER/$DRIVE" ]; then
	destination="/run/media/$USER/$DRIVE"
elif [ -d "/media/$DRIVE" ]; then
	destination="/media/$DRIVE"
else
	printf "\e[31mERROR: \"${DRIVE}\" drive not found.\e[00m\n" >&2
	exit 1
fi

printf "Backing up in \e[36m%s\e[00m\n" "$DRIVE"

# Create global destination folder
destination="$destination/Backings"
mkdir -p "$destination"

# Set the final destination folder name
TODAY=$(date +"%Y-%m-%d-%H-%M")

# Testing if the user is backing up again too soon.
if [ -d "$destination/$TODAY" ]; then
	printf "\e[31mERROR: You have to wait to make another backup.\e[00m\n" >&2
	exit 1
fi

# Remove old backups
let found=$(ls "$destination" | wc -l)

# Remove latest backup (to replace it)
if [ "$replace_latest" = "yes" -a "$found" -gt 0 ]; then
	FOLDERS=($(ls "$destination"))
	rm -r "$destination/${FOLDERS[-1]}"
	unset FOLDERS
fi

# You must always keep at least one backup
[ $KEEP -lt 1 ] && let KEEP=1

if [ $found -ge $KEEP ]; then
	Animate "Removing \e[31mold backups\e[00m" & PID=$!
	let to_delete="found - KEEP + 1"
	for i in $(ls "$destination"); do
		[ $to_delete -gt 0 ] && rm -rf "$destination/$i"
		let to_delete--
	done
	kill $PID; printf "Removing \e[31mold backups\e[00m, \e[32mDone\e[00m\n"
fi

# Create final destination folder
destination="$destination/$TODAY"
mkdir -p "$destination"

# Make the backup
cd $HOME
helper_file="$HOME/.tmp_helper.txt"

IFS="$(echo -en "\n\b")"
for i in ${LIST[@]}; do
	FOUND=no
	if [ -f "$i" ] || ( [ -d "$i" ] && [ -n "$(ls -A "$i")" ] ); then
		FOUND=yes
	fi

	[ "$FOUND" = "no" ] && continue

	case "$i" in
		Development)
		Animate "Copying \e[33m$i\e[00m" & PID=$!
		printf "node_modules\nobj\nout\nbuild\nbin" > "$helper_file"
		rsync -L -r --exclude-from "$helper_file" "$i" "$destination"
		kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" "$i"
		;;

		.minecraft) # Copy only relevant files
		Animate "Copying \e[33m$i\e[00m" & PID=$!
		printf "assets\nlibraries\nlogs\nmods\nversions\nlauncher.jar\nlauncher\nlauncher.pack.lzma\nusercache.json" > "$helper_file"
		rsync -r --exclude-from "$helper_file" "$i" "$destination"
		kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" "$i"
		;;

		*)
		Animate "Copying \e[33m$i\e[00m" & PID=$!
		rsync -L -r "$i" "$destination"
		kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" "$i"
		;;
	esac
done

sync "${destination/\/Backup/}"

notify-send              \
	-t 5000               \
	-a org.gnome.Nautilus \
	-i org.gnome.Nautilus \
	-c transfer.complete  \
	'Backup complete' 'Your files have been backed up to the external disk'
rm "$helper_file"

exit 0
# Thanks for downloading, and enjoy!
