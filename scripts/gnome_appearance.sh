#!/bin/bash
# Script to configure the theme in gnome.
# Originally developed in Gnome Shell 3.38.1.

# MIT License - Copyright (c) 2021 Nicolás Castellán
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

# TODO: Configure your theme
# Add this folder structure to the root of this repository to auto-configure your theme.
# There can only be one file in each subfolder of 'themes' 

# script's location
# └── themes
#     ├── background
#     │   └── image.png
#     ├── cursor
#     │   └── cursor.tar.gz
#     ├── icons
#     │   └── icons.tar.gz
#     └── theme
#         └── theme.tar.gz

# Git will ignore the themes folder.
# The script assumes the archives' basenames (before '.tar.{xz,gz}') are the names of the themes.

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
	mkdir -p ~/.local/share/icons
	tar -C ~/.local/share/icons -xf "$f"
	cursor_name="${f/.tar.*/}"
fi
unset f

icons_name=""
if [ -d "$location/themes/icons" ]; then
	cd "$location/themes/icons"
	f="$(ls)"
	mkdir -p ~/.local/share/icons
	tar -C ~/.local/share/icons -xf "$f"
	icons_name="${f/.tar.*/}"
fi
unset f

theme_name=""
if [ -d "$location/themes/theme" ]; then
	cd "$location/themes/theme"
	f="$(ls)"
	mkdir -p ~/.local/share/themes
	tar -C ~/.local/share/themes -xf "$f"
	theme_name="${f/.tar.*/}"
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
	# Setting icons theme.
	echo "Configuring icons theme..."
	gsettings set org.gnome.desktop.interface icon-theme "$icons_name"
fi

# Configuring background
bk="$(ls "$location/themes/background" | grep -e '\.png$' -e '\.jpg$')"
if [ "$bk" ]; then
	destination="$HOME/.local/share/backgrounds"
	echo "Configuring background..."
	DATE="$(date +"%Y-%m-%d-%H-%M-%S")"
	mkdir -p "$destination"
	cp "$location/themes/background/$bk" "$destination/$DATE-$bk"
	gsettings set org.gnome.desktop.background picture-uri "file://$destination/$DATE-$bk"
	unset destination
fi

# Thanks for downloading, and enjoy!
