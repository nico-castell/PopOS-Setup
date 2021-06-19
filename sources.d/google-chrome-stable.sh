# bash script to be sourced from popOS_setup.sh

# FOR SOME REASON THEY DON'T PROVIDE A URL, SO THE KEY
# IS INSTEAD USED AS THE IDEMPOTENCY TOKEN FOR THIS
# GOOGLE REPOSITORY
URL="https://dl.google.com/linux/linux_signing_key.pub"
KEY="https://dl.google.com/linux/linux_signing_key.pub"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mGoogle Chrome\e[00m source...\n"

	# Configure the repository
	wget -qO - "$KEY" | sudo apt-key add - &>/dev/null

# Configure apt to prefer this repo to Pop's PPA
printf "# Prefer Google Chrome from the google repository
Package: google-chrome-stable
Pin: origin dl.google.com
Pin-Priority: 1002\n" | sudo tee /etc/apt/preferences.d/google-chrome-settings >/dev/null

	# List it as already configured
	REPOS_CONFIGURED+=("$URL")
fi
