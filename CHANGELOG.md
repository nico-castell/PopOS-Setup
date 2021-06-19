# Change log
All significant changes to **PopOS Setup** will be documented here.

- [Released](#released)
  - [Version 2.0.0 - *2021-06-19*](#version-200---2021-06-19)
  - [Version 1.2.0 - *2021-06-11*](#version-120---2021-06-11)
  - [Version 1.1.0 - *2021-06-05*](#version-110---2021-06-05)
  - [Version 1.0.0 - *2021-05-28*](#version-100---2021-05-28)
  - [Version 0.2.2 - *2021-05-07*](#version-022---2021-05-07)
  - [Version 0.2.1 - *2021-04-26*](#version-021---2021-04-26)
  - [Version 0.2.0 - *2021-04-14*](#version-020---2021-04-14)
  - [Version 0.1.8 - *2021-04-14*](#version-018---2021-04-14)
  - [Version 0.1.7 - *2021-04-02*](#version-017---2021-04-02)
  - [Version 0.1.6 [YANKED] - *2021-04-01*](#version-016-yanked---2021-04-01)
  - [Version 0.1.5 - *2021-03-04*](#version-015---2021-03-04)
  - [Version 0.1.4 [YANKED] - *2021-02-24*](#version-014-yanked---2021-02-24)
  - [Version 0.1.3 - *2021-02-05*](#version-013---2021-02-05)
  - [Version 0.1.2 - *2021-01-31*](#version-012---2021-01-31)

## Released
### Version [2.0.0](https://github.com/nico-castell/PopOS-Setup/releases/tag/2.0.0) - *2021-06-19*
This version, while it doesn't bring much new. Reworked an important step of the main script, installing **apt repositories**, to be much more expandable than before, without requiring editing the main script to modify the step. However, some small features were added, such as:
- New packages in the installation list.
- Line highlighting in Vim
- A post-install script to set up the GNOME Sdk
#### Added
- [sources.d](sources.d):
  - This folder will contain sources to be added before installing packages.
- [packages.txt](packages.txt):
  - Added [Kitty Terminal](https://sw.kovidgoyal.net/kitty/), and [Visual Studio Code Insiders](https://code.visualstudio.com/insiders/) packages.
- [gnome-builder.sh](post-install.d/gnome-builder.sh):
  - Added the file, it gives the user a choice to install the **GNOME SDK** before they start using **GNOME Builder**.
- [flatpaks.txt](flatpaks.txt):
  - Added [Bitwarden](https://bitwarden.com/) flatpak to the list.
- [.zshrc](samples/zshrc):
  - Added support for Kitty terminal.
- [.vimrc](samples/vimrc):
  - Added line highlighting.
#### Changed
- [popOS_setup.sh](popOS_setup.sh):
  - Changed methodology for adding repositories. Now the [sources.d](sources.d) folder contains the sources in files named according to the package that needs the source.
- [.zshrc](samples/zshrc):
  - The **vscode prompt** can now be chosen by assigning the value `vscode` to the `prompt_style` variable.
  - Made **vscode prompt** trigger when `$VSCODE_GIT_IPC_HANDLE` is set, instead of `"$VSCODE_TERM" == "yes"`. This means the user won't have to manually set the variable from the vscode settings.
  - Now edits the `$PATH` more carefully.
#### Fixed
- [.vimrc](post-install.d/vim.sh):
  - Fixed root user not getting powerline set up after the user chooses to install it.
- [.zshrc](samples/zshrc):
  - Fixed prompt starting with error code 1 when `~/.zsh_aliases` is missing.

### Version [1.2.0](https://github.com/nico-castell/PopOS-Setup/releases/tag/1.2.0) - *2021-06-11*
This version contains a few improvements, a rewritten script, and fixes. The most significant additions were:
- Added **VS Codium** package.
- Added **Golang** with a post-install script that sets `$GOPATH` to `~/.local/golang`.
- Improved and faster **git info prompt**
- Rewrote the **duc_noip_install.sh** script.
#### Added
- [packages.txt](packages.txt):
  - Added [**VS Codium**](https://vscodium.com/) package.
  - Added [**Golang**](https://golang.org/) programming language, algng with a post install [script](post-install.d/golang.sh).
- [popOS_setup.sh](popOS_setup.sh):
  - Added **VS Codium** source.
- [.zshrc](samples/zshrc):
  - Added info about staged and untracked files to the git prompt.
  - Aliases and configs are now sourced from files under the `~/.zshrc.d` folder, as well as from a `~/.zsh_aliases` file.
- [.bashrc](samples/bashrc):
  - Brought some of the powerful git prompt to this file.
- [back_me_up.sh](back_me_up.sh):
  - The script now also looks for `~/.zshrc.d`, `~/.bashrc.d`, and `~/.bash_aliases`.
#### Changed
- [duc_noip_install.sh](scripts/duc_noip_install.sh):
  - Rewrote the script to be much more reliable and simple to edit.
- [popOS_setup.sh](popOS_setup.sh):
  - The extra scripts are now loaded and executed through loops, this is much more expandable (and reliable) than loading them individually.
- [vim.sh](post-install.d/vim.sh):
  - Switched from user installation of powerline-status to sytem installation.
- [zsh.sh](post-install.d/zsh.sh):
  - Switched from user installation of powerline-shell to sytem installation.
- [.zshrc](samples/zshrc):
  - Improved performance of the git info in the prompt.
#### Fixed
- [vim.sh](post-install.d/vim.sh):
  - Fixed excessive arguments.
- [zsh.sh](post-install.d/zsh.sh):
  - Fixed missing space when prompting the user.
- [git.sh](post-install.d/git.sh):
  - Fixed faulty config for the vim editor.
#### Deprecated
- [.zshrc](samples/zshrc):
  - This file will continue sourcing the `~/.zsh_aliases` file, but it will be fully replaced by `~/.zshrc.d` in an upcoming release. Because of this, the `~/.zsh_aliases` file will no longer be automatically created.

### Version [1.1.0](https://github.com/nico-castell/PopOS-Setup/releases/tag/1.1.0) - *2021-06-05*
This update is mostly a cumulative release of minor additions. The biggest introductions are the choice to use the powerline plugin in **Vim**, better prompts for the **Z-Shell**, and a few changes and fixes.
#### Added
- [.vimrc](samples/vimrc):
  - Added variable fg color for the vim statusline: red if you're root, white if you're not.
- [vim.sh](post-install.d/vim.sh):
  - Added the posibility to set vim as the default `$EDITOR`.
  - Added the posibility of installing the powerline-status plugin for the editor.
- [.zshrc](samples/zshrc):
  - Added gear (`⚙`) for fedora and ubuntu sytle prompts to show there are background jobs running.
  - Ubuntu style prompt (default) now has path shortening when deep in a directory structure.
- [git.sh](post-install.d/git.sh):
  - Added `now-ignored` alias to find files that should be untracked after updating a `.gitignore`.
#### Changed
- [.zshrc](samples/zshrc):
  - Kali style prompt now has softer edges: `╭──` instead of `┌──`.
- [zsh.sh](post-install.d/zsh.sh):
  - The script will no longer attempt to install powerline automatically, instead, it will ask the user if they want to install it.
- [git.sh](post-install.d/git.sh):
  - Changed `flog` and `sflog` aliases. You can specify a path to the `unstage` alias now.
#### Fixed
- [.vimrc](samples/vimrc):
  - Fixed the statusline showing current line instead of total lines after the `/`.
- [back_me_up.sh](back_me_up.sh):
  - Fixed trying to keep less than 1 backup.

### Version [1.0.0](https://github.com/nico-castell/PopOS-Setup/releases/tag/1.0.0) - *2021-05-28*
Some time before this release, the [Fedora Setup](https://githbub.com/nico-castell/Fedora-Setup) project started by reworking this project to work in Fedora. There were a lot of innovations. This release focuses on porting them back. Some of the most notable innovations have been:
- The creation of the [packages.txt](packages.txt) file.
- The creation of the [post-install.d](post-install.d) folder, which stores *.sh* files that are sourced by the main script.
- And many improvements to the codebase that make expanding and modifying functionality easier.
#### Added
- [popOS_setup.sh](popOS_setup.sh)
  - The script now gives a welcome message when started.
- [packages.txt](packages.txt):
  - This file contains the list of packages and dependencies that the [popOS_setup.sh](popOS_setup.sh) script installs. By putting this list in a file, adding and removing packages becomes very easy.
- [post-install.d](post-install.d):
  - This new folder contains shell scripts that should be sourced from [popOS_setup.sh](popOS_setup.sh), they contain the post-installation instructions previously found **in** the main script.
- [scripts](scripts):
  - The scritps folder contains a few scripts that can be run without being sourced by [popOS_setup.sh](popOS_setup.sh). These scripts were previously in the root of the repository.
- [update_recovery.sh](scripts/update_recovery.sh):
  - The functionality to update the recovery partition was moved from the main script to this external script.
- [.zshrc](samples/zshrc):
  - Introduced "prompt styles", so the user can choose a prompt style from the templates when the main script is sourcing the [zsh.sh](post-install.d/zsh.sh) script.
  - Now the paths `~/.local/bin` and `~/bin` are added to the $PATH environment variable.
  - A few other small changes.
- [.vimrc](samples/vimrc):
  - The file now creates a `~/.vimdata` folder to store all the temporary files used by vim.
  - The file lightly customizes some of the coloring and style of the vim editor.
#### Changed
- [popOS_setup.sh](popOS_setup.sh):
  - The main script (pop_OS_start.sh) was renamed to be like the name of the project.
  - There were innumerable changes to how the script works, but the user experience remains very familiar.
- [duc_noip_install.sh](scripts/duc_noip_install.sh):
  - The script now writes its files in `~/.local/bin` and `~/.local/share/applications`.
#### Removed
- [popOS_setup.sh](popOS_setup.sh):
  - The script no longer restarts the computer, making the code simpler.
  - The script no longer copies the *deskcuts*.
  - The script no longer supports installing downloaded packages in the `~/Downloads` folder.
- [deskcuts](deskcuts):
  - Removed a few redundant deskcuts.
- [mc_server_builder.sh](scripts/mc_server_builder.sh):
  - The script no longer executes the command `sudo update-desktop-database`.
- **vscode.sh**:
  - The script was removed as it is no longer necessary.
- **Fonts** folder:
  - The fonts folder was removed.

### Version [0.2.2](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.2.1) - *2021-05-07*
#### Added
- [.zshrc](samples/zshrc)
  - `new` function to create a directory and cd into it.
- [vscode.sh](vscode.sh)
  - Added git alias `sflog` to show output like `flog` and check gpg signatures for each commit.

#### Changed
- [.zshrc](samples/zshrc)
  - Improved gpg filter from history.
  - Improved comment with instructions to use powerline prompt.
- [gnome_appearance.sh](gnome_appearance.sh)
  - Changed terminal transparency to be less transparent as it makes it difficult to read.

#### Fixed
- [gnome_appearance.sh](gnome_appearance.sh)
  - Fixed uncommented comment.

### Version [0.2.1](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.2.1) - *2021-04-26*
#### Added
- [pop_OS_start.sh](pop_OS_start.sh)
  - Added installation and configuration of `tlp` (improves power efficiency on battery) package for laptops.
  - Added suspend when closing the lid for laptops.
  - When installing `zsh` make it roots default shell too.
- [mc_server_builder.sh](mc_server_builder.sh)
  - Now updates the desktop database after installation and deletion.

#### Changed
- [.zshrc](samples/zshrc)
  - Changed ls aliases.
  - Changed `erase-history` function for a filter where the user can specify commands that should not be stored in history.

#### Fixed
- [mc_server_builder.sh](mc_server_builder.sh)
  - Fixed colored prompts (the user can now type delete without deleting the prompt).
  - Fixed inconsistent new-line behaviour when configuring the server.properties.
- [pop_OS_start.sh](pop_OS_start.sh)
  - Fixed colored prompts (the user can now type delete without deleting the prompt).
- [vscode.sh](vscode.sh)
  - Fixed colored prompts (the user can now type delete without deleting the prompt).
  - Fixed git recursive alias `slog`.

### Version [0.2.0](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.2.0) - *2021-04-14*
#### Changed
- [pop_OS_start.sh](pop_OS_start.sh):
  - DETACHED VSCODE SETUP FROM THE SCRIPT:
    - Deleted post-installation instructions for the `code` package.
    - Created [vscode.sh](vscode.sh) to fulfill that role.
    - [pop_OS_start.sh](pop_OS_start.sh) now sources [vscode.sh](vscode.sh)

#### Fixed
- [pop_OS_start.sh](pop_OS_start.sh):
  - Fixed [.vimrc](samples/vimrc) sample file not being found.
  - Create .tmp directories for user and root so vim can use them to keep *.swp* files.
  - Fixed "missing [" when ensuring all packages are up to date.
- [gnome_appearance.sh](gnome_appearance.sh):
  - Fixed configuring favorite-apps.

### Version [0.1.8](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.1.8) - *2021-04-14*
#### Added
- [.vimrc](samples/vimrc):
  - Set up a statusline
  - Set tabsize to 3

#### Changed
- [pop_OS_start](pop_OS_start.sh)
  - Simplified copying deskcuts.

#### Fixed
- [pop_OS_start](pop_OS_start.sh):
  - Fixed colored prompt when confirming packages.
  - Fixed appending to powerline config file when it should be rewritten.
  - Fixed missing ANSI escape after SSH setup.
  - Fixed ~/.vimrc and ~/.config/powerline-shell/config.json owned by root.
  - Fixed not creating ~/.zsh_aliases before writing an alias there.
  - Clear stdin before users pastes the GPG key to use as git signingkey.

### Version [0.1.7](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.1.7) - *2021-04-02*
#### Added
- Added [.editorconfig](.editorconfig) for previewing files on GitHub.

#### Changed
- [mc_server_builder](mc_server_builder.sh) now prompts the user to agree to the EULA.
- [pop_OS_start](pop_OS_start.sh) now installs *apt-transport-https* before installing https repositories.

#### Fixed
- Fixed the prompt when [mc_server_builder](mc_server_builder.sh) asked the user for some configurations.
- Fixed calling [duc_noip_install](duc_noip_install.sh) from the [pop_OS_start](pop_OS_start.sh) script.
- Fixed new-lines in APT preferences for *google-chrome-stable* and *code*. ([pop_OS_start](pop_OS_start.sh))
- Returned old setup for the vscode repository, the new one was failing to install the gpg signing key.
- Fixed bad completion of the script's repository when installing deskcuts. ([pop_OS_start](pop_OS_start.sh))
- Fixed detection of upgrades to the kernel and rebooting after the upgrade. ([pop_OS_start](pop_OS_start.sh))

### Version [0.1.6](https://github.com/nico-castell/PopOS-Setup/tree/0.1.6) [YANKED] - *2021-04-01*
#### Added
- Added more packages for the user to select in [pop_OS_start](pop_OS_start.sh).
- The [.zshrc](samples/zshrc) file now binds `ctrl+del` to delete a whole word.

#### Changed
- Minor improvements to [back_me_up](back_me_up.sh).
- Some improvements to the look of the code for writing files in [duc_noip_install](duc_noip_install.sh) and [pop_OS_start](pop_OS_start.sh).
- Updated the setup for the vscode repository. ([pop_OS_start](pop_OS_start.sh))

#### Fixed
- Fixed APT's preconfigured preference to install and update **google-chrome-stable** and **code** from Pop!_OS' PPA instead of the respective package's official repository. ([pop_OS_start](pop_OS_start.sh))
- Minor fixes in [mc_server_builder](mc_server_builder.sh).

### Version [0.1.5](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.1.5) - *2021-03-04*
#### Added
- Git aliases in vscode setup ([pop_OS_start](pop_OS_start.sh))
- Choice of git core editor in vscode setup ([pop_OS_start](pop_OS_start.sh))

#### Changed
- General improvements and fixes in [mc_server_builder](mc_server_builder.sh).
- Favorite apps in [gnome_settings](gnome_settings.sh).
- Now using tabs to indent.

#### Fixed
- Excel browser [shortcut](deskcuts/browser-msexcel.desktop).
- Java JDK installation in [pop_OS_start](pop_OS_start.sh).
- Git ppa repository reporting fail after success [pop_OS_start](pop_OS_start.sh).
- Fixed bugs in [gnome_appearance](gnome_appearance.sh).

### Version [0.1.4](https://github.com/nico-castell/PopOS-Setup/tree/0.1.4) [YANKED] - *2021-02-24*
#### Added
- [back_me_up](back_me_up.sh)
	- Backup .clang-format from home
- [mc_server_builder](mc_server_builder.sh)
	- Adds a compress.sh script to archive the server.

#### Changed
- [mc_server_builder](mc_server_builder.sh)
	- The script was rewritten
	- Improved run.sh
	- No longer has to download server icon, it just coppies it from the [assets](assets) folder
- [pop_OS_start](pop_OS_start.sh)
	- The web browser [deskcuts](deskcuts) were standarized by using `xdg-open`.

### Version [0.1.3](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.1.3) - *2021-02-05*
#### Changed
* Major changes in all comments.
* Some `tput setaf` commands were changed for ANSI escape codes.

#### Fixed
[back_me_up](back_me_up.sh): No longer errors when not running from ~.

### Version [0.1.2](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.1.2) - *2021-01-31*
#### Changed
Now the project is hosted on a new repository.

#### Deprecated
The old repository is deprecated and will be removed within the next 14 days. ***The repository was deleted on the 25th February, 2021.***

**Reason:** I made a mistake and rewrote the entire git history. This new repository was created from a backup of the project.
