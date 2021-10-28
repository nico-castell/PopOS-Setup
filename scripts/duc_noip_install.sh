#!/bin/bash

# MIT License - Copyright (c) 2021 Nicolás Castellán
# SPDX License identifier: MIT
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

# Exit codes:
# 1  - The Dynamic Update Client is already installed.
# 2  - No internet
# 3  - The standard input was redirected
# 4  - Failed to get root privileges
# 10 - Something went wrong during the installation

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
	-s) Set it up as a systemd service (also selects -n)

Examples:
	./%s
	./%s -p /usr -n\n" "$(basename "$0")" "$(basename "$0")"
}

# Prepare variables
integrate_desktop=yes
systemd_setup=no
logfile="/usr/local/src/duc-noip-install-log.txt"
prefix="$HOME/.local"
[ $(id -u) == 0 ] && prefix="/usr/local"

# Process options
while [ -n "$1" ]; do
	case "$1" in
		-n) integrate_desktop=no ;;
		-p) prefix="$2"; shift   ;;
		-s) systemd_setup=yes    ;;
		*) USAGE_MSG >&2; exit 0 ;;
esac; shift; done
unset USAGE_MSG

# Don't integrate with the desktop when setting up the DUC as a systemd service. Why? Because noip2
# has different behaviour when running as a systemd daemon (service) and when running as its own
# process, and if both are running, they may interfere with each other.
[ "$systemd_setup" = "yes" ] && integrate_desktop=no

# Acquire root privileges now
sudo echo >/dev/null || exit 4

sudo printf "User choices when installing:
  - Integrating desktop: %s
  - Setting up as systemd service: %s
  - Installation prefix: %s
" "$integrate_desktop" "$systemd_setup" "$prefix" > "$logfile"

# Greet the user
printf "Installing \e[01;36mNo-IP's Dynamic Update Client\e[00m (DUC):
This script may open a text editor to work around an issue when typing your
password, see the README file for more information.\n"

# Download and install the program
status=ok
cd /usr/local/src/
sudo wget -q http://www.noip.com/client/linux/noip-duc-linux.tar.gz || status=bad

# Unpack, install and configure
if [ "$status" = "ok" ] && sudo tar -zxf noip*.tar.gz ; then
	sudo rm noip*.tar.gz
	cd noip*/
	gedit </dev/null &>/dev/null &
	sudo make install || status=bad
else
	status=bad
fi

sudo printf "status after running makefile = %s\n" "$status" > "$logfile"

installation_result=$status

# Integrate in systemd using service and timer
if [ "$systemd_setup" = "yes" -a "$installation_result" = "ok" ]; then
	systemd_dir="/etc/systemd/system"
	systemd_service="$systemd_dir/duc-noip-local.service"
	systemd_timer="$systemd_dir/duc-noip-local.timer"

	# Ensure the directory is present and write config files
	sudo mkdir -p "$systemd_dir"
	# Write service file
	sudo cat <<EOF > "$systemd_service" || status=bad
[Unit]
Description=No-IP's Dynamic Update Client
Requires=NetworkManager.service
After=NetworkManager-wait-online.service
Wants=duc-noip-local.timer

[Service]
Type=oneshot
ExecStart=noip2

[Install]
WantedBy=multi-user.target
EOF
	# Write timer file
	sudo cat <<EOF > "$systemd_timer" || status=bad
[Unit]
Description=No-IP's Dynamic Update Client's timer
Requires=NetworkManager.service
After=NetworkManager-wait-online.service

[Timer]
Unit=duc-noip-local.service
OnCalendar=*-*-* *:00,30:00
OnBootSec=10s

[Install]
WantedBy=timers.target
EOF

	sudo printf "systemd files written:
  - %s
  - %s
" "$systemd_service" "$systemd_timer" > "$logfile"

	# Reload daemons and enable the timer to run the service
	sudo systemctl daemon-reload
	sudo systemctl enable --now duc-noip-local.timer

	unset systemd_dir systemd_service systemd_timer
fi

# Integrate with the user's desktop
if [ "$integrate_desktop" = "yes" -a "$installation_result" = "ok" ]; then
	# Create relevant directories and files
	target="$prefix/bin"
	entry="$prefix/share/applications"
	icon="$prefix/share/icons/hicolor/256x256/apps"

	mkdir -p $target $entry $icon

	target="$target/noip-assist"
	entry="$entry/noip-assist.desktop"
	icon="$icon/noip-duc.png"

	# Make the "binary" (it's actually a bash script) file
	cat <<EOF > "$target" || status=bad
#!/bin/bash
# Target file to help you manage No-IP\'s DUC

# File created by duc_noip_install.sh script.
# MIT License - Copyright (c) Nicolás Castellán
# THE SOFTWARE IS PROVIDED \"AS IS\"

action=start

USAGE_MSG () {
	printf "Usage:
	./%s (-k)\n"
}

# Acquire root privileges now
sudo echo >/dev/null || exit 1

while [ -n "\$1" ]; do
	case "\$1" in
		-k) action=kill                   ;;
		-h|--help) USAGE_MSG >&2 ; exit 0 ;;
		*)
		printf "option \e[01m%s\e[00m not recognized\n" "\$1" >&2
		USAGE_MSG >&2
		exit 1
		;;
esac; shift; done

if [ "\$action" = "start" ]; then
	if sudo noip2 ; then
		printf "Process started\n"
		sudo noip2 -S
		OUT=0
	else
		OUT=1
	fi
elif [ "\$action" = "kill" ]; then
	PID=\$(ps ax | grep noip2 | grep -v grep | awk '{print \$1}' 2>/dev/null)
	if [ -n "\$PID" ]; then
		if sudo kill -9 "\$PID" ; then
			printf "Process successfully stopped\n"
			OUT=0
		fi
	else
		printf "Process id could not be foud\nMay not be running\n" >&2
		OUT=1
	fi
fi

sleep 2
exit \$OUT
EOF
	chmod 755 "$target"

	# Download the icon
	wget -q https://www.dropbox.com/s/g55zl9q9uc2a1pw/noiplogo.png?dl=1 -O "$icon" || status=bad
	chmod 644 "$icon"

	# Make the desktop entry file
	cat <<EOF > "$entry" || status=bad
[Desktop Entry]
Name=No-Ip DUC
Comment=Start the dynamic update client.
GenericName=DUC;
Exec=noip-assist
Icon=noip-duc
Type=Application
StartupNotify=false
Terminal=true
Categories=Network;Server;
Actions=open-killing;
Keywords=Network;Minecraft;Server;

[Desktop Action open-killing]
Name=Open to end process
Exec=noip-assist -k
EOF
	chmod 644 "$entry"

	sudo printf "Files written to integrate with the desktop:
- %s
- %s
- %s
" "$target" "$entry" "$icon" > "$logfile"
fi

sudo printf "Final status after installation: %s\n" "$status" > "$logfile"
sudo printf "If you want to remove noip's DUC, you should delete the previously listed files, and:
  - /usr/local/bin/noip2       (executable binary)
  - /usr/local/etc/no-ip2.conf (config file)
  - This list may not be complete, so the system admin might have to check for leftovers
" > "$logfile"

if [ "$status" = "ok" ]; then
	printf "\e[01;32mSuccess!\e[00m The script ran successfully, and the DUC is installed"
	exit 0
else
	printf "\e[01;31mFailed!\e[00m The script finished, but something went wrong in the process"
	exit 10
fi
# Thanks for downloading, and enjoy!
