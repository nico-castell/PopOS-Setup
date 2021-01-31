#!/bin/bash
# Script to configure the theme in gnome.
# Originally developed in Gnome Shell 3.38.1.

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

#region Preparing files
#===========================================================================
# Unzip files, and move them.

echo "Beginning configuration of user themes..."

# Find drive and folder.
# FIXME: Don't have a fixed path
if [ ! -d /media/$USER/Data\ \&\ BackUps/Nico\'s\ Files/Personalization/ ]; then
    echo >&2 "`tput setaf 1`Source directory or drive not found.`tput sgr0`"
    exit 1
fi

# Prepare the destionation folders.
echo "Creating destination directories..."
if [ ! -d ~/.themes ]; then mkdir ~/.themes; fi
if [ ! -d ~/.icons ]; then mkdir ~/.icons; fi

echo "=================="

# Access the directory and unzip the files.
echo "Accessing source folder..."
cd /media/$USER/Data\ \&\ BackUps/Nico\'s\ Files/Personalization

for d in icons themes; do
    echo "Accessing $d..."
    cd $d/

    # Find .zip files and unzip them.
    echo "Listing..."
    LIST=$(ls *.zip)
    echo "------------------"
    for i in ${LIST[@]}; do

        # Copy the file, only if it hasn't already been installed.
        if [ ! -d ~/.$d/${i/".zip"/""} ]; then

            echo "Unziping $i..."
            unzip $i > /dev/null

            echo "Moving ${i/".zip"/""}..."
            mv ${i/".zip"/""} ~/.$d/

        fi

    done
    cd ..
    echo "=================="
done

#===========================================================================
#endregion Preparing files


#region Configuring gsettings
#===========================================================================
# Enable extension and configure the relevant settings.

# Enable user-themes extensions.
echo "Enabling user themes..."
EXT=$(gnome-extensions list | grep user-theme)
gnome-extensions enable $EXT

# Enabling shell theme.
echo "Configuring shell theme..."
gsettings set org.gnome.shell.extensions.user-theme name "Sweet-mars"

# Enabling application theme.
echo "Configuring application theme..."
gsettings set org.gnome.desktop.wm.preferences theme "Sweet-mars"
gsettings set org.gnome.desktop.interface gtk-theme "Sweet-mars"

# Setting cursor theme.
echo "Configuring cursor theme..."
gsettings set org.gnome.desktop.interface cursor-theme "macOSBigSur"

# Setting icons theme.
# echo "Configuring icons theme..."
# gsettings set org.gnome.desktop.interface icon-theme "Cupertino-Catalina"

# Configuring interface.
echo "Configuring interface..."
DATE=$(date +"%Y-%m-%d-%H-%M-%S")
if [ ! -d ~/.local/share/backgrounds/ ]; then mkdir ~/.local/share/backgrounds; fi
cp ~/Pictures/Wallpapers/Modern.jpg ~/.local/share/backgrounds/$DATE-Modern.jpg
gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/.local/share/backgrounds/$DATE-Modern.jpg"
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.interface clock-format 24h
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.shell.extensions.ding show-volumes false

# Configuring terminal.
echo "Configuring the terminal..."
GNOME_TERMINAL_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}'`

gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ cursor-shape "underline"
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-transparency false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-transparent-background true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ background-color "'rgb(5,5,5)'"
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ background-transparency-percent 20
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ scrollbar-policy "'never'"
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ font "Hack 12"

#===========================================================================
#endregion Configuring gsettings

# Thanks for downloading, and enjoy!
