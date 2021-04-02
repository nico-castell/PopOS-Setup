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

while [ -n "$1" ]; do
	case "$1" in
		--from-temp-file) load_tmp_file=true ;;  # Load from temporary file
		--disable-reboot) disable_reboot=true ;; # Stop the script from rebooting
		--help)                                  # Show help menu.
		echo "This script sets up a Pop!_OS installation as best as possible."
		echo "Options are:"
		echo "  --from-temp-file) Loads previous choices."
		echo "  --disable-reboot) Stops the script from rebooting the computer."
		exit
		;;
		-p) persist_at_the_end=true ;;           # Don't exit at the end of the script.
		*) echo "ERROR: Option $1 not recognized" && exit 1 ;;
esac; shift; done

# Head to the script's directory and store it for later
pushd . >/dev/null
cd "$(dirname "$0")"
script_location="$(pwd)"
choices_file=("$script_location/.tmp_choices")

# Draw a line accross the width of the console
Separate () {
	if [ ! -z $1 ]; then tput setaf $1; fi
	printf "\n\n%`tput cols`s\n" |tr " " "="
	tput sgr0
}


#region Asking user about programs to install
if [ -z $load_tmp_file ]; then

	# Go through a list asking the user to confirm each element.
	Confirm_from_list () {
		unset Confimed
		for i in ${To_Confirm[@]}; do
			read -p "Confirm \e[33m\"$i\"\e[00m (Y/n) " -t 10
			O=$?

			# User presses ENTER --> YES
			# Times out          --> NO
			if [ $O -eq 0 ] && [ -z $REPLY ]; then REPLY=("y"); fi
			if [ $O -gt 128 ]; then echo; REPLY=("n"); fi

			# Append confirmed items to the list.
			if [[ ${REPLY,,} == "y" ]]; then
				Confimed+=("$i")
			fi
		done
	}

	# Remove previous choices file, we're about to make a new one.
	if [ -f "$choices_file" ]; then rm "$choices_file"; fi

	echo "Confirm packages to remove:"
	To_Confirm=("geary" "libreoffice*")
	Confirm_from_list
	TO_REMOVE=(${Confimed[@]})
	echo "TO_REMOVE- ${TO_REMOVE[@]}" >> "$choices_file"
	Separate 4

	echo "Confirm packages to install:"
	 To_Confirm=("audacity" "code" "zsh" "dconf-editor" "gimp" "inkscape" "gnome-tweaks" "brave-browser" "google-chrome-stable")
	To_Confirm+=("vivaldi" "lm-sensors" "hddtemp" "os-prober" "p7zip-full" "thunderbird" "vlc" "default-jre" "discord" "gparted")
	To_Confirm+=("genisoimage" "spotify-client" "glade" "htop" "tree" "obs-studio" "pavucontrol" "virtualbox" "gnome-chess")
	To_Confirm+=("signal-desktop" "gnome-mines" "steam" "cmatrix")
	Confirm_from_list
	TO_APT=(${Confimed[@]})
	# Append essential packages that should always be installed.
	TO_APT+=("build-essential" "gnome-shell-extensions" "neofetch" "ubuntu-restricted-extras" "xclip" "vim" "gawk")
	if [[ "${TO_APT[@]}" == *"zsh"* ]]; then
		TO_APT+=("zsh-syntax-highlighting" "zsh-autosuggestions" "fonts-powerline" "python3-pip")
	fi
	echo "TO_APT- ${TO_APT[@]}" >> "$choices_file"
	Separate 4

	echo "Confirm flatpaks to install:"
	To_Confirm=("com.dropbox.Client" "com.Spotify.Client" "org.kde.kdenlive" "com.axosoft.GitKraken")
	Confirm_from_list
	TO_FLATPAK=(${Confimed[@]})
	echo "TO_FLATPAK- ${TO_FLATPAK[@]}" >> "$choices_file"
	Separate 4

	Choose_driver () {
	select c in $@ none; do
		case $c in
			none)
			break
			;;
			*)
			if [ 1 -le $REPLY ] && [ $REPLY -le $# ] 2>/dev/null; then
				NVIDIA_DRIVER=$c
			else echo "Wrong"; continue; fi
			;;
		esac
		break
	done
	}
	echo "Choose an NVIDIA driver:"
	Choose_driver system76-driver-nvidia nvidia-driver-360 nvidia-driver-390 nvidia-driver-455
	echo "NVIDIA_DRIVER- $NVIDIA_DRIVER" >> "$choices_file"
	Separate 4

	read -p "Do you want to update the recovery partition? (y/N) "
	if [[ ${REPLY,,} == "y" ]]; then
		UPDATE_RECOVERY=true
		echo "UPDATE_RECOVERY" >> "$choices_file"
	else UPDATE_RECOVERY=false; fi

	# Ask the user for confirmation to run a script, if said script is present.
	prompt_user () {
		unset Confirmed
		if [ -f "$script_location/$1" ]; then
			read -p "Do you want to $2 (Y/n) "
			if [[ ${REPLY,,} == "y" ]] || [[ -z $REPLY ]]; then
				Confimed=true
			else Confimed=false; fi
		else Confirmed=false; fi
	}

	prompt_user "duc_noip_install.sh" "install No-Ip's DUC"
	INSTALL_DUC=("$Confimed")
	if [ "$INSTALL_DUC" = true ]; then
		echo "INSTALL_DUC" >> "$choices_file"
	fi

	if [[ ${TO_APT[@]} == *"default-jre"* ]]; then
		prompt_user "mc_server_builder.sh" "build a minecraft server"
		BUILD_MC_SERVER=("$Confimed")
		if [ "$BUILD_MC_SERVER" = true ]; then
			echo "BUILD_MC_SERVER" >> "$choices_file"
		fi
	fi
	Separate 4
