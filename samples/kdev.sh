#!/bin/bash
#  _  __                 _      _                      _      _
# | |/ /___ _ _ _ _  ___| |  __| |_____ __  ___ __ _ _(_)_ __| |_
# | ' </ -_) '_| ' \/ -_) | / _` / -_) V / (_-</ _| '_| | '_ \  _|
# |_|\_\___|_| |_||_\___|_| \__,_\___|\_/  /__/\__|_| |_| .__/\__|
#                                                       |_|

# MIT License - Copyright (c) 2021 Nicolás Castellán <cnicolas.developer@gmail.com>
# SPDX License identifier: MIT
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

# Prepare config file and manage backups
config() {
	# Use specified config file, or find the config in use now, if all fails, return error
	TYPE=$1
	[ -z $TYPE ] && TYPE=$(awk -F\" '$1 ~ /CONFIG_LOCALVERSION=/ {print substr($2,2)}' .config)
	[ -z $TYPE ] && return 1

	# If the config file hasn't yet been created, create it from the original
	if [ ! -f ~/kernel/configs/$TYPE.config ]; then
		cp ~/kernel/configs/original.config ~/kernel/configs/$TYPE.config
	fi

	# Write config file and make nconfig
	cp ~/kernel/configs/$TYPE.config .config
	make nconfig
	printf '' > .scmversion

	# Compare user-edited file with the one which was copied, if they differ, update the .old backup
	# file.
	cmp .config ~/kernel/configs/$TYPE.config &>/dev/null || \
		cp ~/kernel/configs/$TYPE{.config,.config.old}
	cp .config ~/kernel/configs/$TYPE.config

	unset TYPE
}

# Install and remove the kernel using 'kernel-install' but also handle the modules
install() {
	# Find the kernel version to install
	KVER=$1
	DIR=$2
	[ -z $KVER -o -z $DIR ] && return 1

	# Copy modules and install kernel
	sudo cp -r $DIR/lib/modules/$KVER /lib/modules
	sudo kernel-install add $KVER $DIR/boot/vmlinuz-$KVER

	unset KVER DIR
}
remove() {
	# Find the kernel version to remove
	KVER=$1
	[ -z $KVER ] && return 1
	[ $(uname -r) = $KVER ] && return 2 # CHECK TO AVOID REMOVING RUNNING KERNEL

	# Remove the kernel and the moduels
	sudo kernel-install remove $KVER
	sudo rm -r /lib/modules/$KVER

	unset KVER
}

# Check systemdboot efi tree
treefi() {
	sudo tree /efi/{$(cat /etc/machine-id),loader}
}

# Load the kernel tree into cache to accelerate compiling
loadtree() {
	find . -type f 2>/dev/null | xargs cat >/dev/null
}

# Clean everything in the linux kernel tree
clean() {
	LEVEL=$1
	[ -z $LEVEL ] && return 1
	case $1 in
	1)
	# Clean only object files resulting from compilation
	make clean
	;;
	2)
	# Clean object files, config and backup files
	make mrproper
	;;
	3)
	# Clean object files, config, backups, editor backups, patch files and untracked files
	make distclean
	if [ -d .git ]; then
		git reset --hard HEAD
		git clean -xf
	fi
	;;
	4)
	# Clean object files, config, backups, editor backups, patch files, untracked files and ccache
	make distclean
	if [ -d .git ]; then
		git reset --hard HEAD
		git clean -dxf
	fi
	[ -d ~/.cache/ccache ] && rm -r ~/.cache/ccache
	;;
	esac
	unset LEVEL
}

help() {
cat <<EOF >&2
ERROR: Options: $@
not recognized.
EOF
}

case "$1" in
	config)   shift; config $@   ;;
	install)  shift; install $@  ;;
	remove)   shift; remove $@   ;;
	treefi)   shift; treefi $@   ;;
	loadtree) shift; loadtree $@ ;;
	clean)    shift; clean $@    ;;

	*) help $@; exit 1 ;;
esac
