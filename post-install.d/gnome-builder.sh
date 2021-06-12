# bash script to be sourced from popOS_setup.sh

Separate 4
printf "Successfully installed \e[36mGNOME Builder\e[00m\n"

# Install the GNOME SDK for GNOME Builder
read -rp "$(printf "Do you want to install the \e[01mGNOME SDK\e[00m from Flathub now? (y/N)
It weighs about 1 GiB with its dependencies
Your answer (default is: N): ")"
if [ "${REPLY,,}" = "y" ]; then
	printf "Installing...\n"
	flatpak install --user -y flathub org.gnome.Sdk/$(lscpu | grep "^Architecture" | awk '{print $2}')/$(gnome-shell --version | grep -oP '\d{2}\.\d' | sed -e 's/\..*//')
fi