fi
#endregion


#region Loading choices from temporary file.
if [ "$load_tmp_file" = true ]; then
	# Error if there aren't previous choices.
	if [ ! -f "$choices_file" ]; then
		echo -e -e "\e[31mERROR: Previous choices are not available.\e[00m" >&2
		exit 1
	else
		echo -e "\e[33mLoading previous choices...\e[00m"
	fi

	# Load lists into their variables.
	Load_choices () {
		Load=$(cat "$choices_file" | grep "$1")
		Load=${Load/"$1"/""}
	}

	Load_choices "TO_REMOVE- "
	TO_REMOVE=${Load[@]}

	Load_choices "TO_APT- "
	TO_APT=${Load[@]}

	Load_choices "TO_FLATPAK- "
	TO_FLATPAK=${Load[@]}

	Load_choices "NVIDIA_DRIVER- "
	NVIDIA_DRIVER=${Load[@]}

	unset Load

	# Load true/false choices.
	Check_choices () {
		if [ ! -z $(cat "$choices_file" | grep "$1") ]; then
			Check=true
		else Check=false; fi
	}

	Check_choices UPDATE_RECOVERY
	UPDATE_RECOVERY=($Check)

	Check_choices BUILD_MC_SERVER
	BUILD_MC_SERVER=($Check)

	Check_choices INSTALL_DUC
	INSTALL_DUC=($Check)

fi
#endregion


# Execution begins here.

#region Preparing the environment.
# Ensure this folder is present.
if [ ! -d ~/.mydock ] && [ -d ~/mydock ]; then mv ~/mydock ~/.mydock; fi
if [ ! -d ~/.mydock ]; then mkdir ~/.mydock; fi

# Ensure the firewall is on.
echo "Checking firewall..."
FIREWALL=$(sudo ufw status | grep "Status: ")
FIREWALL=${FIREWALL/"Status: "/""}
if [[ $FIREWALL = "inactive" ]]; then
	echo "Enabling firewall..."
	sudo ufw enable
fi

