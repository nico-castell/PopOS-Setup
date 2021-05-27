# bash script to be sourced from fedora_setup.sh

# Install .vimrc
Separate 4
printf "Installing a \e[01m.vimrc\e[00m...\n"
cat "$script_location/samples/vimrc" | sudo tee /root/.vimrc /root/.vimrc-og | tee ~/.vimrc ~/.vimrc-og >/dev/null

# Offer to make vim the default editor
read -rp "$(printf "Do you want to swap \e[01mnano\e[00m for \e[01mVim\e[00m as the default \e[35m\$EDITOR\e[00m? (Y/n) ")"
if [ ${REPLY,,} = "y" ] || [ -z $REPLY ]; then
	printf "Swapping...\n"
	sudo dnf swap nano-default-editor vim-default-editor -y --allowerasing >/dev/null
fi
