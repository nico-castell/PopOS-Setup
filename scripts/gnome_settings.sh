#!/bin/bash
# Configure gsettings for gnome.

# MIT License - Copyright (c) 2021 Nicolás Castellán
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

if which nautilus &>/dev/null; then
	echo "Configuring nautilus..."
	gsettings reset org.gnome.nautilus.window-state initial-size
	gsettings reset org.gnome.nautilus.window-state sidebar-width
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
	gsettings set org.gtk.Settings.FileChooser sort-directories-first true
fi

if which gedit &>/dev/null; then
	echo "Configuring the text editor (gedit)..."
	which dconf &>/dev/null && dconf reset -f /org/gnome/gedit/

	gsettings set org.gnome.gedit.plugins active-plugins "['time', 'spell', 'sort', 'snippets', 'quickhighlight', 'modelines', 'filebrowser', 'docinfo']"
	gsettings set org.gnome.gedit.preferences.editor tabs-size "3"
	gsettings set org.gnome.gedit.preferences.editor insert-spaces false

	gsettings set org.gnome.gedit.preferences.editor right-margin-position 100
	gsettings set org.gnome.gedit.preferences.editor wrap-mode 'none'

	gsettings set org.gnome.gedit.preferences.ui show-tabs-mode 'auto'
	gsettings set org.gnome.gedit.preferences.ui side-panel-visible true

	gsettings set org.gnome.gedit.preferences.editor scheme 'oblivion'
	gsettings set org.gnome.gedit.preferences.editor background-pattern 'none'
	gsettings set org.gnome.gedit.preferences.editor display-right-margin true
	gsettings set org.gnome.gedit.preferences.editor right-margin-position 100

	gsettings set org.gnome.gedit.state.window size '(1120, 700)'
	gsettings set org.gnome.gedit.state.window bottom-panel-size '140'
	gsettings set org.gnome.gedit.state.window side-panel-active-page 'GeditFileBrowserPanel'
fi

if which gnome-calculator &>/dev/null; then
	echo "Configuring calculator..."
	gsettings set org.gnome.calculator refresh-interval 86400
	gsettings set org.gnome.calculator show-thousands true
fi

if which gnome-weather &>/dev/null; then
	echo "Disabling automatic location in weather..."
	gsettings set org.gnome.Weather automatic-location false
	gsettings set org.gnome.shell.weather automatic-location false
fi

if which gnome-calendar &>/dev/null; then
	echo "Configuring Calendar..."
	gsettings set org.gnome.calendar weather-settings "(false, true, '', nothing)"
fi

if which eog &>/dev/null; then
	echo "Configuring Image viewer..."
	gsettings set org.gnome.eog.view transparency "'color'"
	gsettings set org.gnome.eog.view extrapolate false
fi

if which geary &>/dev/null; then
	echo "Configuring Geary mail..."
	gsettings set org.gnome.Geary formatting-toolbar-visible true
	gsettings set org.gnome.Geary single-key-shortcuts true
	gsettings set org.gnome.Geary startup-notifications true
	gsettings set org.gnome.Geary window-height 660
	gsettings set org.gnome.Geary window-width 1200
	gsettings set org.gnome.Geary window-maximize false
fi

if which gnome-terminal &>/dev/null; then
	echo "Configuring Terminal..."
	GNOME_TERMINAL_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}'`
	gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ default-size-columns 90
	gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ default-size-rows 30
fi

if which gnome-system-monitor &>/dev/null; then
	echo "Configuring system monitor..."
	gsettings set org.gnome.gnome-system-monitor current-tab "resources"
	gsettings set org.gnome.gnome-system-monitor network-in-bits true
fi

# Configuring interface.
echo "Configuring interface..."
gsettings set org.gnome.shell app-picker-layout '[]'
gsettings reset org.gnome.desktop.wm.preferences button-layout
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.desktop.wm.preferences action-middle-click-titlebar minimize
gsettings set org.gnome.SessionManager logout-prompt false
gsettings set org.gnome.desktop.calendar show-weekdate false
gsettings set org.gnome.desktop.interface clock-format 24h
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Configuring peripherals.
echo "Configuring mouse and touchpad..."
gsettings set org.gnome.desktop.peripherals.mouse accel-profile flat
gsettings set org.gnome.desktop.peripherals.touchpad click-method fingers
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

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
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from "19"
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to "7"
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3200
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

# Configuring terminal.
echo "Configuring the terminal..."
GNOME_TERMINAL_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}'`
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ cursor-shape "underline"
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-transparency false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-transparent-background true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ background-color "'rgb(5,5,5)'"
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ background-transparency-percent 5
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ scrollbar-policy "'always'"
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ default-size-columns 78
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ default-size-rows 24

# Thanks for downloading, and enjoy!
