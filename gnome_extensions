#!/bin/bash
# Script to set my extensions how I like them.

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

(xdg-open "https://extensions.gnome.org/extension/906/sound-output-device-chooser/") &
(xdg-open "https://extensions.gnome.org/extension/97/coverflow-alt-tab/") &
(xdg-open "https://extensions.gnome.org/extension/307/dash-to-dock/") &
(xdg-open "https://extensions.gnome.org/extension/779/clipboard-indicator/") &

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

# Thanks for downloading, and enjoy!
