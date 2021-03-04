#!/bin/bash

# MIT License

# Copyright (c) 2021 nico-castell

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Get script variables now, use them later.
delete_server=false
hide_mc_folder=true

cWGET=$(which wget)
cJAVA=$(which java)
if [ -z $cWGET ] || [ -z $cJAVA ]; then
	printf "\e[31mERROR: Make sure you have \e[01mjava\e[00;31m and \e[01mwget\e[00;31m installed before you run this script\e[00m\n" >&2
	exit 1
fi

pushd . >/dev/null
cd "`dirname "$0"`"
script_location="$(pwd)"
cd ~
home_folder="$(pwd)"

#region Options
while [ -n "$1" ]; do
	case "$1" in
		-d | --delete) delete_server=true ;;         # Delete the server
		-mc | --no-hide-mc) hide_mc_folder=false ;;  # Don't hide server folder
		-h | --help)                                 # Brief help menu
			printf "This script deploys a Minecraft Java server and utilities.\nOptions are:\n  -d  | --delete    ) Delete the server\n  -mc | --no-hide-mc) Don't hide server folder\n"
			exit 0
		;;

		*) printf "ERROR: Option \e[01m$1\e[00m not recognized\n" >&2 && exit 1 ;;
esac; shift; done
#endregion Options

# Request root privileges now
sudo echo >/dev/null
if [ ! $? -eq 0 ]; then
	exit 1
fi

# Define script variables here, use them later.
if $hide_mc_folder; then
	mc_folder=("$home_folder/.mcserver")
else
	mc_folder=("$home_folder/mcserver")
fi

appmenu=("$home_folder/.local/share/applications")
mc_entry=("$appmenu/mcserver.desktop")

#region Deleting the server
if $delete_server; then
	printf "Are you sure you want to \e[01mdelete the server \e[31mpermanently\e[00m? (y/N) "
	read
	if [[ ${REPLY,,} == "y" ]]; then
		if [ ! -d "$mc_folder" ]; then
			printf "Server was deleted previously\n";
		else
			# Show an animation while waiting for a process to finish (usage: Animate & pid=$!; kill $pid)
			Animate() {
				CICLE=('|' '/' '-' '\')
				while true; do
					for i in "${CICLE[@]}"; do
						printf "Deleting server files %s\r" $i
						sleep 0.2
					done
				done
			}

			Animate & pid=$!
			# Delete server contents
			code_1=0
			rm -r "$mc_folder"; code_1=$?

			# Delete app menu entries
			code_2=0
			if [ -f "$mc_entry" ]; then
				rm "$mc_entry"; code_2=$?
			fi
			kill $pid

			# Print results
			if [ $code_1 -eq 0 ] && [ $code_2 -eq 0 ]; then
				printf "Deleting server files, \e[32mSuccess\e[00m\n"
			else
				printf "Deleting server files, \e[31mFailed\e[00m\n"
			fi

			# Delete firewall rules (user assisted)
			printf "Choose the rules for port 25565 # MC-SERVER, press ENTER without typing a rule when you're done."
			sudo ufw status numbered
			while [ true ]; do
				read -p "> "
				if [ -z $REPLY ]; then break; fi
				sudo ufw delete $REPLY
			done
		fi
	fi
	exit 0
fi
#endregion

if [ -d "$mc_folder" ]; then
	printf "\e[31mERROR: Server already exists, cannot re-create it\e[00m\n"
	exit 1
fi

# Test for an internet connection and exit if none is found.
ping -c 1 google.com &>/dev/null
if [ ! $? -eq 0 ]; then
	printf "\e[31mERROR: No internet\e[00m\n" >&2
	exit 1
fi

mkdir -p "$mc_folder"
cd "$mc_folder"

# Prompt the user for the ammount of RAM to be used by the server. Default to 1/2 GB
RAM=512M
printf "How much \e[33mRAM\e[00m do you want the server to use? "
read
if [ ! -z $REPLY ]; then
	RAM=$REPLY
fi

# Download server and icon

# TODO: Keep link up to date.
# Copy the download link from https://www.minecraft.net/en-us/download/server if there's a newer version.
version="1.16.5"
download_link="https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar"

Animate() {
	CICLE=('|' '/' '-' '\')
	while true; do
		for i in "${CICLE[@]}"; do
			printf "Setting up minecraft server \e[01m%s\e[00m %s\r" $version $i
			sleep 0.2
		done
	done
}

Animate & pid=$!

# Download server executable
code_1=0
wget -q "$download_link" -O server.jar ; code_1=$?

# Copy server icon
code_2=0
cp "$script_location/assets/mcserver/server-icon.png" . ; code_2=$?

#region run_file =============================================================
run_file="#!/bin/bash

# The desktop entry file should be in:
# $mc_entry

if [[ \$(ps aux | grep 'jar server.jar' | grep -v grep) ]]; then
	printf \"\\e[32mERROR: The server is already running\\e[00m\\n\"
	exit 1
fi

if [[ \$(ps aux | grep 'compress.sh' | grep -v grep) ]]; then
	printf \"\\e[32mERROR: The server cannot while it's being backed up\\e[00m\\n\"
	exit 1
fi

SLEEP=false
PERSIST=false
while [ -n \"\$1\" ]; do
	case \"\$1\" in
		-s) SLEEP=true   ;; # Don't skip final timer
		-p) PERSIST=true ;; # Persist open at the end.
		*) printf \"ERROR: Option\\e[01m\$1\\e[00m not recognized\\n\" >&2 && exit 1 ;;
