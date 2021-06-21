# bash script to be sourced from popOS_setup.sh

# Set up Git
Separate 4
printf "Successfully installed \e[36mGit\e[00m, configuring...\n"

# User configurations
read -p "What's your commit name? " USERNAME
git config --global user.name "$USERNAME"
read -p "What's your commit email? " EMAIL
git config --global user.email "$EMAIL"
read -p "What do you want to call the default branch? " BRANCH
[ ! -z $BRANCH ] && git config --global init.defaultBranch "$BRANCH"
unset USERNAME EMAIL BRANCH

# Choose a commit editor
printf "Please, select your preferred editor for working with Git:\n"
which code          &>/dev/null && GIT_EDITORS+=("vscode")
which code-insiders &>/dev/null && GIT_EDITORS+=("vscode-insiders")
which vim           &>/dev/null && GIT_EDITORS+=("vim")
whivh nvim          &>/dev/null && GIT_EDITORS+=("nvim")
which nano          &>/dev/null && GIT_EDITORS+=("nano")
which gedit         &>/dev/null && GIT_EDITORS+=("gedit")
select GIT_EDITOR in ${GIT_EDITORS[@]}; do
case $GIT_EDITOR in
	vscode) # Set up Visual Studio Code
	git config --global core.editor "code --wait"
	git config --global merge.tool vscode
	git config --global mergetool.vscode.cmd 'code --wait "$MERGED"'
	git config --global diff.tool vscode
	git config --global difftool.vscode.cmd 'code --wait --diff "$LOCAL" "$REMOTE"'
	;;
	code-insiders) # Set up Visual Studio Code Insiders
	git config --global core.editor "code-insiders --wait"
	git config --global merge.tool vscode-insiders
	git config --global mergetool.vscode-insiders.cmd 'code-insiders --wait "$MERGED"'
	git config --global diff.tool vscode-insiders
	git config --global difftool.vscode-insiders.cmd 'code-insiders --wait --diff "$LOCAL" "$REMOTE"'
	;;
	vim) # Set up Vim
	git config --global core.editor "vim -n -c 'set noundofile' -c 'set nobackup'"
	git config --global merge.tool vim
	git config --global mergetool.keepBackup false
	git config --global mergetool.nvim.cmd 'vim -d "$LOCAL" "$REMOTE" "$MERGED" -c "exe 2 .\"wincmd l\""'
	git config --global diff.tool vim
	git config --global difftool.vim.cmd 'vim -d "$LOCAL" "$REMOTE" -c "wincmd l"'
	;;
	nvim) # Set up Neovim
	git config --global core.editor "nvim -n -c 'set noundofile' -c 'set nobackup'"
	git config --global merge.tool nvim
	git config --global mergetool.keepBackup false
	git config --global mergetool.nvim.cmd 'nvim -d "$LOCAL" "$REMOTE" "$MERGED" -c "exe 2 .\"wincmd l\""'
	git config --global diff.tool nvim
	git config --global difftool.nvim.cmd 'nvim -d "$LOCAL" "$REMOTE" -c "wincmd l"'
	;;
	nano)   git config --global core.editor "nano"                ;;
	gedit)  git config --global core.editor "gedit -s"            ;;
	*) printf "Option %s not recognized.\n" $GIT_EDITOR; continue ;;
esac; break; done
unset GIT_EDITOR GIT_EDITORS

# Configure gpg commit signing
if which gpg &>/dev/null; then
	read -rp "`tput setaf 6`gpg`tput sgr0` was found, do you want to use it to sign your commits? (Y/n) "
	if [ "${REPLY,,}" = "y" ] || [ -z $REPLY ]; then
		read -rp "Do you want to create a new gpg key before you choose a key to sign your commits? (Y/n) " MKGPG
		if [ "${MKGPG,,}" = "y" ] || [ -z $MKGPG ]; then
			gpg --full-generate-key
			printf "\n"
		fi

		printf "\e[01mChoose a key to sign your commits:\e[00m\n"
		gpg --list-secret-keys

		# Let the user choose a key and only configure git if they choose one
		read -rp "Input your key-id of choice: " GPGKEY
		[ -n "$GPGKEY" ] && \
		git config --global user.signingkey "$GPGKEY" && \
		git config --global commit.gpgsign true

		unset GPGKEY MKGPG
	fi
fi

# Configure git
printf "Configuring pull behaviour...\n"
git config --global pull.ff only
printf "Setting up some aliases...\n"
git config --global alias.mrc '!git merge $1 && git commit -m "$2" --allow-empty && :'
git config --global alias.flog "log --all --graph --oneline --format=format:'%C(bold yellow)%h%C(r) %an: %C(bold)%s%C(r) %C(auto)%d%C(r)'"
git config --global alias.sflog "log --all --graph --oneline --format=format:'%C(bold yellow)%h%C(r) %C(bold green)%G?%C(r) %an: %C(bold)%s%C(r) %C(auto)%d%C(r)'"
git config --global alias.eflog "log --all --graph --oneline --format=format:'%C(bold yellow)%h%C(r) %ae: %C(bold)%s%C(r) %C(auto)%d%C(r)'"
git config --global alias.slog 'log --show-signature -1'
git config --global alias.mkst 'stash push -u'
git config --global alias.popst 'stash pop "stash@{0}" -q'
git config --global alias.unstage 'reset -q HEAD --'
git config --global alias.now-ignored = 'ls-files -i --exclude-standard'
