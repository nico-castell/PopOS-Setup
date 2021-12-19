#!/bin/bash
# Script to set my extensions how I like them.

# MIT License - Copyright (c) 2021 Nicolás Castellán <cnicolas.developer@gmail.com>
# SPDX License identifier: MIT
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

(xdg-open "https://extensions.gnome.org/extension/906/sound-output-device-chooser/" &>/dev/null) &
(xdg-open "https://extensions.gnome.org/extension/97/coverflow-alt-tab/" &>/dev/null) &
(xdg-open "https://extensions.gnome.org/extension/307/dash-to-dock/" &>/dev/null) &
(xdg-open "https://extensions.gnome.org/extension/779/clipboard-indicator/" &>/dev/null) &

read -p "Press enter to continue... "

read -p "Did you install \"dash-to-dock\"? (Y/n) "
if [[ ${REPLY,,} == "y" ]] || [[ -z $REPLY ]]; then
	printf "Configuring \e[33mDash to Dock\e[00m...\n"
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock show-trash false
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock show-mounts false
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock transparency-mode DYNAMIC
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock max-alpha 0.8
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock min-alpha 0.4
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock dock-position LEFT
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock running-indicator-style "'SEGMENTED'"
	# gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock*/schemas/ set org.gnome.shell.extensions.dash-to-dock animate-show-apps false
fi

read -p "Did you install \"Sound Output Device Chooser\"? (Y/n) "
if [[ ${REPLY,,} == "y" ]] || [[ -z $REPLY ]]; then
	printf "Configuring \e[33mSound Output Device Chooser\e[00m...\n"
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/sound-output-device-chooser*/schemas/ set org.gnome.shell.extensions.sound-output-device-chooser expand-volume-menu false
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/sound-output-device-chooser*/schemas/ set org.gnome.shell.extensions.sound-output-device-chooser hide-menu-icons false
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/sound-output-device-chooser*/schemas/ set org.gnome.shell.extensions.sound-output-device-chooser hide-on-single-device true
fi

read -p "Did you install \"Clipboard Indicator\"? (Y/n) "
if [[ ${REPLY,,} == "y" ]] || [[ -z $REPLY ]]; then
	printf "Configuring \e[33mClipboard Indicator\e[00m...\n"
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator*/schemas set org.gnome.shell.extensions.clipboard-indicator clear-history "['<Super>F10']"
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator*/schemas set org.gnome.shell.extensions.clipboard-indicator disable-down-arrow true
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator*/schemas set org.gnome.shell.extensions.clipboard-indicator move-item-first true
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator*/schemas set org.gnome.shell.extensions.clipboard-indicator next-entry "['<Super>F12']"
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator*/schemas set org.gnome.shell.extensions.clipboard-indicator prev-entry "['<Super>F11']"
	gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator*/schemas set org.gnome.shell.extensions.clipboard-indicator toggle-menu "['<Super>F9']"
fi

# Thanks for downloading, and enjoy!
