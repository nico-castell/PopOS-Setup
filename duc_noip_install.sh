#!/bin/bash
# Script to install No-Ip's DUC on Linux

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

#region Checks
#===========================================================================
# Checking options internet and installation.

while [ -n "$1" ]; do

    case "$1" in

        # Create a start menu entry.
        -e) ENTRY=true ;;

        # Use crontab to autostart the DUC at start-up.
        # -a) AUTOSTART=true ;;

        # Offer a help message.
        -h)
            echo "This script installs No-Ip's DUC on your computer."
            echo "The options are:"
            echo "  -e) Create a start menu entry."
            echo "  -h) Show this menu."
            exit
            ;;

        *) echo "Option $1 not recognized" && exit 1 ;;

    esac

    shift

done

# This test for an internet connection and exits if it cannot find one.
wget -q --spider www.google.com
if [ ! $? -eq 0 ]; then

    echo >&2 "`tput setaf 1`ERROR: Internet not found`tput sgr0`"
    exit 1

fi

# Checking if the DUC is already installed.
FINDDUC=$(which noip2)
FINDDUC=${FINDDUC/"/usr/local/bin/"/""}

if [ $FINDDUC = "noip2" ]; then

    echo "`tput setaf 2`No-Ip's DUC is already installed`tput sgr0`, exiting..."
    echo "run 'sudo noip2 -S' if it's not already configured"
    exit

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

    echo "`tput setaf 1`ERROR: You need to install the package 'wget' to download the file`tput sgr0`"
    exit 1

fi

# Actually downloads the file.
sudo wget http://www.noip.com/client/linux/noip-duc-linux.tar.gz

echo "Unpacking the file"
sudo tar xf noip-duc-linux.tar.gz

# This will open a text editor to type your password,
#   It's necessary because tping to the installer can
#   cause certain symbols to be written incorrectly and
#   cause a "Wrong password" error.
(gedit ) &
cd noip-2*

# Now it'll compile the program from source.
echo "Attempting Installation"

# Now it'll test if make is installed before continuing.
FINDMAKE=$(which make)

if [[ ! $FINDMAKE = *"make"* ]]; then

    echo "`tput setaf 1`ERROR: You need to install the package 'make' to install the DUC.`tput sgr0`"
    exit 1

fi

# This will actually install the program.
sudo make install
echo

echo "Creating configuration file..."
sudo /usr/local/bin/noip2 -C
echo

echo "Removing lefover .tar.gz file..."
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
    cd ~/.mydock/
    if [ ! -f ~/.mydock/noiplogo.png ]; then

        echo "Downloading logo..."
        wget -q https://www.dropbox.com/s/g55zl9q9uc2a1pw/noiplogo.png?dl=1
        mv ./noiplogo* ./noiplogo.png

    fi

    if [ ! -f ./noip_duc ]; then

        echo "Making target file..."
        #region File ============================================================
        echo "#!/bin/bash" >> noip_duc
        echo "# Script to start the DUC." >> noip_duc
        echo >> noip_duc
        echo "while [ -n \"\$1\" ]; do" >> noip_duc
        echo >> noip_duc
        echo "    case \"\$1\" in" >> noip_duc
        echo >> noip_duc
        echo "        # Show PID and wait." >> noip_duc
        echo "        -s) SHOW=true ;;" >> noip_duc
        echo >> noip_duc
        echo "        # Open to kill process." >> noip_duc
        echo "        -k) KILL=true ;;" >> noip_duc
        echo >> noip_duc
        echo "        *) echo \"Option \$1 not recognized\" && exit ;;" >> noip_duc
        echo >> noip_duc
        echo "    esac" >> noip_duc
        echo >> noip_duc
        echo "    shift" >> noip_duc
        echo >> noip_duc
        echo "done" >> noip_duc
        echo >> noip_duc
        echo "# Find Process ID and kill it." >> noip_duc
        echo "if [ \$KILL ]; then" >> noip_duc
        echo >> noip_duc
        echo "    echo \"Please type your sudo password:\"" >> noip_duc
        echo "    sudo /usr/local/bin/noip2 -S" >> noip_duc
        echo "    echo" >> noip_duc
        echo "    read -p \"Input the PID > \"" >> noip_duc
        echo "    sudo /usr/local/bin/noip2 -K \$REPLY" >> noip_duc
        echo "    echo" >> noip_duc
        echo "    read -p \"Press ENTER to exit.\"" >> noip_duc
        echo "    exit" >> noip_duc
        echo >> noip_duc
        echo "fi" >> noip_duc
        echo >> noip_duc
        echo "# Start No-Ip's DUC." >> noip_duc
        echo "echo \"Please type your sudo password:\"" >> noip_duc
        echo "sudo /usr/local/bin/noip2" >> noip_duc
        echo "echo \"DUC Started Succesfully\"" >> noip_duc
        echo >> noip_duc
        echo "# Show the PID." >> noip_duc
        echo "if [ \$SHOW ]; then" >> noip_duc
        echo >> noip_duc
        echo "    echo" >> noip_duc
        echo "    sudo /usr/local/bin/noip2 -S" >> noip_duc
        echo "    echo" >> noip_duc
        echo "    read -p \"Press ENTER to exit.\"" >> noip_duc
        echo >> noip_duc
        echo "fi" >> noip_duc
        echo >> noip_duc
        echo "if [ ! \$SHOW ]; then sleep 1.5; fi" >> noip_duc
        #endregion File ============================================================

    fi

    chmod +x ./noip_duc

    # This will create the .desktop file.
    cd /usr/share/applications/
    if [ ! -f ./noip_duc.desktop ]; then

        echo "Creating noip_duc.desktop file..."
        #region File ============================================================
        echo "[Desktop Entry]" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Name=No-Ip DUC" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Comment=Start the dynamic update client." | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "GenericName=DUC;" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Exec=/home/$USER/.mydock/noip_duc" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Icon=/home/$USER/.mydock/noiplogo.png" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Type=Application" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "StartupNotify=false" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Terminal=true" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Categories=Network;Server;" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Actions=open-showing;open-killing;" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Keywords=Network;Minecraft;Server;" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "X-Desktop-File-Install-Version=0.24" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "[Desktop Action open-showing]" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Name=Open showing PID" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Exec=/home/$USER/.mydock/noip_duc -s" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Icon=/home/$USER/.mydock/noiplogo.png" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "[Desktop Action open-killing]" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Name=Open to end process" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Exec=/home/$USER/.mydock/noip_duc -k" | sudo tee -a ./noip_duc.desktop > /dev/null
        echo "Icon=/home/$USER/.mydock/noiplogo.png" | sudo tee -a ./noip_duc.desktop > /dev/null
        #endregion File ============================================================

    fi

    echo "Press 'Alt+F2' and run 'r' if the entry doesn't yet load."

fi

#===========================================================================
#endregion Start menu entry


#region Autostart
#===========================================================================
# Use crontab to autostart the DUC at start-up.

# FINDCRON=$(which crontab)
# if [ -z $FINDCRON ]; then

#     echo "`tput setaf 1`ERROR: You need cron installed to autostart the DUC at system start-up`tput sgr0`"

# else

#     echo "Automating initialization of the DUC..."
#     echo "@reboot su -l $USER && sudo noip2" | sudo tee -a /var/spool/cron/crontabs/root > /dev/null
#     if [ $? -eq 0 ]; then echo "Automation was successful."; fi

# fi

#===========================================================================
#endregion Autostart
# The script has ended.
echo "`tput setaf 2`No-Ip's DUC has been installed!`tput sgr0`"

# Thanks for downloading, and enjoy!
