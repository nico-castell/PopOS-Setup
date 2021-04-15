# Script to set up vscode

# WARNING: This script must be executed by running:
#    source "$script_location/vscode.sh"
# from pop_OS_start.sh because it depends on variables declared in
# pop_OS_start.sh

Separate 4
echo -e "\e[36mVisual Studio Code\e[00m was successfully installed,"
echo "Choose some developer tools to prepare:"

LIST+=("Git")
LIST+=("GPG - User assisted")
LIST+=("C++ Tools")
LIST+=(".NET Core 3.1")
LIST+=("Java JDK")
LIST+=("SSH")
LIST+=("VS Code Extension development")

select c in "${LIST[@]}" exit; do
case $c in
	Git)
	echo "Adding git ppa repository..."
	Animate & PID=$!
	sudo apt-add-repository -y ppa:git-core/ppa >/dev/null
	O=$?; kill $PID
	if [ $O -eq 0 ]; then
		echo -e "\e[32mSuccess\e[00m"
	else
		echo -e "\e[31mFailed to add repository\e[00m"
	fi

	# Configure user to make commits.
	echo "Configure git:"
	read -p "What's your GitHub username? " USERNAME
	git config --global user.name "$USERNAME"
	read -p "What's your GitHub email? " EMAIL
	git config --global user.email "$EMAIL"

	read -p "What do you want to call the default branch? " DEF_BRANCH
	if [ ! -z $DEF_BRANCH ]; then
		git config --global init.defaultBranch "$DEF_BRANCH"
	fi
	unset USERNAME EMAIL DEF_BRANCH

	# Integrave vscode in some common Git operations.
	printf "Please, select a default editor for \e[36mcommit messages\e[00m:\n"
	GIT_EDITORS+=("vscode")
	GIT_EDITORS+=("vim")
	GIT_EDITORS+=("nano")
	GIT_EDITORS+=("gedit")
	select GIT_EDITOR in ${GIT_EDITORS[@]}; do
	case $GIT_EDITOR in
		vim)    git config --global core.editor vim            ;;
		vscode) git config --global core.editor 'code --wait'  ;;
		nano)   git config --global core.editor nano           ;;
		gedit)  git config --global core.editor 'gedit -s'     ;;
		*) echo "Option $GIT_EDITOR not recognized."; continue ;;
	esac; break; done
	unset GIT_EDITOR GIT_EDITORS

	printf "Setting \e[01mVS Code\e[00m as the default merge tool...\n"
	git config --global merge.tool vscode
	git config --global mergetool.vscode.cmd 'code --wait $MERGED'
	git config --global diff.tool vscode
	git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

	echo "Configuring pull behaviour..."
	git config --global pull.rebase false
	git config --global pull.ff only

	# Set up aliases
	printf "Setting up some Git aliases...\n"
	git config --global alias.mrc '!git merge $1 && git commit -m "$2" --allow-empty && :'
	git config --global alias.flog "log --all --graph --oneline --format=format:'%C(bold white)%h%C(r) -- %C(blue)%an (%ar)%C(r): %s %C(auto)%d%C(r)'"
	git config --global alias.slog 'slog --show-signature -1'
	git config --global alias.fflog 'log --graph'
	git config --global alias.mkst 'stash push -u'
	git config --global alias.popst 'stash pop "stash@{0}" -q'
	git config --global alias.unstage 'reset -q HEAD -- .'

	echo
	;;

	"GPG - User assisted")
	printf "Setting up \e[36mGPG\e[00m...\n"
	printf "\e[33mPlease follow the steps:\e[00m\n"
	gpg --full-generate-key
	printf "\e[33mListing keys:\e[00m\n"
	gpg --list-secret-keys --keyid-format long
	while read -e -t 0.1; do : ; done; unset REPLY # Clear input buffer
	read -p "`tput setaf 3`Please copy the key and paste it here: `tput sgr0`" KEY
	printf "\e[33mConfiguring \e[01mgit\e[00;33m to automatically \e[01msign\e[00;33m all your commits...\e[00m\n"
	git config --global user.signingkey "$KEY"
	git config --global commit.gpgsign yes
	printf "\e[33mDo you want to print the public signature to add it to your \e[01mGitHub\e[00;33m? (Y/n) \e[00m"
	read
	if [[ ${REPLY,,} == "y" ]] || [[ -z $REPLY ]]; then
		gpg --armor --export "$KEY"
	fi
	unset KEY

	echo
	;;

	"C++ Tools")
	echo -e "Installing \e[36mgdb\e[00m and \e[36mclang-format\e[00m.."
	Animate & PID=$!
	sudo apt-get install gdb clang-format -y >/dev/null
	O=$?; kill $PID
	if [ $O -eq 0 ]; then
		echo -e "\e[32mSuccess\e[00m"
	else
		echo -e "\e[31mInstallation failed\e[00m"
	fi
	echo
	;;

	".NET Core 3.1")
	echo "Adding microsoft repository..."
	Animate & PID=$!
	wget -q https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb -O .packages-microsoft-prod.deb &>/dev/null
	sudo dpkg -i .packages-microsoft-prod.deb &>/dev/null
	rm .packages-microsoft-prod.deb &>/dev/null
	kill $PID
	echo "Done"

	echo "Updating repositories..."
	Animate & PID=$!
	sudo apt-get update &>/dev/null
	O=$?; kill $PID
	if [ $O -eq 0 ]; then
		echo -e "\e[32mSuccess\e[00m"
	else
		echo -e "\e[31mUpdate failed\e[00m"
	fi

	echo "Installing $c..."
	Animate & PID=$!
	sudo apt-get install apt-transport-https dotnet-sdk-3.1 aspnetcore-runtime-3.1 -y >/dev/null
	O=$?
	kill $PID
	if [ $O -eq 0 ]; then
		echo -e "\e[32mSuccess\e[00m"
	else
		echo -e "\e[31mInstallation failed\e[00m"
	fi
	echo
	;;

	"Java JDK")
	echo "Installing JDK..."
	Animate & PID=$!
	sudo apt-get install default-jdk -y >/dev/null
	O=$?; kill $PID
	if [ $O -eq 0  ]; then
		echo -e "\e[32mSuccess\e[00m"
	else
		echo -e "\e[31mInstallation failed\e[00m"
	fi
	echo
	;;

	SSH)
	echo "Set up an SSH key pair to use with GitHub"
	read -p "Input a password: " -s PASS; echo # echo to fix read -s not printing a new line.

	KEY="$HOME/.ssh/id_GitHub-Key_main"
	ssh-keygen -t rsa -b 4096 -C "GitHub-Key" -N "$PASS" -f "$KEY"
	unset PASS

	read -p "`tput setaf 3`Do you want to print the public key to copy to copy to your $(printf '\e[01m')GitHub$(printf '\e[00;33m') account?`tput sgr0` (Y/n) "
	if [[ "${REPLY,,}" == "y" ]] || [ -z "$REPLY" ]; then
		cat "$KEY"
	fi

	unset KEY

	sleep 1.5
	echo
	;;

	"VS Code Extension development")
	echo "Installing Node.js 15..."
	Animate & PID=$!
	curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash - >/dev/null
	sudo apt-get install -y nodejs >/dev/null
	kill $PID

	echo "Installing VS Code extension generator..."
	Animate & PID=$!
	sudo npm install -g yo generator-code vsce >/dev/null
	kill $PID
	echo
	;;

	exit) break ;;
	*) echo "Option $c not recognized." ;;
esac
done
unset LIST
