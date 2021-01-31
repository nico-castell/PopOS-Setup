#!/bin/bash
# Script to set up Pop!_OS in the best way possible.

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

#region Options
while [ -n "$1" ]; do
    case "$1" in
        # User options ==========================
        # Load from temporary file.
        --from-temp-file) load_tmp_file=true ;;

        # Disable rebooting in the script.
        --disable-reboot) disable_reboot=true ;;

        # Help menu.
        --help)
        echo "This script sets up a Pop!_OS installation as best as possible."
        echo "Options are:"
        echo "  --from-temp-file) Loads previous choices."
        echo "  --disable-reboot) Stops the script from rebooting the computer."
        exit
        ;;

        # Internal options ======================
        # Make the script persist at the end.
        -p) persist_at_the_end=true ;;

        *) echo "ERROR: Option $1 not recognized" && exit 1 ;;
    esac
    shift
done
#endregion Options

# Getting script's absolute location for later.
pushd . > /dev/null
cd "$(dirname "$0")" # Stay in this directory.
script_location="$(pwd)"
choices_file=("$script_location/.tmp_choices")

# Function to draw a line across the width of the console.
Separate () {
    if [ ! -z $1 ]; then tput setaf $1; fi
    printf "\n\n%`tput cols`s\n" |tr " " "="
    tput sgr0
}

# Now the script will branch in two directions, before continuing and using
# variables set by either one of the branches.

#region Choices
#===========================================================================
# 2 Branches to load choices from the user of from a file

#region Prompting the user ============================================================
# Branch 1, prompt the user.
if [ -z $load_tmp_file ]; then

    # Confirm items in a list. Goes through a list, and prompts about each item,
    # then outputs the chosen ones.
    Confirm_from_list () {
        unset Confimed
        for i in ${To_Confirm[@]}; do

            # Colored prompt with a 10 second time-out
            read -p "Confirm `tput setaf 3`\"$i\"`tput sgr0` (Y/n) " -t 10
            O=$?

            # Make yes the default answer, only when pressing ENTER.
            if [ $O -eq 0 ] && [ -z $REPLY ]; then REPLY=("y"); fi
            # When read times out, default to no, as the answer.
            if [ $O -gt 128 ]; then echo; REPLY=("n"); fi # echo to create consistent new line behaviour.

            if [[ ${REPLY,,} == "y" ]]; then
                Confimed+=("$i") # Append to the list.
            fi

        done
    }

    # Remove previous choices, as this branch will create a new one.
    if [ -f "$choices_file" ]; then rm "$choices_file"; fi

    # Confirm packages to remove.
    echo "Confirm packages to remove:"
    To_Confirm=("geary" "libreoffice*")
    Confirm_from_list
    TO_REMOVE=(${Confimed[@]}) # Packages that will be removed.
    echo "TO_REMOVE- ${TO_REMOVE[@]}" >> "$choices_file"
    Separate 4

    # Confirm packages to install.
    echo "Confirm packages to install:"
     To_Confirm=("audacity" "code" "zsh" "dconf-editor" "gimp" "gnome-tweaks" "brave-browser" "google-chrome-stable")
    To_Confirm+=("lm-sensors" "hddtemp" "os-prober" "p7zip-full" "thunderbird" "vlc" "default-jre" "discord" "gparted")
    To_Confirm+=("spotify-client" "glade" "htop" "obs-studio" "pavucontrol" "virtualbox" "gnome-chess" "signal-desktop")
    To_Confirm+=("gnome-mines" "steam" "cmatrix")
    Confirm_from_list
    TO_APT=(${Confimed[@]}) # Packages that will be installed.
    # Append packages that are essential, so they should always be installed.
    TO_APT+=("build-essential" "gnome-shell-extensions" "neofetch" "ubuntu-restricted-extras" "xclip" "vim" "gawk")
    if [[ "${TO_APT[@]}" == *"zsh"* ]]; then
        TO_APT+=("zsh-syntax-highlighting" "zsh-autosuggestions" "fonts-powerline" "python3-pip")
    fi
    echo "TO_APT- ${TO_APT[@]}" >> "$choices_file"
    Separate 4

    # Confirm flatpaks to install.
    echo "Confirm flatpaks to install:"
    To_Confirm=("com.dropbox.Client" "com.Spotify.Client" "org.kde.kdenlive")
    Confirm_from_list
    TO_FLATPAK=(${Confimed[@]})
    echo "TO_FLATPAK- ${TO_FLATPAK[@]}" >> "$choices_file"
    Separate 4

    # Choose an item from the list of options.
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
    Choose_driver system76-driver-nvidia nvidia-driver-390 nvidia-driver-455
    echo "NVIDIA_DRIVER- $NVIDIA_DRIVER" >> "$choices_file"
    Separate 4

    # Offer to update recovery partition at the end of the script.
    read -p "Do you want to update the recovery partition? (y/N) "
    if [[ ${REPLY,,} == "y" ]]; then
        UPDATE_RECOVERY=true
        echo "UPDATE_RECOVERY" >> "$choices_file"
    else UPDATE_RECOVERY=false; fi

    # Promt the user for confirmation to run a script, if the script is present.
    prompt_user () {
        unset Confirmed
        if [ -f "$script_location/$1" ]; then
            read -p "Do you want to $2 (Y/n) "
            if [[ ${REPLY,,} == "y" ]] || [[ -z $REPLY ]]; then
                Confimed=true
            else Confimed=false; fi
        else Confirmed=false; fi
    }

    # Offer to install No-Ip's DUC.
    prompt_user "duc_noip_install" "install No-Ip's DUC"
    INSTALL_DUC=("$Confimed")
    if [ "$INSTALL_DUC" = true ]; then
        echo "INSTALL_DUC" >> "$choices_file"
    fi

    # If java is going to be installed, offer to build a minecraft server.
    if [[ ${TO_APT[@]} == *"default-jre"* ]]; then
        prompt_user "mc_server_builder.sh" "build a minecraft server"
        BUILD_MC_SERVER=("$Confimed")
        if [ "$BUILD_MC_SERVER" = true ]; then
            echo "BUILD_MC_SERVER" >> "$choices_file"
        fi
    fi

    Separate 4
