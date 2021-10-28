#!/bin/bash

# MIT License - Copyright (c) 2021 Nicolás Castellán
# SPDX License identifier: MIT
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

# TODO: Keep link up to date.
# Copy the download link from https://www.minecraft.net/en-us/download/server if there's a newer version.
version="1.17.1"
download_link="https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar"

# Exit codes:
# 1   - Java not found
# 2   - Argument not recognized
# 3   - Failed to gain sudo privileges
# 4   - Server already exists
# 5   - No internet
# 10  - Something went wrong while setting up the server
# 130 - Process interrupted

# Get script variables now, use them later.
hide_mc_folder=yes
setup_firewall=no
delete_server=no

cd "`dirname "$0"`"
script_location="$(pwd)"

# We need java for the initial setup of the server
which java &>/dev/null || exit 1

# Process options
while [ -n "$1" ]; do
	case "$1" in
		-d | --delete)   delete_server=yes  ;; # Delete the server
		-v | --visible)  hide_mc_folder=no  ;; # Don't prefix folder with a .
		-f | --firewall) setup_firewall=yes ;; # Set up the firewall (requires sudo)
		-h | --help)                          # Show help menu
		cat <<EOF >&2
This script deploys a minecraft server to your computer. In the process it
also sets up some tools to help you manage it.

Options:
  -d | --delete)   Delete the server.
  -v | --visible)  Don't hide the minecraft folder.
  -f | --firewall) Set up firewall rules using ufw.
  -h | --help)     Show this menu.
EOF
		exit 0
		;;
		*)
		printf "ERROR: Option \e[01m%s\e[00m not recognized\n" "$1" >&2
		exit 2
		;;
esac; shift; done

# Get sudo privileges now if we'll need them
if [ "$setup_firewall" = "yes" ]; then
	sudo echo >/dev/null || exit 3
fi

# Define location of the server's folder and files
if [ "$hide_mc_folder" = "yes" ]; then
	mc_folder="$HOME/.mcserver"
else
	mc_folder="$HOME/mcserver"
fi
appmenu="$HOME/.local/share/applications"
desktop_entry="$appmenu/mcserver.desktop"

