# bash script to be sourced from popOS_setup.sh

# Offer to install tools to develop vscode extensions
if which code &>/dev/null && which code npm &>/dev/null; then
	Separate 4
	read -rp "Do you want to install tools to develop extensions for `tput setaf 6`Visual Studio Code`tput sgr0`? (Y/n) "
	if [[ ${REPLY,,} == "y" ]] || [ -z $REPLY ]; then
		printf "Installing...\n"
		sudo npm install -g yo generator-code vsce >/dev/null
	fi
fi