fi
#endregion Prompting the user ============================================================

#region Loading previous choices ============================================================
# Branch 2, load previous choices.
if [ "$load_tmp_file" = true ]; then

    # If there are previous choices, load them, else exit.
    if [ ! -f "$choices_file" ]; then
        echo >&2 "`tput setaf 1`ERROR: Previous choices are not available.`tput sgr0`"
        exit 1
    else
        echo "`tput setaf 3`Loading previous choices...`tput sgr0`"
    fi

    # Function to load choices into variables.
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

    # Find if the name of a choice is in the file, if it is, return true, else return false.
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
#endregion Loading previous choices ============================================================

#===========================================================================
#endregion Choices

# Now carry on using variables from the branches.

#region Preparing the environment.
#===========================================================================
# Handle relevant folders, firewall and .bashrc aliases

# Ensure the following folders are present.
if [ ! -d ~/.mydock ] && [ -d ~/mydock ]; then mv ~/mydock ~/.mydock; fi
if [ ! -d ~/.mydock ]; then mkdir ~/.mydock; fi

# Test firewall and activate it.
echo "Checking firewall..."
FIREWALL=$(sudo ufw status | grep "Status: ")
FIREWALL=${FIREWALL/"Status: "/""}
if [[ $FIREWALL = "inactive" ]]; then
    echo "Enabling firewall..."
    sudo ufw enable
fi

# Make the backup alias for the backup script
Make_backup_alias () {
    # If there is a backup script, make an alias for it, but only, if an alias hasn't already been made.
    if [ -f "$script_location/back_me_up.sh" ] && [ -z "$(cat $1 | grep "alias backup")" ]; then
        echo >> $1
        echo "alias backup=\"$script_location/back_me_up.sh\"" >> $1
    fi
}
echo "Making an alias for the backup script..."
Make_backup_alias ~/.bashrc