#region Deleting the server
if [ "$delete_server" = "yes" ]; then
	read -rp "Are you sure you want to permanently delete the server? (y/N) "
	if [ "$REPLY" = "y" ]; then
		if [ ! -d "$mc_folder" ]; then
			printf "Server was deleted previously\n"
		else
			Animate() {
				CICLE=('|' '/' '-' '\')
				trap return 2
				while true; do
					for i in "${CICLE[@]}"; do
						printf "Deleting server files %s\r" "$i"
						sleep 0.2
					done
				done
			}

			# Delete server files
			Animate & PID=$!
			trap "kill -n 2 $PID ; exit 130" 2
			status=ok
			rm -r "$mc_folder"  || status=bad
			rm "$desktop_entry" || status=bad
			kill -n 2 $PID
			trap - 2

			# Announce status of the removal
			if [ "$status" = "ok" ]; then
				printf "Deleting server files, \e[32mSuccess\e[00m\n"
			else
				printf "Deleting server files, \e[31mFailed\e[00m\n"
			fi

			# Remove firewall rules
			if [ "$setup_firewall" = "yes" ]; then
				RULES=($(sudo ufw status numbered 2>&1 | awk '$NF ~ /MC-SERVER/ {print $2}' | tr -d ']'))
				RULES=($(echo ${RULES[@]} | rev))
				for i in ${RULES[@]}; do
					echo "y" | sudo ufw delete $i &>/dev/null
				done
				unset RULES
			fi
		fi
	fi
	exit 0
fi
#endregion

if [ -d "$mc_folder" ]; then
	printf "\e[31mERROR: Server already exists\e[00m\n" >&2
	exit 4
fi

# Test for an internet connection and exit if none is found.
ping -c 1 google.com &>/dev/null
if [ ! $? -eq 0 ]; then
	printf "\e[31mERROR: No internet\e[00m\n" >&2
	exit 5
fi

# Ask user how much RAM to use (Default= 512M)
RAM='512M'
read -rp "$(printf "How much \e[01mRAM\e[00m do you want the server to use? \e[02m(-Xmx\e[04m   \e[24m)\e[00m\n> ")"
[ -n "$REPLY" ] && RAM="$REPLY"

# Show a fancy animation while the user waits to set things up.
Animate() {
	trap return 2
	CICLE=('|' '/' '-' '\')
	while true; do
		for i in "${CICLE[@]}"; do
			printf "Setting up minecraft server \e[01m%s\e[00m %s\r" $version $i
			sleep 0.2
		done
	done
}

Animate & PID=$!
trap "kill -n 2 $PID &>/dev/null ; exit 130" 2 # Close animation if users hits ^C

status=ok # Set to 'bad' if something goes wrong

# 1. Download server executable
mkdir -p "$mc_folder"
cd "$mc_folder"
wget -q "$download_link" -O "server-${version}.jar" || status=bad

# 2. Copy server icon
if [ -f "$script_location/../assets/mcserver/server-icon.png" ] ; then
	cp "$script_location/../assets/mcserver/server-icon.png" . || status=bad
fi

# 3. Write run script
cat <<EOF > run.sh || status=bad
#!/bin/bash

# The desktop entry file should be in:
# $desktop_entry

# Avoid problems
if [[ \$(ps -aux | grep 'jar server*.jar' | grep -v grep) ]]; then
	printf "\\e[32mERROR: The server is already running\\e[00m\\n"
	exit 1
fi

if [[ \$(ps -aux | grep 'compress.sh' | grep -v grep) ]]; then
	printf "\\e[32mERROR: The server cannot be run while it's being backed up.\\e[00m\\n"
	exit 1
fi

# Process options
SLEEP=no
PERSIST=no
while [ -n "\$1" ]; do
	case "\$1" in
		-s) SLEEP=yes   ;; # Don't skip final timer
		-p) PERSIST=yes ;; # Persist open at the end
		*) printf "ERROR: Option \\e[01m%s\\e[00m not recognized\\n" "\$1" >&2 ; exit 1 ;;
esac; shift; done

# Run the server
cd "\$(dirname "\$0")"
printf "Starting the server...\\n"
printf "\\e[36m%\$(tput cols)s\\e[00m\\n" | tr ' ' '='
java -Xmx$RAM -Xms$RAM -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:G1HeapRegionSize=32M -XX:MaxGCPauseMillis=50 -jar server*.jar --nogui
printf "\\e[36m%\$(tput cols)s\\e[00m\\n" | tr ' ' '='
printf "Server has stopped.\\n"

# Options take effect here
[ "\$SLEEP" = "yes"   ] && sleep 1.5
[ "\$PERSIST" = "yes" ] && read -rp "Press ENTER to exit..."
exit 0
EOF
chmod 744 run.sh

# 4. Write compress script
cat <<EOF > compress.sh || status=bad
#!/bin/bash

FILE_NAME="server_\$(date +"%Y-%m-%d")" # The name of the archive file
LOCATION="${mcfolder%/*}/mcserver-backups" # The location to store the file
MCFOLDER="$mcfolder" # The location of the server folder

if [[ \$(ps aux | grep 'jar server.jar' | grep -v grep) ]]; then
	printf "\e[31mERROR: You can't back up the server while it's running\e[00m\n" >&2
	exit 1
fi

if [ \$# -lt 1 ]; then
	printf "\e[31mERROR: You must use one argument\e[00m\n" >&2
	printf "\e[33mUsage:\e[00m ./%s (-xz | -gz | -zip)\n" `basename "\$0"` >&2
	exit 1
fi

cd "\${MCFOLDER%/*}"
case "\$1" in
	-xz)  COMMAND="tar -Jvcf \$LOCATION/\$FILE_NAME.tar.xz \$(basename \$MCFOLDER)" ;;
	-gz)  COMMAND="tar -zvcf \$LOCATION/\$FILE_NAME.tar.gz \$(basename \$MCFOLDER)" ;;
	-zip) COMMAND="zip -r \$LOCATION/\$FILE_NAME.zip \$(basename \$MCFOLDER)"       ;;
	*) printf "ERROR: Option \e[01m\$1\e[00m not reconognized\n"; exit 1         ;;
esac

# Declare variables used for progress
let TOTAL_FILES=\$(find mcserver -depth | wc -l)
let COUNT=0

# Display progress as the command is running
export XZ_OPT=-9
while read -r i; do
	let COUNT++
	printf "Compressing server: %s\r" \$(echo "scale=2; (\$COUNT/\$TOTAL_FILES)*100" | bc | sed -e 's/\.[0-9]\{,2\}//g' -e 's/^[0-9]\{,3\}/&%/g')
done< <(\$COMMAND)
echo
unset COUNT TOTAL_FILES XZ_OPT

if [[ \$2 == "-p" ]]; then
	read -sp "Press ENTER to exit..."
	echo
fi

exit 0
EOF
chmod 744 compress.sh

# 5. Write desktop entry
mkdir -p "$appmenu"
cat <<EOF > "$desktop_entry" || status=bad
[Desktop Entry]
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
Icon=$mc_folder/server-icon.png
EOF
chmod 644 "$desktop_entry"

# 6. (Optional) Set up firewall
if [ "$setup_firewall" = "yes" ]; then
	sudo ufw allow 25565 comment 'MC-SERVER' &>/dev/null || status=bad
	sudo ufw reload &>/dev/null                          || status=bad
fi

# Run the server for the first time and perform initial settings
java -Xmx"$RAM" -Xms"$RAM" -jar server*.jar --nogui --initSettings &>/dev/null || status=bad

# Stop animation and announce status of the setup
kill -n 2 $PID
trap - 2
if [ "$status" = "ok" ]; then
	printf "Setting up minecraft server \e[01m%s\e[00m, \e[01;32mSuccess\e[00m\n" $version
else
	printf "Setting up minecraft server \e[01m%s\e[00m, \e[01;31mFail\e[00m\n" $version
	exit 10
fi

read -rp "$(printf "Do you agree to the \e[35mEULA\e[00m? \e[02m(https://account.mojang.com/documents/minecraft_eula)\e[00m\n(Y/n) > ")"
[ "$REPLY" == "y" -o -z "$REPLY" ] && sed -i 's/^eula=false/eula=true/' eula.txt

# Configure some "defaults"
sed -i 's/^enable-command-block=false/enable-command-block=true/' server.properties
sed -i "s/^server-ip=/server-ip=$(hostname -I)/" server.properties

ask_setting () {
	read -erp "$(printf "%s (\e[35m%s\e[00m) -> " "$1" "$2")"
	[ -z "$REPLY" ] && REPLY="$2"
	REPLY=$(printf '%q' "$REPLY")
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

# Clear all trailing whitespace in properties file
sed -i 's/\s*$//g' server.properties

printf "\n\e[01;32mCongratulations! \e[00;32mYou now have a minecraft server.\e[00m\n"
exit 0
# Thanks for downloading, and enjoy!
