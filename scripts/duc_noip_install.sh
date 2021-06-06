#!/bin/bash

# MIT License - Copyright (c) 2021 Nicolás Castellán
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

# Check if the DUC is already installed
if which noip2 &>/dev/null; then
	printf "No-IP's DUC is already installed\n" >&2
	exit 1
fi

# Test for an internet connection and exit if none is found.
ping -c 1 google.com &>/dev/null
if [ ! $? -eq 0 ]; then
	printf "\e[31mERROR: No internet\e[00m\n" >&2
	exit 2
fi

# Script needs a terminal to run properly
if [ ! -t 1 ]; then
	printf "ERROR: This script needs to take input from a terminal\n" >&2
	exit 3
fi

USAGE_MSG () {
	printf "This script installs \e[01;36mNo-IP's Dynamic Update client\e[00m.
Options:
	-n) Don't install a menu entry
	-p) Override installation prefix

Examples:
	./%s
	./%s -p /usr -n\n" "$(basename "$0")" "$(basename "$0")"
}

# Process options
integrate_desktop=yes
prefix="$HOME/.local"
while [ -n "$1" ]; do
	case "$1" in
		-n) integrate_desktop=no ;;
		-p) prefix="$2"; shift   ;;
		*) USAGE_MSG >&2; exit 0 ;;
esac; shift; done
unset USAGE_MSG

# Acquire root privileges now
sudo echo >/dev/null || exit 4

# Greet the user
printf "Installing \e[01;36mNo-IP's Dynamic Update Client\e[00m (DUC):
This script may open a text editor to work around an issue when typing your
password, see the README file for more information.\n"

# Download the program
cd /usr/local/src/
sudo wget -q http://www.noip.com/client/linux/noip-duc-linux.tar.gz

# Unpack, install and configure
installed=no
if sudo tar -zxf noip*.tar.gz ; then
	sudo rm noip.tar.gz
	cd noip*/
	gedit </dev/null &>/dev/null &
	sudo make install
	installed=yes
fi

# Integrate with the user's desktop
if [ "$integrate_desktop" = "yes" -a "$installed" = "yes" ]; then
	cd "$HOME"

	# Create relevant directories and files
	target="$prefix/bin"
	entry="$prefix/share/applications"
	icon="$prefix/share/icons/hicolor/256x256/apps"

	mkdir -p $target $entry $icon

	target="$target/noip-assist"
	entry="$entry/noip-assist.desktop"
	icon="$icon/noip-duc.png"

	# Make the "binary" (it's actually a bash script) file
	printf "%s\n" "#!/bin/bash
# Target file to help you manage No-IP\'s DUC

# File created by duc_noip_install.sh script.
# MIT License - Copyright (c) Nicolás Castellán
# THE SOFTWARE IS PROVIDED \"AS IS\"

action=start

USAGE_MSG () {
	printf \"Usage:
	./%s (-k)\\n\"
}

while [ -n \"\$1\" ]; do
	case \"\$1\" in
		-k) action=kill                   ;;
		-h|--help) USAGE_MSG >&2 ; exit 0 ;;
		*)
		printf \"option \\e[01m%s\\e[00m not recognized\\n\" \"\$1\" >&2
		USAGE_MSG >&2
		exit 1
		;;
esac; shift; done

if [ \"\$action\" = \"start\" ]; then
	printf \"root privileges are needed for this operation:\\n\"
	if sudo /usr/local/bin/noip2 ; then
		printf \"Process started\\n\"
		sudo /usr/local/bin/noip2 -S
		OUT=0
	else
		OUT=1
	fi
elif [ \"\$action\" = \"kill\" ]; then
	PID=\$(ps ax | grep noip2 | grep -v grep | awk '{print \$1}' 2>/dev/null)
	if [ -n \"\$PID\" ]; then
		printf \"root privileges are needed for this operation:\\n\"
		if sudo kill -9 \"\$PID\" ; then
			printf \"Process successfully stopped\\n\"
			OUT=0
		fi
	else
		printf \"Process id could not be foud\\nMay not be running\\n\" >&2
		OUT=1
	fi
fi

sleep 2
exit \$OUT\\n" | tee "$target" >/dev/null
	chmod 755 "$target"

	# Download the icon
	wget -q https://www.dropbox.com/s/g55zl9q9uc2a1pw/noiplogo.png?dl=1 -O "$icon"
	chmod 644 "$icon"

	# Make the desktop entry file
	printf "%s\n" "[Desktop Entry]
Name=No-Ip DUC
Comment=Start the dynamic update client.
GenericName=DUC;
Exec=$target
Icon=noip-duc
Type=Application
StartupNotify=false
Terminal=true
Categories=Network;Server;
Actions=open-killing;
Keywords=Network;Minecraft;Server;

X-Desktop-File-Install-Version=0.24

[Desktop Action open-killing]
Name=Open to end process
Exec=$target -k\\n" | tee "$entry" >/dev/null
	chmod 644 "$entry"
fi

printf "\e[01;32mFinished!\e[00m The DUC installation script is done\n"
# Thanks for downloading, and enjoy!
