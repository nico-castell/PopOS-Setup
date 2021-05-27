#!/bin/bash
# Script to install No-Ip's DUC on Linux

# MIT License - Copyright (c) 2021 Nicolás Castellán
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

#region Checks
#===========================================================================
# Checking options internet and installation.

while [ -n "$1" ]; do
	case "$1" in
		-e) ENTRY=true ;;        # Create a start menu entry.
		# -a) AUTOSTART=true ;;  # Use crontab to autostart the DUC at start-up.
		-h)                      # Offer a help message.
			echo "This script installs No-Ip's DUC on your computer."
			echo "The options are:"
			echo "  -e) Create a start menu entry."
			echo "  -h) Show this menu."
			exit
			;;
		*) echo "Option $1 not recognized" && exit 1 ;;
esac; shift; done

# Test for an internet connection and exit if none is found.
ping -c 1 google.com &>/dev/null
if [ ! $? -eq 0 ]; then
	echo -e >&2 "\e[31mERROR: No internet\e[00m"
	exit 1
fi

# Checking if the DUC is already installed.
FINDDUC=$(which noip2)
FINDDUC=${FINDDUC/"/usr/local/bin/"/""}
if [ $FINDDUC = "noip2" ]; then
	echo -e "\e[32mNo-Ip's DUC is already installed\e[00m, exiting..."
	echo "run 'sudo noip2 -S' if it's not already configured"
	exit 0
fi

#===========================================================================
#endregion Checks


#region Installing
#===========================================================================
# Talk to the user and install the program

# Greeting the user.
echo "Installer for No-Ip activated."
echo "This will open a text editor to type your password and copy paste it later."
echo "This is necessary because tiping directly causes some simbols to be wrong."
echo "You should be prompted for your No-Ip password twice."

# Accessing the installation folder and downloading the uncompiled program.
cd /usr/local/src/
echo "Attempting to download the .tar.gz file"

# Testing if wget is installed.
FINDWGET=$(which wget)
FINDWGET=${FINDWGET/"/usr/bin/"/""}

if [ $FINDWGET != "wget" ]; then
	echo -e "\e[31mERROR: You need to install the package 'wget' to download the file\e[00m" >&2
	exit 1
fi

# Actually downloads the file.
sudo wget http://www.noip.com/client/linux/noip-duc-linux.tar.gz

echo "Unpacking the file"
sudo tar -xf noip-duc-linux.tar.gz

# This will open a text editor to type your password, It's necessary because
#   typing to the installer can cause certain symbols to be written incorrectly
#   and cause a "Wrong password" error.
(gedit ) &
cd noip-2*

# Now it'll compile the program from source.
echo "Attempting Installation"

# Now it'll test if make is installed before continuing.
FINDMAKE=$(which make)

if [[ ! $FINDMAKE = *"make"* ]]; then
	echo -e "\e[31mERROR: You need to install the package 'make' to install the DUC.\e[00m" 2>/dev/null
	exit 1
fi

# This will actually install the program.
sudo make install
echo -e "\nCreating configuration file..."
sudo /usr/local/bin/noip2 -C
echo -e "\nRemoving lefover .tar.gz file..."
sudo rm /usr/local/src/noip*.tar.gz

#===========================================================================
#endregion Installing


#region Start menu entry
#===========================================================================
# Offers the user a chance to make a start menu entry.

