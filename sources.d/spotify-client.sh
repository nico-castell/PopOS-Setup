# bash script to be sourced from popOS_setup.sh

URL="http://repository.spotify.com"
KEY="https://download.spotify.com/debian/pubkey_0D811D58.gpg"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mSpotify\e[00m source...\n"

	# Configure the repository
	wget -qO - "$KEY" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg/spotify-client.gpg &>/dev/null
	printf "deb [signed-by=/etc/apt/trusted.gpg/spotify-client.gpg arch=amd64] %s stable non-free\n" "$URL" | \
		sudo tee /etc/apt/sources.list.d/spotify.list &>/dev/null

	# List it as already configured
	REPOS_CONFIGURED+=("$URL")
fi