# Make the alias for the backup script.
Make_backup_alias () {

	if [ -f "$script_location/back_me_up.sh" ] && [ -z "$(cat $1 | grep "alias backup")" ]; then
		echo >> $1
		echo "alias backup=\"$script_location/back_me_up.sh\"" >> $1
	fi
}
echo "Making an alias for the backup script..."
Make_backup_alias ~/.bashrc

Separate 4

# Test for an internet connection and exit if none is found.
ping -c 1 google.com &>/dev/null
if [ ! $? -eq 0 ]; then
	echo -e >&2 "\e[31mERROR: No internet\e[00m"
	exit 1
fi

#endregion


#region Functions

# Show an animation while waiting for a process to finish.
Animate() {
	CICLE=('|' '/' '-' '\')
	while true; do
		for i in "${CICLE[@]}"; do
			printf "%s\r" $i
			sleep 0.2
		done
	done
}

# Use the package manager to clean up.
Clean_up () {
	echo; echo "Cleaning..."
	sudo apt-get autopurge -y -qq
	sudo apt-get autoclean -y -qq
}

# Make the system reboot and the script resume after login.
Custom_reboot_resume () {
	###########################################################################
	#     WARNING: check for $disable_reboot BEFORE running this function.    #
	###########################################################################

	# Ensure directory is ready.
	mkdir -p ~/.config/autostart

	#region .desktop to autorun this script.
	printf "[Desktop Entry]\n"                                           > ~/.config/autostart/continue_pop_OS_start.desktop
	printf "Name=TMP Continue pop_OS_start\n"                            >> ~/.config/autostart/continue_pop_OS_start.desktop
	printf "Exec=$script_location/pop_OS_start.sh --from-temp-file -p\n" >> ~/.config/autostart/continue_pop_OS_start.desktop
	printf "Type=Application\n"                                          >> ~/.config/autostart/continue_pop_OS_start.desktop
	printf "StartUpNotify=true\n"                                        >> ~/.config/autostart/continue_pop_OS_start.desktop
	printf "Terminal=true\n"                                             >> ~/.config/autostart/continue_pop_OS_start.desktop
	printf "X-Desktop-File-Install-Version=0.24\n"                       >> ~/.config/autostart/continue_pop_OS_start.desktop
	#endregion

	# Give the user an opportunity to cancel the reboot.
	echo -e "\e[39mRebooting computer in 15 seconds." >&2
	echo -e "Press ENTER to reboot now." >&2
	read -p "Press 'C' to cancel `tput sgr0`" -t 15 -n 1
	O=$?

	if [[ ! -z $REPLY ]]; then
		echo
		return 1 # This return code means the user canceled the reboot
	fi
	if [ $O -gt 128 ]; then echo; fi

	sudo reboot
	exit 2
}

# Test for $DO_REBOOT before rebooting.
Instruct_system_reboot () {
	if [ "$DO_REBOOT" = true ]; then
		Custom_reboot_resume
		# Draw a line if user canceled.
		if [ $? -eq 1 ]; then
			Separate 4
		fi
	fi
}
#endregion


#region Installing updates and NVIDIA Driver
echo "Removing software..."
Animate & PID=$!
sudo apt-get purge ${TO_REMOVE[@]} -y >/dev/null
kill $PID; echo "Done"
echo

echo "Updating repositories..."
Animate & PID=$!
sudo apt-get update >/dev/null
kill $PID; echo "Done"
Separate 4

# Simulate and upgrade using dist-upgrade, if the pattern "linux" is found,
#   assume kernel is being updated and test if rebooting was not disabled,
#   then instruct the script to reboot after upgrading.
UPGRADE_SIM=$(apt-get -s dist-upgrade | grep -e "linux" -e "kernel")
if [ ! -z "$UPGRADE_SIM" ] && [ ! $disable_reboot = true ]; then
	DO_REBOOT=true
	echo -e "\e[39mThe system will reboot after upgrading the kernel...\e[00m"
fi

echo "Upgrading software to the latest version..."
sudo apt-mark hold firefox* >/dev/null
sudo apt dist-upgrade -y
sudo apt-mark unhold firefox* >/dev/null
Clean_up
Separate 4

Instruct_system_reboot
unset TO_REMOVE UPGRADE_SIM DO_REBOOT

if [ ! -z $NVIDIA_DRIVER ]; then
	if [[ ! $NVIDIA_DRIVER == *"system76-driver-nvidia"* ]] && [ ! "$disable_reboot" = true ]; then
		DO_REBOOT=true
		echo "The system will reboot after installing the nvidia driver..."
	fi

	echo -e "Installing NVIDIA driver \e[33m\"$NVIDIA_DRIVER\"\e[00m..."
	sudo apt install $NVIDIA_DRIVER -y

	REPLACE=$(cat "$choices_file" | grep "^NVIDIA_DRIVER- ")
	sed -i "s/$REPLACE/ALREADY_INSTALLED_DRIVER/" "$choices_file"

	Clean_up
	Separate 4

	Instruct_system_reboot
	unset DO_REBOOT REPLACE
fi
unset NVIDIA_DRIVER
#endregion

#region Installing programs

# Notes about some packages:
# * Teamviewer can only be downloaded from the website.
# * Dropbox is not found using apt, you have to download it, and the installer
#     sets up their repo.
# * Zoom is available as a flatpak, but it very bad. It's recommended to
#     download the .deb package.

# Stop gnome package kit, it holds the update process and causes most apt-get
#   updates to fail.
sudo systemctl stop packagekit

# Prepare 'https://' repositories
sudo apt-get install apt-transport-https -y &>/dev/null

# Prepare proprietary repositories.
for i in ${TO_APT[@]}; do
	case $i in
		spotify-client)
		echo "Preparing Spotify repository..."
		curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - &>/dev/null
		echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list &>/dev/null
		;;

		brave-browser)
		echo "Preparing Brave Browser repository..."
		sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg &>/dev/null
		echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list &>/dev/null
		;;

		google-chrome-stable)
		echo "Preparing Google Chrome repository..."
		wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &>/dev/null
		echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list &>/dev/null
		# Configure apt preference to update google-chrome from google's repo instead of Pop!_OS' PPA
		printf '# Prefer Google Chrome from the google repository\n' | sudo tee /etc/apt/preferences.d/google-chrome-settings >/dev/null
		printf 'Package: google-chrome-stable\n'                     | sudo tee -a /etc/apt/preferences.d/google-chrome-settings >/dev/null
		printf 'Pin: origin dl.google.com\n'                         | sudo tee -a /etc/apt/preferences.d/google-chrome-settings >/dev/null
		printf 'Pin-Priority: 1002\n'                                | sudo tee -a /etc/apt/preferences.d/google-chrome-settings >/dev/null
		;;

		code)
		echo "Preparing Visual Studio Code repository..."
		wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/packages.microsoft.gpg add - &>/dev/null
		echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list &>/dev/null
		# Configure apt preference to update vscode from microsoft's repo instead of Pop!_OS' PPA
		printf '# Prefer vscode from the microsoft repo\n' | sudo tee /etc/apt/preferences.d/vscode-settings >/dev/null
		printf 'Package: code\n'                           | sudo tee -a /etc/apt/preferences.d/vscode-settings >/dev/null
		printf 'Pin: origin packages.microsoft.com\n'      | sudo tee -a /etc/apt/preferences.d/vscode-settings >/dev/null
		printf 'Pin-Priority: 1002\n'                      | sudo tee -a /etc/apt/preferences.d/vscode-settings >/dev/null
		;;

		signal-desktop)
		echo "Preparing Signal Desktop repository..."
		curl -sS https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add - &>/dev/null
		echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list &>/dev/null
		;;

		vivaldi)
		echo "Preparing Vivaldi repository..."
		wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add - &>/dev/null
		echo 'deb https://repo.vivaldi.com/archive/deb/ stable main' | sudo tee -a /etc/apt/sources.list.d/vivaldi.list &>/dev/null
		;;
	esac