esac; shift; done

# Draw a line across the width of the console.
Separate () {
	printf \"\\e[36m\"
	printf \"%\`tput cols\`s\\n\" | tr \" \" \"=\"
	printf \"\\e[00m\"
}

cd \"\$(dirname \"\$0\")\"
printf \"Starting the server...\\n\"
Separate
java -Xmx$RAM -Xms$RAM -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:G1HeapRegionSize=32M -XX:MaxGCPauseMillis=50 -jar server*.jar --nogui
Separate
printf \"Server has stopped.\\n\"

# Options take effect here
if \$SLEEP;   then sleep 1.5; fi
if \$PERSIST; then read -p \"Press ENTER to exit...\"; fi
exit 0"
#endregion ===================================================================
code_3=0
printf "%s\n" "$run_file" > run.sh ; code_3=$?
chmod +x run.sh

#region compress_file ========================================================
compress_file="#!/bin/bash

pushd . >/dev/null
cd \"$mc_folder\"

if [[ \$(ps aux | grep 'jar server.jar' | grep -v grep) ]]; then
	printf \"\\e[31mERROR: You can't back up the server while it's running\\e[00m\\n\" >&2
	exit 1
fi

if [[ \$(ps aux | grep 'compress.sh' | grep -v grep) ]]; then
	printf \"\\e[31ERROR: You're already backing up the server\\e[00m\\n\" >&2
	exit 1
fi

if [ \$# -lt 1 ]; then
	printf \"\\e[31mERROR: You must use one argument\\e[00m\\n\" >&2
	printf \"\\e[33mUsage:\\e[00m ./%s (-xz | -gz | -zip)\\n\" \`basename \"\$0\"\` >&2
	exit 1
fi

case \"\$1\" in
	-xz)  ARCHIVE=\"xz\"  ;; # Use tar.xz
	-gz)  ARCHIVE=\"gz\"  ;; # Use tar.gz
	-zip) ARCHIVE=\"zip\" ;; # Use .zip
	*) printf \"ERROR: Option \\e[01m\$1\\e[00m not reconognized\\n\"; exit 1 ;;
esac

Animate() {
	CICLE=('|' '/' '-' '\')
	while true; do
		for i in \"\${CICLE[@]}\"; do
			printf \"Compressing the server (\\e[36m%s\\e[00m) %s\\r\" \$ARCHIVE \$i
			sleep 0.2
		done
	done
}

old_backups=\"\$(ls | grep -e '\\.tar\\...\$' -e '\\.zip\$')\"
if [ -n \"\$old_backups\" ]; then
	printf \"Deleting \\e[31mold\\e[00m backups...\\r\"
	rm \"\$old_backups\"
fi

DATE=\"\$(date +\"%Y-%m-%d\")\"
Animate & pid=\$!

case \$ARCHIVE in
	xz) XZ_OPT=-9 tar -Jcf server_\$DATE.tar.xz * &>/dev/null; O=\$? ;;
	gz) tar -zcf server_\$DATE.tar.gz * &>/dev/null; O=\$? ;;
	zip) zip -rq server_\$DATE.zip * &>/dev/null; O=\$? ;;
