# bash script to be sourced from popOS_setup.sh

# Install .vimrc
Separate 4
printf "Installing a \e[01m.vimrc\e[00m...\n"
cat "$script_location/samples/vimrc" | sudo tee /root/.vimrc /root/.vimrc-og | tee ~/.vimrc ~/.vimrc-og >/dev/null

# Offer to make vim the default editor
read -rp "$(printf "Do you want to set \e[01mVim\e[00m as the default \e[35m\$EDITOR\e[00m? (Y/n) ")"
if [ ${REPLY,,} = "y" ] || [ -z $REPLY ]; then
	printf "Setting...\n"
	sudo mkdir -p /etc/profile.d

	# .sh file
	printf "# Ensure vim is set as EDITOR if it isn't already set

if [ -z \"\$EDITOR\" ]; then
	export EDITOR=\"%s\"
fi\n" $(which vim) | sudo tee /etc/profile.d/vim-default-editor.sh >/dev/null

	# .csh file
	printf "Ensure vim is set as EDITOR if it isn't already set

if ( ! (\$?EDITOR) ) then
	setenv EDITOR \"%s\"
endif\n" $(which vim) | sudo tee /etc/profile.d/vim-default-editor.csh >/dev/null
fi
