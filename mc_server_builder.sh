#!/bin/bash
# Script to deploy a minecraft server from scratch.

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

#region Initialization
#===========================================================================
# This will check options, contain the "delete server" code, and check for internet.

# Assigning booleans to the options.
while [ -n "$1" ]; do
    case "$1" in
        -d | --delete) REMOVE=true ;;                     # This option is there to delete the server.
        -fd | --full-delete) REMOVE=true && FULL=true ;;  # This is option is for a full removal of the server.
        -s | --skip) SKIP=true ;;                         # This option is to skip the user settings.
        -us | --user-config-only) USERCONFIGONLY=true ;;  # This will only run the user settings.
        -mc | --not-hide-mc) NOTHIDEMCFOLDER=true ;;      # Not hide .mcserver folder.
        -h | --help)                                      # Offer help.
            echo "This script deploys a Minecraft Java Server in you computer."
            echo "Options are:"
            echo "  -d | --delete) Delete the server."
            echo "  -fd | --full-delete) Complete removal of the server (includes firewall and start menu entry)"
            echo "  -s | --skip) Skip the user settings of server.properties."
            echo "  -us | --user-config-only) Only configure the server."
            echo "  -h | --help) Show this menu."
            echo "  -mc | --not-hide-mc) Not hide server directory."
            exit
            ;;
        *) echo >&2 "Option \"$1\" not recognized." && exit 1 ;;
esac; shift; done

if [ "$NOTHIDEMCFOLDER" = true ]; then
    MCFOLDER=("mcserver")
else
    MCFOLDER=(".mcserver")
fi

# This part of the script will delete the server and all of it's files (permanently).
if [ $REMOVE ]; then
    read -p "Are you sure you want to delete the server permanently? (y/N) "
    if [[ $REPLY == "y" ]] || [[ $REPLY == "Y" ]]; then
        if [ ! -d ~/"$MCFOLDER"/ ]; then
            echo "Server has been deleted previously."
        else
            echo "Deleting server files..."
            rm -r ~/"$MCFOLDER"/

            # When the -fd option is used, it will delete everything it originally created.
            if [ $FULL ]; then
                echo "Deleting start menu entry..."
                if [ -f /usr/share/applications/mcserver.desktop ]; then
                    sudo rm /usr/share/applications/mcserver.desktop
                fi

                echo -e "\nChoose the rule/s for port 25565 # MC-SERVER"
                sudo ufw status numbered
                while [ true ]; do
                    read -p "> "
                    if [ -z $REPLY ]; then break; fi
                    sudo ufw delete $REPLY
                done

                # Ensure changes take place.
                sudo ufw reload
                echo -e "\n\e[33mThe firewall will not be disabled.\e[00m"
                echo "Run 'sudo ufw disable' to disable it"
            fi
        fi
    fi
    exit
fi

# Framework for user_settings.
ask_setting () {
    read -p "$1 ($2) "
    if [[ -z $REPLY ]]; then REPLY=("$2"); fi # Default to what is specified.
    REPLACE=$(cat server.properties | grep "^$3=")
    sed -i "s/$REPLACE/$3=$REPLY/" server.properties
}

# This will promt the user for configurations.
user_settings () {
    ask_setting "Do you want the server to run in online mode?" "true" "online-mode"
    ask_setting "What will be the motd of the world?" "A Minecraft Server" "motd"
    ask_setting "What will be the default gamemode?" "survival" "gamemode"
    ask_setting "What will be the difficulty of the world?" "normal" "difficulty"
    ask_setting "What will be the maximum ammount of players?" "2" "max-players"
    ask_setting "What will be the view distance?" "7" "view-distance"
    ask_setting "What will be the player idle timeout?" "14" "player-idle-timeout"
}

#===========================================================================
#endregion Initialization

# Run the user settings only.
if [ $USERCONFIGONLY ]; then
    if [ -f ~/"$MCFOLDER"/server.properties ]; then
        cd ~/"$MCFOLDER"/
        user_settings
        exit
    else
        echo "`tput setaf 1`\"server.properties\" does not exist.`tput sgr0`"
        exit 1
    fi
fi

# Test for an internet connection and exit if none is found.
ping -c 1 google.com &>/dev/null
if [ ! $? -eq 0 ]; then
    echo -e >&2 "\e[31mERROR: No internet\e[00m"
    exit 1
fi

#region Preparing the server
#===========================================================================
# Performing checks, making directories, downloading server & icon, and creating run.

# If the directory for the server doesn't already exist, it'll create it.
if [ ! -d ~/"$MCFOLDER" ]; then
    echo "Creating ~/$MCFOLDER directory..."
    mkdir ~/"$MCFOLDER"
else
    echo -e "\e[32m~/$MCFOLDER already present\e[00m"
fi

