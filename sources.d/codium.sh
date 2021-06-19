# bash script to be sourced from popOS_setup.sh

URL="https://paulcarroty.gitlab.io/vscode-deb-rpm-repo/debs/"
KEY="https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mVS Codium\e[00m source...\n"

	# Configure the repository
	wget -qO - "$KEY" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/vscodium.gpg &>/dev/null
	printf "deb [signed-by=/etc/apt/trusted.gpg.d/vscodium.gpg arch=amd64] %s vscodium main\n" "$URL" | \
		sudo tee /etc/apt/sources.list.d/vscodium.list &>/dev/null

	# List it as already configured
	REPOS_CONFIGURED+=("$URL")
fi