Separate 4

# This tests for an internet connection and exits if it cannot find one.
wget -q --spider www.google.com
if [ ! $? -eq 0 ]; then
    echo >&2 "`tput setaf 1`ERROR: Internet not found`tput sgr0`"
    exit 1
fi

#===========================================================================
#endregion Preparing the environment.


#region Major software
#===========================================================================
# Update everything (inc. kernel) and install nvidia driver.

#region Functions ============================================================

# Show an animation while waiting for a process to finish (usage: Animate & pid=$!; kill $pid)
Animate() {
    CICLE=('|' '/' '-' '\')
    while true; do
        for i in "${CICLE[@]}"; do
            printf "%s\r" $i
            sleep 0.2
        done
    done
}

# Function to use the package manager to clean up.
Clean_up () {
    echo; echo "Cleaning..."
    sudo apt-get autopurge -y -qq # Silently.
    sudo apt-get autoclean -y -qq
}

# Make the system reboot and restart this script after log in.
Custom_reboot_resume () {
    ###########################################################################
    #     WARNING: check for $disable_reboot BEFORE running this function.    #
    ###########################################################################

    # Ensure autostart directory is available.
    if [ ! -d ~/.config/autostart/ ]; then
        mkdir ~/.config/autostart
    fi

    # Ensure that the file wasn't already present.
    if [ -f ~/.config/autostart/continue_pop_OS_start.desktop ]; then
        rm ~/.config/autostart/continue_pop_OS_start.desktop
    fi

    #region .desktop to autorun this script. ============================================================
    echo "[Desktop Entry]" >> ~/.config/autostart/continue_pop_OS_start.desktop
    echo "Name=TMP Continue pop_OS_start" >> ~/.config/autostart/continue_pop_OS_start.desktop
    echo "Exec=$script_location/pop_OS_start --from-temp-file -p" >> ~/.config/autostart/continue_pop_OS_start.desktop
    echo "Type=Application" >> ~/.config/autostart/continue_pop_OS_start.desktop
    echo "StartUpNotify=true" >> ~/.config/autostart/continue_pop_OS_start.desktop
    echo "Terminal=true" >> ~/.config/autostart/continue_pop_OS_start.desktop
    echo "X-Desktop-File-Install-Version=0.24" >> ~/.config/autostart/continue_pop_OS_start.desktop
    #endregion .desktop to autorun this script. ============================================================

    # Tell user that the computer is going to reboot.
    echo >&2 "`tput setaf 9`Rebooting computer in 15 seconds."
    echo >&2 "Press ENTER to reboot now."
    read -p "Press 'C' to cancel `tput sgr0`" -t 15 -n 1 # -n 1 to resume without the user habing to press ENTER.
    O=$?
    # If reply is not empty, it's because the user canceled the reboot.
    if [[ ! -z $REPLY ]]; then
        echo
        return 1 # Returning 1 means the user canceled the reboot.
    fi
    if [ $O -gt 128 ]; then echo; fi # Create consistent new line behaviour from read -t.

    sudo reboot
    exit 2 # Exit code 2 means rebooting.
}

# Assist Custom_reboot_continue
Instruct_system_reboot () {
    if [ "$DO_REBOOT" = true ]; then
        Custom_reboot_resume
        # Test if the user canceled, and separate if they did.
        if [ $? -eq 1 ]; then
            Separate 4
        fi
    fi
}
#endregion Functions ============================================================

# Remove chosen software.
echo "Removing software..."
Animate & PID=$!
sudo apt-get purge ${TO_REMOVE[@]} -y > /dev/null
kill $PID; echo "Done"
echo
# Update repositories to get latest updates.
echo "Updating repositories..."
Animate & PID=$!
sudo apt-get update > /dev/null
kill $PID; echo "Done"
Separate 4

# Simulate and upgrade using dist-upgrade, if the pattern "linux" is found, assume kernel is being
# updated and test if rebooting was not disabled, then instruct the script to reboot after upgrading.
UPGRADE_SIM=$(apt-get -s dist-upgrade | grep "linux")
if [ ! -z "$UPGRADE_SIM" ] && [ ! $disable_reboot = true ]; then
    DO_REBOOT=true
    echo "`tput setaf 9`The system will reboot after upgrading the kernel...`tput sgr0`"
fi

# Perform the upgrade.
echo "Upgrading software to the latest version..."
sudo apt-mark hold firefox* > /dev/null # The script may delete firefox, so it's held back to make it ho faster.
sudo apt dist-upgrade -y
sudo apt-mark unhold firefox* > /dev/null
Clean_up
Separate 4

Instruct_system_reboot
unset TO_REMOVE UPGRADE_SIM DO_REBOOT

# The script will only run the code pertaining the installation of an nvidia driver, if there is a
# driver to be installed that either was chosen by the user or loaded from tmp file.
if [ ! -z $NVIDIA_DRIVER ]; then

    # Check if driver to be installed is not Pop!_OS' custom driver, then check if reboot was disabled,
    # only then, instruct the script to reboot to load proper display settings.
    if [[ ! $NVIDIA_DRIVER == *"system76-driver-nvidia"* ]] && [ ! "$disable_reboot" = true ]; then
        DO_REBOOT=true
        echo "The system will reboot after installing the nvidia driver..."
    fi

    # Install the driver.
    echo "Installing NVIDIA driver `tput setaf 3`\"$NVIDIA_DRIVER\"`tput sgr0`..."
    sudo apt install $NVIDIA_DRIVER -y

    # Replace driver in tmp_file with 'Already installed driver' to avoid a boot loop.
    REPLACE=$(cat "$choices_file" | grep "^NVIDIA_DRIVER- ")
    sed -i "s/$REPLACE/ALREADY_INSTALLED_DRIVER/" "$choices_file"

    Clean_up
    Separate 4

    Instruct_system_reboot
    unset DO_REBOOT REPLACE

fi
unset NVIDIA_DRIVER

#===========================================================================
#endregion Major software


#region Installing programs
#===========================================================================
# Intall packages, flatpaks and downloaded packages

# Notes about some packages:
# Teamviewer can only be downloaded from the website.
# Dropbox is not found using apt, you have to download it, and the installer sets up their repo.
# Zoom is available as a flatpak, but it very bad. It's recommended to download the .deb package.

# Stop gnome package kit, it holds the update process and causes most apt-get updates to fail.
sudo systemctl stop packagekit

# CONFIGURE THE SYSTEM MIRRORS.
NEW_MIRR=("http://ubuntu.mirror.constant.com/")
MIRR_FILE=("/etc/apt/sources.list.d/system.sources")
# Escape special characters in the mirror and then replace in the file.
echo "Changing mirror to `tput setaf 3`$NEW_MIRR`tput sgr0`,"
echo "edit `tput setaf 3`$MIRR_FILE`tput sgr0` to change it..."
echo
NEW_MIRR=$(printf '%s\n' "$NEW_MIRR" | sed -e 's/[\/&]/\\&/g')
sudo sed -i "s/^URIs:.*/URIs: $NEW_MIRR/" $MIRR_FILE
unset MIRR NEW_MIRR MIRR_FILE

# Prepare keys and repositories for some packages with proprietary repositories.
for i in ${TO_APT[@]}; do
    case $i in
        spotify-client)
        echo "Preparing Spotify repository..."
        curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - &>/dev/null
        echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list &>/dev/null
        ;;

        brave-browser)
        echo "Preparing Brave Browser repository..."
        curl -sS https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add - &>/dev/null
        echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list &>/dev/null
        ;;

        google-chrome-stable)
        echo "Preparing Google Chrome repository..."
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &>/dev/null
        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list &>/dev/null
        ;;

        code)
        echo "Preparing Visual Studio Code repository..."
        wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/packages.microsoft.gpg add - &>/dev/null
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list &>/dev/null
        ;;

        signal-desktop)
        echo "Preparing Signal Desktop repository..."
        curl -sS https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add - &>/dev/null
        echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list &>/dev/null
        ;;
    esac