echo "Accesing ~/$MCFOLDER/..."
cd ~/"$MCFOLDER"/
# Now it's downloading a minecraft server from mojang.
if [ ! -f ./server*.jar ]; then
    echo "Getting minecraft server 1.16.5 from Mojang..."
    # Copy the download link from https://www.minecraft.net/en-us/download/server if there's a newer version.
    wget https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar
else
    echo -e "\e[32mServer already present\e[00m"
fi

# If there's no server icon present this will download one from the author's dropbox.
if [ ! -f ./server-icon.png ]; then
    echo "Downloading a server icon..."
    wget -q https://www.dropbox.com/s/g6z9zjitgwg4c0x/server-icon.png?dl=1
    mv ./server-icon* ./server-icon.png
fi

if [ ! -f ./run ]; then
    # This will create the file to run the server from now on.
    echo "Creating run file..."

    # It'll aks the user about the usage of RAM and if they don't answer it'll default to 1G.
    echo -e "How much \e[33mRAM\e[00m do you want the server to use?"
    echo -e "If you leave this blank the server will use 1G"
    read -p "> "

    if [[ -z $REPLY ]]; then RAM=1G; else RAM=$REPLY; fi

    #region Target File ============================================================
    echo "#!/bin/bash" >> run
    echo "# Script to start the minecraft server." >> run
    echo >> run
    echo "# The .desktop file should be in /usr/share/applications/mcserver.desktop" >> run
    echo >> run
    echo "while [ -n \"\$1\" ]; do" >> run
    echo "    case \"\$1\" in" >> run
    echo "        -s) SLEEP=true   ;; # Skip the final timer (Useful when running this script from a terminal)." >> run
    echo "        -p) PERSIST=true ;; # Persist at the end, useful for debugging." >> run
    echo "        *) echo \"ERROR: Option \$1 not recongized\" >&2 && exit 1 ;;" >> run
    echo "esac; shift; done" >> run
    echo >> run
    echo "# Function to draw a line across the width of the console." >> run
    echo "Separate () {" >> run
    echo "    if [ ! -z \$1 ]; then tput setaf \$1; fi" >> run
    echo "    printf \"\n\n%\`tput cols\`s\n\" |tr \" \" \"=\"" >> run
    echo "    tput sgr0" >> run
    echo "}" >> run
    echo >> run
    echo "# Verbosing the options." >> run
    echo "if [ \$PERSIST ]; then echo \"\" \"The window will stay open after stopping the server.\"; fi" >> run
    echo >> run
    echo "printf \"\nAccessing the server folder...\n\"" >> run
    echo "cd \"\$(dirname \"\$0\")\"" >> run
    echo "printf \"\nStarting the server...\"\n" >> run
    echo >> run
    echo "# This actually runs the server." >> run
    echo "Separate 6" >> run
    echo "java -Xmx\$RAM -Xms\$RAM -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:G1HeapRegionSize=32M -XX:MaxGCPauseMillis=50 -jar server*.jar --nogui" >> run
    echo "Separate 6" >> run
    echo >> run
    echo "printf \"\nServer has stopped.\"\n" >> run
    echo >> run
    echo "# The options take effect here." >> run
    echo "if [ \$SLEEP ];   then sleep 1.5; fi" >> run
    echo "if [ \$PERSIST ]; then read -p \"Persisting, press ENTER to exit.\"; fi" >> run
    #endregion Target File ============================================================
else
    echo -e "\e[32mrun already present`tput sgr0`"
fi

# Adding executable permissions to 'run'.
chmod +x ./run

#===========================================================================
#endregion Preparing the server


#region Setting up the server
#===========================================================================
# Now it will run the server, agree to the eula and configure some things in server.properties.

# Checking if Java is installed (I mean... the server runs on it)
if [ ! -f /usr/bin/java ]; then
    echo >&2 "`tput setaf 1`You need java installed to proceed.`tput sgr0`"

    # Offer to install java.
    read -p "Do you want to install \"default-jre\"? (Y/n) "
    if [[ ${REPLY,,} == "y" ]] || [[ -z $REPLY ]]; then
        echo "Installing..."
        sudo apt-get install default-jre -y > /dev/null
        if [ $? -eq 0 ]; then echo "Sucessful installation."; else exit 1; fi
        echo
    else exit 1; fi
fi

# Checking the status of eula.txt
if [ -f eula.txt ]; then
    # Getting the value of eula.
    EULA=$(cat eula.txt | grep "eula=")
    EULA=${EULA/"eula="/""}

    # If it's false then agree to it.
    if [[ "$EULA" == "false" ]]; then
        echo "Agreeing to the EULA..."
        sed -i 's/eula=false/eula=true/' eula.txt
    else
        # It's already been agreed to.
        echo "`tput setaf 2`EULA has already been agreed to.`tput sgr0`"
    fi
