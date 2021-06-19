# bash script to be sourced from popOS_setup.sh

URL="https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01m.NET\e[00m source...\n"

	# Configure the repository
	wget -qO ~/.packages-microsoft-prod.deb "$URL" &>/dev/null
	sudo dpkg -i ~/.packages-microsoft-prod.deb    &>/dev/null
	rm .packages-microsoft-prod.deb                &>/dev/null

	# List it as already configured
	REPOS_CONFIGURED+=("$URL")
fi