done

# Update repositories.
echo "Updating repositories..."
Animate & PID=$!
sudo apt-get update > /dev/null
kill $PID; echo "Done"
Separate 4

# Install all choses packages in one command.
echo "Installing packages..."
sudo apt install ${TO_APT[@]} -y

# Check if the previous command ran successsfully, then start handling special instructions for
# some of the installed packages.
if [ $? -eq 0 ]; then
for i in ${TO_APT[@]}; do
    case $i in
        # Assume that installing chrome or brave means the user won't use firefox, so remove it.
        google-chrome-stable | brave-browser)
        if [ ! "$ALREADY_REMOVED_FIREFOX" ]; then
            ALREADY_REMOVED_FIREFOX=true
            Separate 4
            echo -e "\"\e[36m$i\e[00m\" was installed, removing \e[33mFirefox\e[00m..."
            Animate & PID=$!
            sudo apt-get purge firefox* -y > /dev/null 2> /dev/null
            Clean_up > /dev/null 2> /dev/null
            kill $PID
        fi
        ;;

        # Offer a list of instructions to prepare common developer tools.
        code)
        Separate 4
        echo -e "\e[36mVisual Studio Code\e[00m was successfully installed,"
        echo "Choose some developer tools to prepare:"

        LIST+=("Git")
        LIST+=("GDB Debugger")
        LIST+=(".NET Core 3.1")
        LIST+=("Java JDK")
        LIST+=("SSH")
        LIST+=("VS Code Extension development")

        # Offer a select menu for the user to set up different tools.
        select c in "${LIST[@]}" exit; do
        case $c in
            Git) # Set up git repository.
            echo "Adding git ppa repository..."
            Animate & PID=$!
            sudo apt-add-repository -y ppa:git-core/ppa > /dev/null
            O=$!; kill $PID
            if [ $O -eq 0 ]; then
                echo -e "\e[32mSuccess\e[00m"
            else
                echo -e "\e[31mFailed to add repository\e[00m"
            fi

            # Set up user to make commits.
            echo "Configure git:"
            read -p "What's your GitHub username? " USERNAME
            git config --global user.name "$USERNAME"
            read -p "What's your GitHub email? " EMAIL
            git config --global user.email "$EMAIL"

            # Set up initial branch name
            read -p "What do you want to call the default branch? " DEF_BRANCH
            if [ ! -z $DEF_BRANCH ]; then
                git config --global init.defaultBranch "$DEF_BRANCH"
            fi
            unset USERNAME EMAIL DEF_BRANCH

            # Set vscode as the default merge tool to resolve conflicts.
            printf "Setting \e[01mVS Code\e[00m as the default merge tool...\n"
            git config --global merge.tool vscode
            git config --global mergetool.vscode.cmd 'code --wait $MERGED'
            # Set vscode as the default diff tool.
            git config --global diff.tool vscode
            git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
            # Set vim as the default text editor.
            printf "Setting \e[01mvim\e[00m as the default text editor...\n"

            # Configure default pull behaviour.
            echo "Configuring pull behaviour..."
            git config --global pull.rebase false
            git config --global pull.ff only

            # Set up some aliases to explore commits.
            printf "Setting up \e[01m'flog'\e[00m and \e[01m'slog'\e[00m aliases...\n"
            git config --global alias.flog 'log --color --decorate --oneline'
            git config --global alias.slog 'slog --show-signature -1'

            echo
            ;;

            "GDB Debugger") # Install a C++ debugger.
            echo "Installing gdb debugger for C++..."
            Animate & PID=$!
            sudo apt-get install gdb -y > /dev/null
            O=$?; kill $PID
            if [ $O -eq 0 ]; then
                echo -e "\e[32mSuccess\e[00m"
            else
                echo -e "\e[31mInstallation failed\e[00m"
            fi
            echo
            ;;

            ".NET Core 3.1") # Install the .NET Core framework.
            # Get and add the microsoft signing key and repository to the trusted keys.
            echo "Adding microsoft repository..."
            Animate & PID=$!
            wget -q https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb -O .packages-microsoft-prod.deb &>/dev/null
            sudo dpkg -i .packages-microsoft-prod.deb 2> /dev/null > /dev/null
            rm .packages-microsoft-prod.deb 2> /dev/null > /dev/null
            kill $PID
            echo "Done"

            echo "Updating repositories..."
            Animate & PID=$!
            sudo apt-get update 2> /dev/null > /dev/null
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

            "Java JDK") # Install developer tools for Java.
            echo "Installing JDK..."
            Animate & PID=$!
            sudo apt-get install $c -y > /dev/null
            O=$?; kill $PID
            if [ $O -eq 0  ]; then
                echo -e "\e[32mSuccess\e[00m"
            else
                echo -e "\e[31mInstallation failed\e[00m"
            fi
            echo
            ;;

            SSH) # Create an ssh key to use with GitHub.
            echo "Set up an SSH key pair to use with GitHub"
            read -p "Input a password: " -s PASS; echo # read -s does not print a new line, so print it manually.

            # Generate the key pair.
            ssh-keygen -t rsa -b 4096 -C "GitHub-Key" -N "$PASS" -f ~/.ssh/id_GitHub-Key_main
            unset PASS

            # Start the ssh agent, add the key, and stop the agent.
            SSHAGENTID=$(eval "$(ssh-agent -s)")
            ssh-add ~/.ssh/id_GitHub-Key_main
            SSHAGENTID=${SSHAGENTID/"Agent pid "/""}
            kill $SSHAGENTID
            unset SSHAGENTID

            # Copy the public key to the clipboard, so the user can copy it into GitHub.
            echo "`tput setaf 6`Adding public key to the clipboard, link it to your GitHub account.`tput sgr0`"
            xclip -selection clipboard < ~/.ssh/id_GitHub-Key_main.pub
            sleep 1.5 # Give the user time to read.
            echo
            ;;

            "VS Code Extension development") # Install everything necessary to code VS Code extensions.
            # Install Node.js
            echo "Installing Node.js 15..."
            Animate & PID=$!
            curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash - >/dev/null
            sudo apt-get install -y nodejs >/dev/null
            kill $PID

            # Install Yeoman and VS Code Extension Generator
            echo "Installing VS Code extension generator"
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

        lm-sensors) # Configure sensors.
        Separate 4
        echo "Configure \"lm-sensors\":"
        sleep 1.5 # Time for the user to read.
        sudo sensors-detect
        ;;

        cmatrix) # Remove unnecessary .desktop file.
        sudo rm /usr/share/applications/cmatrix.desktop 2> /dev/null
        ;;

        vim) # Make the ~/.vimrc file
        cp /usr/share/vim/vim82/vimrc_example.vim ~/.vimrc
        sudo cp /usr/share/vim/vim82/vimrc_example.vim /root/.vimrc
        echo >> ~/.vimrc
        echo "set number" >> ~/.vimrc
        sudo echo >> /root/.vimrc
        sudo echo "set number" >> /root/.vimrc
        ;;

        zsh) # Install and configure powerline prompt for zsh
        Separate 4
        echo -e "Successfully installed \e[34mzsh\e[00m"

        echo -e "Preparing \e[33m.zshrc\e[00m files..."
        # Only copy the files if there aren't any previous copies.
        if [ -f "$script_location/samples/zshrc" ]; then
            if [ ! -f ~/.zshrc ]; then
                cp "$script_location/samples/zshrc" ~/.zshrc
                cp "$script_location/samples/zshrc" ~/.zshrc-backup
            fi
            if [ ! -f /root/.zshrc ]; then
                sudo cp "$script_location/samples/zshrc" /root/.zshrc
                sudo cp "$script_location/samples/zshrc" /root/.zshrc-backup
            fi
        fi

        echo -e "Installing \e[33mPowerline Shell\e[00m..."
        Animate & PID=$!
        sudo pip3 install powerline-shell > /dev/null 2> /dev/null
        O=$?; kill $PID

        if [ $O -eq 0 ]; then
            echo -e "\e[32mInstallation successful\e[00m, making configurations..."
            Animate & PID=$!
            # Uncomment functions .zshrc files to enable powerline.
            sed -i "s/# use_powerline/use_powerline/" ~/.zshrc
            sudo sed -i "s/# use_powerline/use_powerline/" /root/.zshrc

            # Clone the powerline fonts repository and install all the fonts, then remove the repo.
            cd
            git clone https://github.com/powerline/fonts.git ".PLfonts" > /dev/null
            if [ $? -eq 0 ]; then
                cd .PLfonts
                ./install.sh > /dev/null
            fi
            if [ -d ~/.PLfonts ]; then rm -rf ~/.PLfonts; fi
            cd "$script_location"

            # Configure the powerline theme.
            mkdir -p ~/.config/powerline-shell
            sudo mkdir -p /root/.config/powerline-shell
            #region file ============================================================
            echo "{" | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "  \"segments\": [" | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"virtual_env\"," | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"username\"," | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"hostname\"," | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"ssh\"," | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"cwd\"," | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"git\"," | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"hg\"," | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"jobs\"," | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"root\"" | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "  ]," | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "  \"cwd\": {" | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "    \"max_depth\" : 3" | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "  }" | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            echo "}" | sudo tee -a ~/.config/powerline-shell/config.json /root/.config/powerline-shell/config.json > /dev/null
            #endregion file ============================================================

            kill $PID
            echo "Done"
        else
            echo -e "\e[31mInstallation failed\e[00m"
        fi

        # Make the back_me_up alias in the new rc file.
        echo "Making new alias for the backup script..."
        Make_backup_alias ~/.zshrc

        # Make zsh the default shell.
        echo -e "Setting \e[34mzsh\e[00m as the new \e[33mdefault shell\e[00m..."
        chsh -s $(which zsh)
        ;;
    esac
