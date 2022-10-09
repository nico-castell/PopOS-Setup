# bash script to be sourced from popOS_setup.sh

# Copy .zshrc and offer to change default shell
Separate
printf "Successfully installed \e[36mzsh\e[00m, configuring...\n"

# Create .zshrc files
     [ ! -f ~/.zshrc         ] && cat "$script_location/samples/zshrc" | tee ~/.zshrc ~/.zshrc-og >/dev/null
sudo [ ! -f /root/.zshrc     ] && cat "$script_location/samples/zshrc" | sudo tee /root/.zshrc /root/.zshrc-og >/dev/null
sudo [ ! -f /etc/skel/.zshrc ] && cat "$script_location/samples/zshrc" | sudo tee /etc/skel/.zshrc >/dev/null

# Offer to install powerline-shell
read -rp "$(printf "Do you want to install \e[01mPowerline Shell\e[00m? (y/N) ")"
if [ ${REPLY,,} = "y" ]; then
	printf "Installing \e[01mPowerline Shell\e[00m...\n"
	sudo pip3 install powerline-shell &>/dev/null; O=$?
else
	O=1
fi

if [ $O -eq 0 ]; then
	mkdir -p ~/.config/powerline-shell
	sudo mkdir -p /root/.config/powerline-shell

	#region file
	FILE='{
	"segments": [
		"virtual_env",
		"username",
		"hostname",
		"ssh",
		"cwd",
		"git",
		"hg",
		"jobs",
		"root"
	],
	"cwd": {
		"max_depth": 3
	}
}'
	#endregion
	printf "%s\n" "$FILE" | sudo tee /root/.config/powerline-shell/config.json | tee ~/.config/powerline-shell/config.json >/dev/null
	unset FILE
fi

# Modify PATH for all users
cat <<EOF | sudo tee -a /etc/zsh/zshenv >/dev/null
# User specific environment
if ! [[ "\$PATH" =~ "\$HOME/.local/bin" ]]; then
	PATH="\$HOME/.local/bin:\$PATH"
fi
if ! [[ "\$PATH" =~ "\$HOME/bin" ]]; then
	PATH="\$HOME/bin:\$PATH"
fi
export PATH
EOF

printf "Choose the prompt style you prefer: \n"
select s in $(cat "$HOME/.zshrc" | grep "# Choose a prompt style between" | sed -e 's/\s*#.*: //'); do
	if [ $O -ne 0 ] && [ $s = "powerline" ]; then
		printf "Sorry, powerline was not installed, choose another style\n"
		continue
	fi
	sed -i "s/^	prompt_style=.*$/	prompt_style=$s/" ~/.zshrc
	sudo sed -i "s/^	prompt_style=.*$/	prompt_style=$s/" /root/.zshrc
	break
done

read -rp "Do you want to make `tput setaf 6`Z-Shell`tput sgr0` your default shell? (Y/n) "
if [[ ${REPLY,,} == "y" ]] || [ -z $REPLY ]; then
	sudo usermod -s $(which zsh) $USER
	sudo usermod -s $(which zsh) root

	sudo sed -i "s|SHELL=.*|SHELL=$(which zsh)|g" /etc/default/useradd
fi
