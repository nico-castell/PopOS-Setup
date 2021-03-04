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

# TODO: Configure your theme
# Add this folder structure to the root of this repository to auto-configure your theme.
# The files must end in '.tar.gz' and there can only be one file in each subfolder of 'themes'.
# .
# └── themes
#     ├── background
#     │   └── image.png
#     ├── cursor
#     │   └── cursor.tar.gz
#     ├── icons
#     │   └── icons.tar.gz
#     └── theme
#         └── theme.tar.gz
#
# Git will ignore the themes folder.
# The script assumes the archives' basenames (before '.tar.gz') are the names of the themes.

cd "$(dirname "$0")"
location="$(pwd)"

if [ ! -d "$location/themes" ]; then
	exit 1
fi

echo "Decompressing user themes..."
pushd . >/dev/null
cursor_name=""
if [ -d "$location/themes/cursor" ]; then
	cd "$location/themes/cursor"
	f="$(ls)"
	tar -zxf "$f"
	mkdir -p ~/.icons
	cursor_name="${f/".tar.gz"/""}"
	mv "$cursor_name" ~/.icons
fi
unset f

icons_name=""
if [ -d "$location/themes/icons" ]; then
	cd "$location/themes/icons"
	f="$(ls)"
	tar -zxf "$f"
	mkdir -p ~/.icons
	icons_name="${f/".tar.gz"/""}"
	mv "$icons_name" ~/.icons
fi
unset f

theme_name=""
if [ -d "$location/themes/theme" ]; then
	cd "$location/themes/theme"
	f="$(ls)"
	tar -zxf "$f"
	mkdir -p ~/.themes
	theme_name="${f/".tar.gz"/""}"
	mv "$theme_name" ~/.themes
fi
unset f

popd >/dev/null

# Enable user-themes extensions.
echo "Enabling user themes..."
EXT=$(gnome-extensions list | grep user-theme)
gnome-extensions enable $EXT

if [ "$theme_name" ]; then
	# Enabling shell theme.
	echo "Configuring shell theme..."
	gsettings set org.gnome.shell.extensions.user-theme name "$theme_name"

	# Enabling application theme.
	echo "Configuring application theme..."
	gsettings set org.gnome.desktop.wm.preferences theme "$theme_name"
	gsettings set org.gnome.desktop.interface gtk-theme "$theme_name"
fi

if [ "$cursor_name" ]; then
	# Setting cursor theme.
	echo "Configuring cursor theme..."
	gsettings set org.gnome.desktop.interface cursor-theme "$cursor_name"
fi

if [ "$icons_name" ]; then
	Setting icons theme.
	echo "Configuring icons theme..."
	gsettings set org.gnome.desktop.interface icon-theme "$icons_name"
fi

# Configuring background
bk="$(ls "$location/themes/background" | grep -e '\.png$' -e '\.jpg$')"
if [ "$bk" ]; then
	destination="/home/$USER/.local/share/backgrounds"
	echo "Configuring background..."
	DATE="$(date +"%Y-%m-%d-%H-%M-%S")"
	mkdir -p "$destination"
	cp "$location/themes/background/$bk" "$destination/$DATE-$bk"
	gsettings set org.gnome.desktop.background picture-uri "file://$destination/$DATE-$bk"
	unset destination
fi

# Configuring interface.
echo "Configuring interface..."
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

# Thanks for downloading, and enjoy!