done
fi
unset ALREADY_REMOVED_FIREFOX
Separate 4

# Install all flatpaks with one command.
if [ ! -z ${TO_FLATPAK[@]} ]; then
    echo "Installing flatpaks..."
    flatpak install ${TO_FLATPAK[@]} -y
    Separate 4
fi
unset TO_FLATPAK

# Test for debian packages in Downloads folder and install them.
if [ "$(ls -A ~/Downloads/ | grep ".deb")" ]; then
    echo "Installing downloaded packages..."
    sudo apt install ~/Downloads/*.deb -y -q
    rm ~/Downloads/*.deb
    Separate 4
fi

#===========================================================================
#endregion Installing programs


#region Finalizing
#===========================================================================
# Secondary scripts, final touches and recovery update.

# Ensure everything is updated.
echo "Ensuring packages are up to date..."
Animate & PID=$!
if [ "$(sudo apt-get update | grep "apt list --upgradable")" ]]; then
    echo -e "Some packages can be upgraded, \e[36mupgrading...\e[00m"
    sudo apt-get upgrade -y > /dev/null
fi
O=$?; kill $PID
echo "Ensuring flatpaks are up to date..."
flatpak update -y
Separate 4

# Install DUC.
if [ "$INSTALL_DUC" = true ]; then
    "$script_location"/duc_noip_install -e # -e is to create an app meny entry.
    Separate 4
fi

# Build minecraft server.
if [ "$BUILD_MC_SERVER" = true ]; then
    "$script_location"/mc_server_builder.sh
    Separate 4
fi
unset BUILD_MC_SERVER INSTALL_DUC

# Configure gnome using secondary scripts.
if [ -f "$script_location/gnome_settings.sh" ]; then
    "$script_location"/gnome_settings.sh
    Separate 4
fi

if [ -f "$script_location/gnome_appearance.sh" ]; then
    echo "Restarting gnome shell..."
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")' > /dev/null
    sleep 8 # Wait for the refresh to be over before continuing
    "$script_location"/gnome_appearance.sh
    Separate 4
fi

# Find the deskcuts folder and copy its .desktop files.
# These files use the icons found in a .mydock folder in the user's home directory.
if [ -d "$script_location"/deskcuts ] && [ ! -z "$(ls -A $script_location/deskcuts/ | grep ".desktop")" ]; then
    echo "Copying deskcuts..."
    # Get all of the items and then look at the prefixes of each file, if they match one of the patterns
    # in the case statement, see if the requires package was installed. Only then, copy the deskcut.
    # In the case of the browsers, only copy deskcuts for one of them.
    LIST=$(ls -AR "$script_location"/deskcuts/ | grep ".desktop")
    for i in ${LIST[@]}; do
        case $i in
            chr*) # These deskcuts rely on Google chrome.
            if [ $COPIED_BROWSER_DESKCUTS == true ]; then continue; fi
            COPIED_BROWSER_DESKCUTS=true
            if [[ ${TO_APT[@]} == *"google-chrome-stable"* ]]; then
                sudo cp "$script_location"/deskcuts/chrome/chr*.desktop /usr/share/applications/
            fi
            ;;

            bra*) # These deskcuts rely on Brave Browser.
            if [ $COPIED_BROWSER_DESKCUTS == true ]; then continue; fi
            COPIED_BROWSER_DESKCUTS=true
            if [[ ${TO_APT[@]} == *"brave-browser"* ]]; then
                sudo cp "$script_location"/deskcuts/brave/bra*.desktop /usr/share/applications/
            fi
            ;;

            code*) # These deskcuts rely on Visual Studio Code.
            if [[ ${TO_APT[@]} == *"code"* ]]; then
                sudo cp "$script_location"/deskcuts/code* /usr/share/applications/
            fi
            ;;

            launcher_fenix.desktop) # This deskcut relies on Java.
            if [[ ${TO_APT[@]} == *"default-jre"* ]]; then
                sudo cp "$script_location"/deskcuts/launcher_fenix.desktop /usr/share/applications/
            fi
            ;;
        esac
    done
    unset LIST COPIED_BROWSER_DESKCUTS
fi
unset TO_APT

# Test for and empty file template and create it if absent.
if [ ! -f ~/Templates/Empty ]; then
    echo "Creating empty file template..."
    touch ~/Templates/Empty
    chmod -x ~/Templates/Empty
fi

# Clean and organize the appmenu alphabetically.
Clean_up
gsettings reset org.gnome.shell app-picker-layout
gsettings reset org.gnome.gedit.state.window size

# If the user chose to, update the recovery partition using Pop!_OS' API. Do this last, as the tool
# downloads a full image of the OS and that can take a very long time.
if [ "$UPDATE_RECOVERY" = true ]; then
    Separate 4
    echo "Upgrading recovery partition..."
    pop-upgrade recovery upgrade from-release
fi
unset UPDATE_RECOVERY

Separate 4

#===========================================================================
#endregion Finalizing

sudo systemctl start packagekit

# When the script is finished, remove the autostart file.
if [ -f ~/.config/autostart/continue_pop_OS_start.desktop ]; then
    rm ~/.config/autostart/continue_pop_OS_start.desktop
fi
# Remove the choices file at the end of the script.
if [ -f "$choices_file" ]; then rm "$choices_file"; fi

echo "It's highly recommended to `tput setaf 3`reboot`tput sgr0` now."

if [ "$persist_at_the_end" = true ]; then
    read -p "Press any key to finish." -n 1
fi

popd > /dev/null
exit 0

# Thanks for downloading, and enjoy!
