# bash script to be sourced from popOS_setup.sh

# Install a neovim init file
Separate 4
printf "Successfully installed \e[36mNeovim\e[00m, configuring...\n"

# Create config directories and name the file
LOCATION='.config/nvim'
mkdir -p "$HOME/$LOCATION"
sudo mkdir -p "/root/$LOCATION"
LOCATION="$LOCATION/init.vim"

cat "$script_location/samples/nvim.vim"                  | \
	sudo tee "/root/$LOCATION" "/root/$LOCATION-og"       | \
	tee "$HOME/$LOCATION" "$HOME/$LOCATION-og" >/dev/null

read -rp "$(printf "Do you want to set \e[01mneovim\e[00m as the default \e[35m\$EDITOR\e[00m? (Y/n) ")" SWP

# Set nvim as the default editor
if [ "${SWP,,}" = "y" -o -z "$SWP" ]; then
	printf "Setting \e[01mNeovim\e[00m as the new default editor...\n"
	sudo mkdir -p /etc/profile.d
	sudo rm /etc/profile.d/vim-default-editor*sh 2>/dev/null

# .sh file
printf "# Ensure nvim is set as EDITOR if it isn't already set

if [ -z \"\$EDITOR\" ]; then
	export EDITOR=\"%s\"
fi\n" $(which nvim) | sudo tee /etc/profile.d/nvim-default-editor.sh >/dev/null

# .csh file
printf "# Ensure nvim is set as EDITOR if it isn't already set

if ( ! (\$?EDITOR) ) then
	setenv EDITOR \"%s\"
fi\n" $(which nvim) | sudo tee /etc/profile.d/nvim-default-editor.csh >/dev/null

fi

# If vim was also installed, write some code so the user can check the editor
# they're running
which vim &>/dev/null && printf "
\" Simple check to see if you're in nvim or vim
function! Checkeditor()
	if has('nvim') | echo 'nvim' | else | echo 'vim' | endif
endfunction
command! Checkeditor call Checkeditor()\n" | \
	sudo tee -a "/root/$LOCATION"           | \
	tee -a "$HOME/$LOCATION" >/dev/null

unset SWP LOCATION