done

# Update all repositories.
echo "Updating repositories..."
Animate & PID=$!
sudo apt-get update >/dev/null
kill $PID; echo "Done"
Separate 4

echo "Installing packages..."
sudo apt install ${TO_APT[@]} -y

# Do post-installation instructions if the installation was successful.
if [ $? -eq 0 ]; then
for i in ${TO_APT[@]}; do
	case $i in
		# If the user chooses one of these web browsers, assume Firefox won't
		#   be used and unistall it.
		google-chrome-stable | brave-browser | vivaldi)
		if [ ! "$ALREADY_REMOVED_FIREFOX" ]; then
			ALREADY_REMOVED_FIREFOX=true
			Separate 4
			echo -e "\"\e[36m$i\e[00m\" was installed, removing \e[33mFirefox\e[00m..."
			Animate & PID=$!
			sudo apt-get purge firefox* -y &>/dev/null
			rm -rf ~/.mozilla
			Clean_up &>/dev/null
			kill $PID
		fi
		;;

		# Offer to prepare some common developer tools.
		code)
		Separate 4
		echo -e "\e[36mVisual Studio Code\e[00m was successfully installed,"
		echo "Choose some developer tools to prepare:"

		LIST+=("Git")
		LIST+=("GPG - User assisted")
		LIST+=("C++ Tools")
		LIST+=(".NET Core 3.1")
		LIST+=("Java JDK")
		LIST+=("SSH")
		LIST+=("VS Code Extension development")

		select c in "${LIST[@]}" exit; do
		case $c in
			Git)
			echo "Adding git ppa repository..."
			Animate & PID=$!
			sudo apt-add-repository -y ppa:git-core/ppa >/dev/null
			O=$?; kill $PID
			if [ $O -eq 0 ]; then
				echo -e "\e[32mSuccess\e[00m"
			else
				echo -e "\e[31mFailed to add repository\e[00m"
			fi

			# Configure user to make commits.
			echo "Configure git:"
			read -p "What's your GitHub username? " USERNAME
			git config --global user.name "$USERNAME"
			read -p "What's your GitHub email? " EMAIL
			git config --global user.email "$EMAIL"

			read -p "What do you want to call the default branch? " DEF_BRANCH
			if [ ! -z $DEF_BRANCH ]; then
				git config --global init.defaultBranch "$DEF_BRANCH"
			fi
			unset USERNAME EMAIL DEF_BRANCH

			# Integrave vscode in some common Git operations.
			printf "Please, select a default editor for \e[36mcommit messages\e[00m:\n"
			GIT_EDITORS+=("vscode")
			GIT_EDITORS+=("vim")
			GIT_EDITORS+=("nano")
			GIT_EDITORS+=("gedit")
			select GIT_EDITOR in ${GIT_EDITORS[@]}; do
			case $GIT_EDITOR in
				vim)    git config --global core.editor vim            ;;
				vscode) git config --global core.editor 'code --wait'  ;;
				nano)   git config --global core.editor nano           ;;
				gedit)  git config --global core.editor 'gedit -s'     ;;
				*) echo "Option $GIT_EDITOR not recognized."; continue ;;
			esac; break; done
			unset GIT_EDITOR GIT_EDITORS

			printf "Setting \e[01mVS Code\e[00m as the default merge tool...\n"
			git config --global merge.tool vscode
			git config --global mergetool.vscode.cmd 'code --wait $MERGED'
			git config --global diff.tool vscode
			git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

			echo "Configuring pull behaviour..."
			git config --global pull.rebase false
			git config --global pull.ff only

			# Set up aliases
			printf "Setting up some Git aliases...\n"
			git config --global alias.mrc '!git merge $1 && git commit -m "$2" --allow-empty && :'
			git config --global alias.flog "log --all --graph --oneline --format=format:'%C(bold white)%h%C(r) -- %C(blue)%an (%ar)%C(r): %s %C(auto)%d%C(r)'"
			git config --global alias.slog 'slog --show-signature -1'
			git config --global alias.fflog 'log --graph'
			git config --global alias.mkst 'stash push -u'
			git config --global alias.popst 'stash pop "stash@{0}" -q'
			git config --global alias.unstage 'reset -q HEAD -- .'

			echo
			;;

			"GPG - User assisted")
			printf "Setting up \e[36mGPG\e[00m...\n"
			printf "\e[33mPlease follow the steps:\e[00m\n"
			gpg --full-generate-key
			printf "\e[33mListing keys:\e[00m\n"
			gpg --list-secret-keys --keyid-format long
			printf "\e[33mPlease copy the key and paste it here: \e[00m"
			read KEY
			printf "\e[33mConfiguring \e[01mgit\e[00;33m to automatically \e[01msign\e[00;33m all your commits...\e[00m\n"
			git config --global user.signingkey "$KEY"
			git config --global commit.gpgsign yes
			printf "\e[33mDo you want to print the public signature to add it to your \e[01mGitHub\e[00;33m? (Y/n) \e[00m"
			read
			if [[ ${REPLY,,} == "y" ]] || [[ -z $REPLY ]]; then
				gpg --armor --export "$KEY"
			fi
			unset KEY

			echo
			;;

			"C++ Tools")
			echo -e "Installing \e[36mgdb\e[00m and \e[36mclang-format\e[00m.."
			Animate & PID=$!
			sudo apt-get install gdb clang-format -y >/dev/null
			O=$?; kill $PID
			if [ $O -eq 0 ]; then
				echo -e "\e[32mSuccess\e[00m"
			else
				echo -e "\e[31mInstallation failed\e[00m"
			fi
			echo
			;;

			".NET Core 3.1")
			echo "Adding microsoft repository..."
			Animate & PID=$!
			wget -q https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb -O .packages-microsoft-prod.deb &>/dev/null
			sudo dpkg -i .packages-microsoft-prod.deb &>/dev/null
			rm .packages-microsoft-prod.deb &>/dev/null
			kill $PID
			echo "Done"

			echo "Updating repositories..."
			Animate & PID=$!
			sudo apt-get update &>/dev/null
			O=$?; kill $PID
			if [ $O -eq 0 ]; then
				echo -e "\e[32mSuccess\e[00m"
			else
				echo -e "\e[31mUpdate failed\e[00m"
			fi

			echo "Installing $c..."
			Animate & PID=$!
			sudo apt-get install apt-transport-https dotnet-sdk-3.1 aspnetcore-runtime-3.1 -y >/dev/null
			O=$?
			kill $PID
			if [ $O -eq 0 ]; then
				echo -e "\e[32mSuccess\e[00m"
			else
				echo -e "\e[31mInstallation failed\e[00m"
			fi
			echo
			;;

			"Java JDK")
			echo "Installing JDK..."
			Animate & PID=$!
			sudo apt-get install default-jdk -y >/dev/null
			O=$?; kill $PID
			if [ $O -eq 0  ]; then
				echo -e "\e[32mSuccess\e[00m"
			else
				echo -e "\e[31mInstallation failed\e[00m"
			fi
			echo
			;;

			SSH)
			echo "Set up an SSH key pair to use with GitHub"
			read -p "Input a password: " -s PASS; echo # echo to fix read -s not printing a new line.

			ssh-keygen -t rsa -b 4096 -C "GitHub-Key" -N "$PASS" -f ~/.ssh/id_GitHub-Key_main
			unset PASS

			echo -e "\e[36mAdding public key to the clipboard...\e[00m"
			xclip -selection clipboard < ~/.ssh/id_GitHub-Key_main.pub
			sleep 1.5
			echo
			;;

			"VS Code Extension development")
			echo "Installing Node.js 15..."
			Animate & PID=$!
			curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash - >/dev/null
			sudo apt-get install -y nodejs >/dev/null
			kill $PID

			echo "Installing VS Code extension generator..."
			Animate & PID=$!
			sudo npm install -g yo generator-code vsce >/dev/null
			kill $PID
			echo
			;;

			exit) break ;;
			*) echo "Option $c not recognized." ;;
		esac
		done
		unset LIST
		;;

		lm-sensors)
		Separate 4
		echo "Configure \"lm-sensors\":"
		sleep 1.5 # Time for the user to read.
		sudo sensors-detect
		;;

		cmatrix) # Remove unnecessary .desktop file.
		sudo rm /usr/share/applications/cmatrix.desktop 2>/dev/null
		;;

		vim) # Make a ~/.vimrc from the sample.
		cat $script_location/samples/vimrc | sudo tee -a ~/.vimrc /root/.vimrc >/dev/null
		;;

		zsh) # Install Powerline.
		Separate 4
		echo -e "Successfully installed \e[34mzsh\e[00m"

		echo -e "Preparing \e[33m.zshrc\e[00m files..."

		if [ -f "$script_location/samples/zshrc" ]; then
			if [ ! -f ~/.zshrc ]; then
				cat "$script_location/samples/zshrc" | tee -a ~/.zshrc ~/.zshrc-backup >/dev/null
			fi
			if [ ! -f /root/.zshrc ]; then
				cat "$script_location/samples/zshrc" | sudo tee -a /root/.zshrc /root/.zshrc-backup >/dev/null
			fi
		fi

		echo -e "Installing \e[33mPowerline Shell\e[00m..."
		Animate & PID=$!
		sudo pip3 install powerline-shell &>/dev/null
		O=$?; kill $PID

		if [ $O -eq 0 ]; then
			echo -e "\e[32mInstallation successful\e[00m, making configurations..."
			Animate & PID=$!
			# Enable powerline in the .zshrc files.
			sed -i "s/# use_powerline/use_powerline/" ~/.zshrc
			sudo sed -i "s/# use_powerline/use_powerline/" /root/.zshrc

			# Install fonts from the repository.
			cd
			git clone https://github.com/powerline/fonts.git ".PLfonts" >/dev/null
			if [ $? -eq 0 ]; then
				cd .PLfonts
				./install.sh >/dev/null
			fi
			if [ -d ~/.PLfonts ]; then rm -rf ~/.PLfonts; fi
			cd "$script_location"

			# Configure the powerline theme.
			mkdir -p ~/.config/powerline-shell
			sudo mkdir -p /root/.config/powerline-shell
			#region file
			echo "{"                     | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "  \"segments\": ["     | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"virtual_env\","  | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"username\","     | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"hostname\","     | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"ssh\","          | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"cwd\","          | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"git\","          | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"hg\","           | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"jobs\","         | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"root\""          | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "  ],"                  | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "  \"cwd\": {"          | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "    \"max_depth\" : 3" | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "  }"                   | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			echo "}"                     | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json >/dev/null
			#endregion

			kill $PID
			echo "Done"
		else
			echo -e "\e[31mInstallation failed\e[00m"
		fi

		# We need to remake this alias.
		echo "Making new alias for the backup script..."
		Make_backup_alias ~/.zsh_aliases

		echo -e "Setting \e[34mzsh\e[00m as the new \e[33mdefault shell\e[00m..."
		chsh -s $(which zsh)
		;;
	esac
