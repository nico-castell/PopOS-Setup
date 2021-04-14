#!/bin/bash
# Configure gsettings for gnome.

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

# Configuring Nautilus.
echo "Configuring nautilus..."
gsettings reset org.gnome.nautilus.window-state initial-size
gsettings reset org.gnome.nautilus.window-state sidebar-width
gsettings set org.gtk.Settings.FileChooser sort-directories-first true

# Configuring gedit.
echo "Configuring the text editor (gedit)..."
gsettings set org.gnome.gedit.plugins active-plugins "['sort', 'snippets', 'spell', 'quickhighlight', 'docinfo', 'time', 'filebrowser', 'modelines']"
gsettings set org.gnome.gedit.preferences.editor tabs-size "4"
gsettings set org.gnome.gedit.preferences.editor insert-spaces true

# Configuring calculator.
echo "Configuring calculator..."
gsettings set org.gnome.calculator refresh-interval 86400

# Configuring interface.
echo "Configuring interface..."
gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:appmenu"
gsettings set org.gnome.shell favorite-apps ['brave-browser.desktop', 'org.gnome.Geary.desktop', 'brave-hnpfjngllnobngcgfapefoaidbinmjnm-Default.desktop', 'browser-msoffice.desktop', 'org.gnome.Calendar.desktop', 'code.desktop', 'org.gnome.Nautilus.desktop', 'spotify.desktop']

echo "Configuring interface behaviour..."
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.desktop.wm.preferences action-middle-click-titlebar minimize
gsettings set org.gnome.SessionManager logout-prompt false

# Configuring peripherals.
echo "Configuring mouse..."
gsettings set org.gnome.desktop.peripherals.mouse accel-profile flat
gsettings set org.gnome.desktop.peripherals.mouse speed 0.084

echo "Configuring touchpad..."
gsettings set org.gnome.desktop.peripherals.touchpad click-method none
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad speed 0.5

# Configuring privacy.
echo "Enabling the removal of old trash files in 7 days' time..."
gsettings set org.gnome.desktop.privacy remove-old-trash-files true
gsettings set org.gnome.desktop.privacy old-files-age "7"

echo "Enabling the removal of old temporary files in 7 days' time..."
gsettings set org.gnome.desktop.privacy remove-old-temp-files true
gsettings set org.gnome.desktop.privacy recent-files-max-age "7"

echo "Setting the idle delay to 10 minutes..."
gsettings set org.gnome.desktop.session idle-delay "600"

# Configuring keybindings.
echo "Configuring keybindings..."
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>F10']"
gsettings set org.gnome.settings-daemon.plugins.media-keys calculator "['<Super>c']"
gsettings set org.gnome.settings-daemon.plugins.media-keys help "['<Super>F1']"
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Primary><Alt>t']"
gsettings set org.gnome.shell.extensions.pop-shell activate-launcher "['<Super>slash', '<Primary>apostrophe']"

# Configuring custom keybindings.
# Gedit.
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Open text editor"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Super>t'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "gedit"
# VS Code.
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Open VS Code"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "'<Primary><Super>c'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "code"
# Add the keybindings.
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[\
'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', \
'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"

# Enabling night light.
echo "Enabling night light..."
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3200

# Disable auto location in Weather.
echo "Disabling automatic location in weather..."
gsettings set org.gnome.Weather automatic-location false
gsettings set org.gnome.shell.weather automatic-location false

# Configure apps.
echo "Configuring Calendar..."
gsettings set org.gnome.calendar weather-settings "(false, true, '', nothing)"

echo "Configuring Image viewer..."
gsettings set org.gnome.eog.view transparency "'color'"
gsettings set org.gnome.eog.view extrapolate false

echo "Configuring Calculator..."
gsettings set org.gnome.calculator show-thousands true

echo "Configuring Geary mail..."
gsettings set org.gnome.Geary folder-list-pane-position-horizontal 200
gsettings set org.gnome.Geary messages-pane-position 480
gsettings set org.gnome.Geary migrated-config true
gsettings set org.gnome.Geary single-key-shortcuts true
gsettings set org.gnome.Geary startup-notifications true
gsettings set org.gnome.Geary formatting-toolbar-visible true

echo "Configuring Terminal..."
GNOME_TERMINAL_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}'`
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ default-size-columns 100
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ default-size-rows 32

echo "Configuring system monitor..."
gsettings set org.gnome.gnome-system-monitor current-tab "resources"
gsettings set org.gnome.gnome-system-monitor network-in-bits true

# Thanks for downloading, and enjoy!
