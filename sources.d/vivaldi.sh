# bash script to be sourced from popOS_setup.sh

URL="https://updates.signal.org/desktop/apt"
KEY="https://repo.vivaldi.com/archive/linux_signing_key.pub"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mVivaldi\e[00m source...\n"

	# Configure the repository
	wget -qO - "$KEY" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg/vivaldi.gpg &>/dev/null
	printf "deb [signed-by=/etc/apt/trusted.gpg/vivaldi.gpg arch=amd64] %s stable main\n" "$URL" | \
		sudo tee /etc/apt/sources.list.d/vivaldi.list &>/dev/null

	# List it as already configured
	REPOS_CONFIGURED+=("$URL")
fi