done
fi
unset ALREADY_REMOVED_FIREFOX
Separate 4

if [ ! -z ${TO_FLATPAK[@]} ]; then
	echo "Installing flatpaks..."
	flatpak install ${TO_FLATPAK[@]} -y
	Separate 4
fi
unset TO_FLATPAK

if [ "$(ls -A ~/Downloads/ | grep ".deb")" ]; then
	echo "Installing downloaded packages..."
	sudo apt install ~/Downloads/*.deb -y -q
	rm ~/Downloads/*.deb
	Separate 4
fi
#endregion


#region Finalizing
echo "Ensuring packages are up to date..."
Animate & PID=$!
if [ "$(sudo apt-get update | grep "apt list --upgradable")" ]]; then
	echo -e "Some packages can be upgraded, \e[36mupgrading...\e[00m"
	sudo apt-get upgrade -y >/dev/null
fi
O=$?; kill $PID
echo "Ensuring flatpaks are up to date..."
flatpak update -y
Separate 4

# Run secondary scripts.
if [ "$INSTALL_DUC" = true ]; then
	"$script_location"/duc_noip_install.sh -e # -e to create an app menu entry.
	Separate 4
fi
if [ "$BUILD_MC_SERVER" = true ]; then
	"$script_location"/mc_server_builder.sh
	Separate 4
fi
unset BUILD_MC_SERVER INSTALL_DUC
if [ -f "$script_location/gnome_settings.sh" ]; then
	"$script_location"/gnome_settings.sh
	Separate 4
fi
if [ -f "$script_location/gnome_appearance.sh" ]; then
	echo "Restarting gnome shell..."
	busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")' >/dev/null
	sleep 8 # Wait for the refresh to be over before continuing
	"$script_location"/gnome_appearance.sh
	Separate 4
fi

# Copy deskcuts.
#   These files use icons found in a .mydock folder at /home/user/.mydock
if [ -d "$script_location"/deskcuts ] && [ ! -z "$(ls -A "$script_location"/deskcuts/ | grep ".desktop")" ]; then
	echo "Copying deskcuts..."

	cp "$script_location/deskcuts/browser-*" ~/.local/share/applications

	# Use the prefixes of the files to determine wether the package was
	#   installed, if so, copy the deskcut.
	LIST=$(ls -AR "$script_location"/deskcuts/ | grep ".desktop")
	for i in ${LIST[@]}; do
		case $i in
			launcher_fenix.desktop) # Relies on Java.
			if [[ ${TO_APT[@]} == *"default-jre"* ]]; then
				cp "$script_location"/deskcuts/launcher_fenix.desktop ~/.local/share/applications
			fi
			;;
		esac
	done
	unset LIST COPIED_BROWSER_DESKCUTS
fi
unset TO_APT

# Create an empty file template.
if [ ! -f ~/Templates/Empty ]; then
	echo "Creating empty file template..."
	touch ~/Templates/Empty
	chmod -x ~/Templates/Empty
fi

# Clean and organize the app menu alphabetically.
Clean_up
# FIXME: Fix organizing the app menu alphabetically.
# gsettings reset org.gnome.shell app-picker-layout # (broken in GNOME 3.38.3)
gsettings reset org.gnome.gedit.state.window size

# If the user chose to, update the recovery partition using Pop!_OS' API. Do
#   this last, as the tool downloads a full image of the OS and that can take
#   a very long time.
if [ "$UPDATE_RECOVERY" = true ]; then
	Separate 4
	echo "Upgrading recovery partition..."
	pop-upgrade recovery upgrade from-release
fi
unset UPDATE_RECOVERY
Separate 4

# Restart GNOME's package kit.
sudo systemctl start packagekit
#endregion

# Clean dependency files.
if [ -f ~/.config/autostart/continue_pop_OS_start.desktop ]; then
	rm ~/.config/autostart/continue_pop_OS_start.desktop
fi
if [ -f "$choices_file" ]; then rm "$choices_file"; fi

echo -e "It's highly recommended to \e[33mreboot\e[00m now."

if [ "$persist_at_the_end" = true ]; then
	read -p "Press any key to finish." -n 1
fi

popd >/dev/null
exit 0

# Thanks for downloading, and enjoy!