esac

kill \$pid
popd >/dev/null

if [ \$O -eq 0 ]; then
	printf \"Compressing the server (\\e[36m%s\\e[00m), \\e[32mSuccess\\e[00m\\n\" \$ARCHIVE
else
	printf \"Compressing the server (\\e[36m%s\\e[00m), \\e[31mFail\\e[00m\\n\" \$ARCHIVE
fi

if [[ \$2 == \"-p\" ]]; then
	read -sp \"Press ENTER to exit...\"
	echo
fi

exit \$O"
#endregion ===================================================================
code_4=0
printf '%s\n' "$compress_file" > compress.sh ; code_4=$?
chmod +x compress.sh

#region desktop_file =========================================================
desktop_file="[Desktop Entry]
Type=Application
Name=MC Server
GenericName=Minecraft;Server;mcserver;
Comment=Start the local minecraft server.
Icon=$mc_folder/server-icon.png
Exec=$mc_folder/run.sh -s
Actions=open-persistent;open-skipping;backup;
Terminal=true
Categories=Minecraft;Game;Server;
Keywords=Server;Minecraft;

[Desktop Action open-persistent]
Name=Open persistent window
Exec=$mc_folder/run.sh -p
Icon=$mc_folder/server-icon.png

[Desktop Action open-skipping]
Name=Open skipping close timer
Exec=$mc_folder/run.sh
Icon=$mc_folder/server-icon.png

[Desktop Action backup]
Name=Archive the server
Exec=$mc_folder/compress.sh -gz -p
Icon=$mc_folder/server-icon.png"
#endregion ===================================================================
code_5=0
mkdir -p "$appmenu"
printf '%s\n' "$desktop_file" > "$mc_entry" ; code_5=$?
chmod -x "$mc_entry"

# Allow Minecraft port through firewall
code_6=0
sudo ufw allow 25565 comment 'MC-SERVER' &>/dev/null ; code_6=$?
sudo ufw reload &>/dev/null

# Run the server and agree to the EULA
java -jar server.jar --nogui --initSettings &>/dev/null
sed -i 's/eula=false/eula=true/' eula.txt

kill $pid

# Announce status of the setup
if [[ $code_1 -eq 0 ]] && [[ $code_2 -eq 0 ]] && [[ $code_3 -eq 0 ]] && \
   [[ $code_4 -eq 0 ]] && [[ $code_5 -eq 0 ]] && [[ $code_6 -eq 0 ]]; then
	printf "Setting up minecraft server \e[01m%s\e[00m, \e[32mSuccess\e[00m\n" $version
else
	printf "Setting up minecraft server \e[01m%s\e[00m, \e[31mFail\e[00m\n" $version
	exit 1
fi

# Configure some "defaults"
sed -i 's/enable-command-block=false/enable-command-block=true/' server.properties
LAN=$(hostname -I)
LAN=${LAN//" "/""}
sed -i "s/server-ip=/server-ip=$LAN/" server.properties

ask_setting () {
	printf "%s (\e[35m%s\e[00m) -> " $1 $2
	read -erp "$1 ($2) "
	if [[ -z $REPLY ]]; then REPLY=("$2"); fi # Default to the specified value.
	REPLY="$(printf '%q' "$REPLY")"
	REPLACE=$(cat server.properties | grep "^$3=")
	sed -i "s/$REPLACE/$3=$REPLY/" server.properties
}

printf "\n"
ask_setting "Do you want the server to run in online mode?"  "true"               "online-mode"
ask_setting "What will be the motd of the world?"            "A Minecraft Server" "motd"
ask_setting "What will be the default gamemode?"             "survival"           "gamemode"
ask_setting "What will be the difficulty of the world?"      "normal"             "difficulty"
ask_setting "What will be the maximum ammount of players?"   "2"                  "max-players"
ask_setting "What will be the view distance?"                "7"                  "view-distance"
ask_setting "What will be the player idle timeout?"          "14"                 "player-idle-timeout"

printf "\n\e[01;32mCongratulations! \e[00;32mYou now have a minecraft server.\e[00m\n"
popd >/dev/null

exit 0
# Thanks for downloading, and enjoy!