# This will make it so that you can use the option or be prompted about making the entry.
if [ $ENTRY ]; then

	cd ~
	if [ ! -d ~/.mydock/ ]; then
		mkdir ~/.mydock
	fi

	# Download the logo only if there isn't yet another one.
	mkdir -p ~/.local/share/icons/hicolor/256x256/apps
	cd ~/.local/share/icons/hicolor/256x256/apps
	if [ ! -f ~/.mydock/noiplogo.png ]; then
		echo "Downloading logo..."
		wget -q https://www.dropbox.com/s/g55zl9q9uc2a1pw/noiplogo.png?dl=1 -O noiplogo.png
	fi

	mkdir -p ~/.local/bin
	cd ~/.local/bin
	if [ ! -f noip_duc.sh ]; then
		echo "Making target file..."
		#region File ============================================================
		echo "#!/bin/bash"                                              > noip_duc.sh
		echo "# Script to start the DUC."                               >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "while [ -n \"\$1\" ]; do"                                 >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "    case \"\$1\" in"                                      >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "        # Show PID and wait."                             >> noip_duc.sh
		echo "        -s) SHOW=true ;;"                                 >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "        # Open to kill process."                          >> noip_duc.sh
		echo "        -k) KILL=true ;;"                                 >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "        *) echo \"Option \$1 not recognized\" && exit ;;" >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "    esac"                                                 >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "    shift"                                                >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "done"                                                     >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "# Find Process ID and kill it."                           >> noip_duc.sh
		echo "if [ \$KILL ]; then"                                      >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "    echo \"Please type your sudo password:\""             >> noip_duc.sh
		echo "    sudo /usr/local/bin/noip2 -S"                         >> noip_duc.sh
		echo "    echo"                                                 >> noip_duc.sh
		echo "    read -p \"Input the PID > \""                         >> noip_duc.sh
		echo "    sudo /usr/local/bin/noip2 -K \$REPLY"                 >> noip_duc.sh
		echo "    echo"                                                 >> noip_duc.sh
		echo "    read -p \"Press ENTER to exit.\""                     >> noip_duc.sh
		echo "    exit"                                                 >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "fi"                                                       >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "# Start No-Ip's DUC."                                     >> noip_duc.sh
		echo "echo \"Please type your sudo password:\""                 >> noip_duc.sh
		echo "sudo /usr/local/bin/noip2"                                >> noip_duc.sh
		echo "echo \"DUC Started Succesfully\""                         >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "# Show the PID."                                          >> noip_duc.sh
		echo "if [ \$SHOW ]; then"                                      >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "    echo"                                                 >> noip_duc.sh
		echo "    sudo /usr/local/bin/noip2 -S"                         >> noip_duc.sh
		echo "    echo"                                                 >> noip_duc.sh
		echo "    read -p \"Press ENTER to exit.\""                     >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "fi"                                                       >> noip_duc.sh
		echo                                                            >> noip_duc.sh
		echo "if [ ! \$SHOW ]; then sleep 1.5; fi"                      >> noip_duc.sh
		#endregion File ============================================================
	fi
	chmod +x ./noip_duc.sh

	# This will create the .desktop file.
	cd ~/.local/share/applications
	if [ ! -f noip_duc.desktop ]; then
		echo "Creating noip_duc.desktop file..."
		#region File ============================================================
		echo "[Desktop Entry]"                            > ./noip_duc.desktop
		echo "Name=No-Ip DUC"                             >> ./noip_duc.desktop
		echo "Comment=Start the dynamic update client."   >> ./noip_duc.desktop
		echo "GenericName=DUC;"                           >> ./noip_duc.desktop
		echo "Exec=/home/$USER/.local/bin/noip_duc.sh"    >> ./noip_duc.desktop
		echo "Icon=noiplogo"                              >> ./noip_duc.desktop
		echo "Type=Application"                           >> ./noip_duc.desktop
		echo "StartupNotify=false"                        >> ./noip_duc.desktop
		echo "Terminal=true"                              >> ./noip_duc.desktop
		echo "Categories=Network;Server;"                 >> ./noip_duc.desktop
		echo "Actions=open-showing;open-killing;"         >> ./noip_duc.desktop
		echo "Keywords=Network;Minecraft;Server;"         >> ./noip_duc.desktop
		echo                                              >> ./noip_duc.desktop
		echo "X-Desktop-File-Install-Version=0.24"        >> ./noip_duc.desktop
		echo                                              >> ./noip_duc.desktop
		echo "[Desktop Action open-showing]"              >> ./noip_duc.desktop
		echo "Name=Open showing PID"                      >> ./noip_duc.desktop
		echo "Exec=/home/$USER/.local/bin/noip_duc.sh -s" >> ./noip_duc.desktop
		echo "Icon=noiplogo"                              >> ./noip_duc.desktop
		echo                                              >> ./noip_duc.desktop
		echo "[Desktop Action open-killing]"              >> ./noip_duc.desktop
		echo "Name=Open to end process"                   >> ./noip_duc.desktop
		echo "Exec=/home/$USER/.local/bin/noip_duc.sh -k" >> ./noip_duc.desktop
		echo "Icon=noiplogo"                              >> ./noip_duc.desktop
		#endregion File ============================================================
	fi
	echo "Press 'Alt+F2' and run 'r' if the entry doesn't yet load."
fi

#===========================================================================
#endregion Start menu entry

printf "\e[32mNo-Ip's DUC has been installed!\e[00m\n"
# Thanks for downloading, and enjoy!