else
    # Starting the server for the first time and then agreeing to the eula.
    echo -e "\nFirst server start, expect eula error..."
    java -jar server.jar --nogui --initSettings
    echo -e "\nServer exited..."

    # Agreeing to the eula in eula.txt is necessary to run the server.
    echo -e "Modifying eula.txt...\n"
    sed -i 's/eula=false/eula=true/' eula.txt
fi

# Now it will modify some things in server.properties
sed -i 's/enable-command-block=false/enable-command-block=true/' server.properties

# Finding the user's LAN ipv4 and using it for the server.
LAN=$(hostname -I)
LAN=${LAN//" "/""}
echo "Server IP will be: \"$LAN\""

LANTEST=$(cat ~/$MCFOLDER/server.properties | grep "server-ip=")
LANTESTED=${LANTEST/"server-ip="/""}

# Checking that the ip isn't already there before writing it.
if [[ $LANTESTED == $LAN ]]; then
    echo "Server IP is already correct."
    echo
    echo "`tput setaf 2`Server has already been built.`tput sgr0`"
else
    echo "Writing server IP..."
    sed -i "s/$LANTEST/server-ip=$LAN/" server.properties
fi

# Configure the server.properties file using the function.
if [ ! $SKIP ]; then
    echo
    user_settings
fi

#===========================================================================
#endregion Setting up the server


#region Final touches
#===========================================================================
# Adding the server to the start menu, and checking firewall

# Now it asks for permission to continue and use sudo privileges.
echo
echo "The server is built, only steps remaining are:"
echo "    1. Creating start menu entry"
echo "    2. Updating the firewall"
echo -e "--> \e[33msudo\e[00m privileges will be required <--"
read -p "Do you want to continue? (Y/n) "
if [[ ${REPLY,,} == "n" ]]; then exit; fi

# Now it will test for the presence of the .desktop file for this server.
if [ ! -f /usr/share/applications/mcserver.desktop ]; then
    # If the file doesn't exist it will create it.
    cd /usr/share/applications/
    #region Target File ============================================================
    echo "[Desktop Entry]" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Name=MC Server" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Comment=Start the local minecraft server." | sudo tee -a ./mcserver.desktop > /dev/null
    echo "GenericName=Minecraft;Server;mcserver" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Exec=/home/$USER/$MCFOLDER/run -s" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Icon=/home/$USER/$MCFOLDER/server-icon.png" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Type=Application" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "StartupNotify=false" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Terminal=true" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "StartupWMClass=" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Categories=Minecraft;Server;Game;" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Actions=open-persistent;open-skipping;" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Keywords=Server;Minecraft" | sudo tee -a ./mcserver.desktop > /dev/null
    echo | sudo tee -a ./mcserver.desktop > /dev/null
    echo "X-Desktop-File-Install-Version=0.24" | sudo tee -a ./mcserver.desktop > /dev/null
    echo | sudo tee -a ./mcserver.desktop > /dev/null
    echo "[Desktop Action open-persistent]" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Name=Open persistent window" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Exec=/home/$USER/$MCFOLDER/run -p" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Icon=/home/$USER/$MCFOLDER/server-icon.png" | sudo tee -a ./mcserver.desktop > /dev/null
    echo | sudo tee -a ./mcserver.desktop > /dev/null
    echo "[Desktop Action open-skipping]" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Name=Open skipping close timer" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Exec=/home/$USER/$MCFOLDER/run" | sudo tee -a ./mcserver.desktop > /dev/null
    echo "Icon=/home/$USER/$MCFOLDER/server-icon.png" | sudo tee -a ./mcserver.desktop > /dev/null
    #endregion Target File ============================================================

    echo .e "\n\e[32mEntry created.\e[00m"
else
    # If the file is already there, it will just say it's already there.
    echo -e "\e[32mEntry is already created.\e[00m"
fi

echo -e "\e[33mYou should press Alt+F2 and run 'r' if the server entry doesn't load\e[00m"
echo -e "\e[33mThe entry icon will be \"server-icon.png\" in ~/.mcserver/.\e[00m"

# Now it's updating the firewall rules.
echo -e "\nAllowing traffic on port 25565 through the firewall..."
sudo ufw allow 25565 comment 'MC-SERVER'

# This checks the firewall activation and outputs in red if it's inactive.
FIREWALL=$(sudo ufw status | grep "Status: ")
FIREWALL=${FIREWALL/"Status: "/""}

if [[ $FIREWALL = "inactive" ]]; then
    echo
    echo -e "\e[31mFirewall is disabled\e[00m"
    read -p "Do you want to enable it? (Y/n) "

    # If the firewall is off, then the script will offer to activate it.
    if [[ ${REPLY,,} == "y" ]] || [[ $REPLY = $null ]]; then
        echo "Enabling firewall..."
        sudo ufw enable
    fi
fi
# Ensure changes take place.
sudo ufw reload

echo -e "\n\e[32mCongratulations! You now have a minecraft server.\e[00m"

#===========================================================================
#endregion Final touches

# Thanks for downloading, and enjoy!
