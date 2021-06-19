# bash script to be sourced from popOS_setup.sh

URL="https://updates.signal.org/desktop/apt"
KEY="https://updates.signal.org/desktop/apt/keys.asc"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mSignal Desktop\e[00m source...\n"

	# Configure the repository
	wget -qO - "$KEY" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg/signal-desktop.gpg &>/dev/null
	printf "deb [signed-by=/etc/apt/trusted.gpg/signal-desktop.gpg arch=amd64] %s xenial main\n" "$URL" | \
		sudo tee /etc/apt/sources.list.d/signal-xenial.list &>/dev/null

	# List it as already configured
	REPOS_CONFIGURED+=("$URL")
fi
