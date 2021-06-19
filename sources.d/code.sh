# bash script to be sourced from popOS_setup.sh

URL="https://packages.microsoft.com/repos/code"
KEY="https://packages.microsoft.com/keys/microsoft.asc"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mVisual Studio Code\e[00m source...\n"

	# Configure the repository
	wget -qO - "$KEY" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/packages.microsoft.gpg &>/dev/null
	printf "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] %s stable main\n" "$URL" | \
		sudo tee /etc/apt/sources.list.d/vscode.list &>/dev/null

# Configure apt to prefer this repo to Pop's PPA
printf "# Prefer vscode from the microsoft repo
Package: code
Pin: origin packages.microsoft.com
Pin-Priority: 1002\n" | sudo tee /etc/apt/preferences.d/vscode-settings >/dev/null

	# List it as already configured
	REPOS_CONFIGURED+=("$URL")
fi
