# bash script to be sourced from popOS_setup.sh

URL="https://brave-browser-apt-release.s3.brave.com/"
KEY="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mBrave Browser\e[00m source...\n"

	# Configure the repository
	wget -qO - "$KEY" | sudo tee /usr/share/keyrings/brave-browser-archive-keyring.gpg &>/dev/null
	printf "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] %s stable main\n" "$URL" | \
		sudo tee /etc/apt/sources.list.d/brave-browser-release.list &>/dev/null

	# List it as already configured
	REPOS_CONFIGURED+=("$URL")
fi
