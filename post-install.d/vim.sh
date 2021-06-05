# bash script to be sourced from popOS_setup.sh

# Install .vimrc
Separate 4
printf "Installing a \e[01m.vimrc\e[00m...\n"
cat "$script_location/samples/vimrc" | sudo tee /root/.vimrc /root/.vimrc-og | tee ~/.vimrc ~/.vimrc-og >/dev/null

read -rp "$(printf "Do you want to set \e[01mVim\e[00m as the default \e[35m\$EDITOR\e[00m? (Y/n) ")" DEF
read -rp "$(printf "Do you want to use \e[01mPowerline\e[00m in Vim? (Y/n) ")" PWL

# Set vim as the default EDITOR
if [ "${DEF,,}" = "y" -o -z "$DEF" ]; then
	set_default_editor() {
		printf "Setting \e[01mVim\e[00m as the default editor...\n"
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
	}
	set_default_editor &
fi

# Install powerline for vim
if [ "${PWL,,}" = "y" -o -z "$PWL" ]; then
	prepare_powerline() {
		printf "Installing \e[01mPowerline\e[00m for Vim...\n"
		sudo pip3 install powerline-status &>/dev/null && \
			printf "
if &term !=? 'linux'
	\" Powerline
	set rtp+=%s
	set laststatus=2
	set showtabline=1
	set noshowmode
	set t_Co=256
endif\n" "$(pip3 show powerline-status 2>/dev/null | grep Location | cut -d ' ' -f 2-)/powerline/bindings/vim" >>~/.vimrc
	}
	prepare_powerline &
fi

# Wait for subprocesses to be over, and unset vars and functions to avoid contamination
wait
unset DEF PWL set_default_editor prepare_powerline
