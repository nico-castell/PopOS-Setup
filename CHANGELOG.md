# Change log
All significant changes to **PopOS Setup** will be documented here.

- [Unreleased](#unreleased)
	- [Added](#added)
	- [Changed](#changed)
	- [Removed](#removed)
- [Released](#released)
	- [Version 2.4.0 - *2021-11-21*](#version-240---2021-11-21)
	- [Version 2.3.0 - *2021-10-17*](#version-230---2021-10-17)
	- [Version 2.2.1 - *2021-10-15*](#version-221---2021-10-15)
	- [Version 2.2.0 - *2021-10-11*](#version-220---2021-10-11)
	- [Version 2.1.0 - *2021-07-15*](#version-210---2021-07-15)
	- [Version 2.0.0 - *2021-06-19*](#version-200---2021-06-19)
	- [Version 1.2.0 - *2021-06-11*](#version-120---2021-06-11)
	- [Version 1.1.0 - *2021-06-05*](#version-110---2021-06-05)
	- [Version 1.0.0 - *2021-05-28*](#version-100---2021-05-28)
	- [Version 0.2.2 - *2021-05-07*](#version-022---2021-05-07)

## Unreleased
### Added
- [popOS_setup.sh](popOS_setup.sh):
	- Given that now some post-install.d processes use parallelization to run things in the
		background and work faster, a `wait` command was implemented in the final clean-up step so
		users don't close the shell while things are still running.
### Changed
- [popOS_setup.sh](popOS_setup.sh):
	- There `Separate` function was optimized.
- [post-install.d](post-install.d):
	- Some files now use child subshells that run in parallel `( .. ) &` to speed things up by
		running things in the background.
- [git.sh](post-install.d/git.sh):
	- Tweaked the git slog alias so it does not specify the number of commits to show, allowing the
	  user to specify it instead.
	- The `now-ignored` alias was renamed to `list-ignored` because the keyword list better explains
	  what the alias does.
### Removed
- [git.sh](post-install.d/git.sh):
	- The alias `mrc` was removed because it is only useful in very rare situations.

## Released
### Version [2.4.0](https://github.com/nico-castell/PopOS-Setup/releases/tag/2.4.0) - *2021-11-21*
This release comes after 16 commits, though the changes are extensive. These were the most important
changes:
- Fixing bugs
- Improving (slightly) code maintainabilty
- Correcting outdated comments
- **Categorizing the apt packages** so the user can now choose to skip an entire software category
	when selecting packages to install
#### Added
- [init.vim](samples/nvim.vim):
	- The file type *limits* was added to use tabs with a length of 8.
- [vimrc](samples/vimrc):
	- The file type *limits* was added to use tabs with a length of 8.
- [remove.txt](remove.txt):
	- *Document Scanner* was added to the list.
- [back_me_up.sh](back_me_up.sh):
	- Added a notification to signal when the backup is finished.
	- The script now also backs up the `~/.gitconfig` file.
#### Changed
- [popOS_setup.sh](popOS_setup.sh):
	- The mecanism to process the *packages.txt* file was changed for something that allows the user
		to skip entire categories of software.
	- The loops that process *remove.txt*, *packages.txt*, and *flatpaks.txt* now use a file in
		memory for performance optimizations, this file is protected by unique names, chmod and umask.
- [packages.txt](packages.txt):
	- The format of the file was changed:
		1. Lines that are not indented represent categories
		2. Indented lines represent apps
		3. Indented lines belong to the category above them
		4. Indented lines must use a hard tab for indentation
	- The packages **Firefox** and **Geary Mail** were added in their categories.
- [kdev.sh](samples/kdev.sh):
	- The config option no longer reads the `Makefile` if you don't specify a config name, instead,
		it reads `.config`.
- [.zshrc](samples/zshrc):
	- The code for the git prompt was changed to be much faster by using zsh's *vcs_info*. This means
		less functionality, but much less code to run every time the prompt needs to be renderes.
	- The shell can now detect when it is running inside GNOME Builder, and use the vscode prompt.
	- The `la` alias now groups folders first.
	- Made many other tweaks to improve code maintainability and speed.
- [.bashrc](samples/bashrc):
	- The `la` alias now groups folders first.
#### Fixed
- [kdev.sh](samples/kdev.sh):
	- Stop assuming the user's *cwd* when using `kdev config`.
	- Fixed `kdev config` failing to find the config type currently in use.
	- The `kdev clean` option on level 4 now also removes git untracked directories.
- [init.vim](samples/nvim.vim):
	- Fixed local settings that lingered when changing filetype from markdown, text, or limits to
	  anything else.
- [.vimrc](samples/vimrc):
	- Fixed local settings that lingered when changing filetype from markdown, text, or limits to
	  anything else.

### Version [2.3.0](https://github.com/nico-castell/PopOS-Setup/releases/tag/2.3.0) - *2021-10-17*
This is a small release made in parity with the
[Fedora Setup](https://github.com/nico-castell/Fedora-Setup) project to syncronize changes to this
date.
#### Added
- [remove.txt](remove.txt):
	- Added **Eddy** to the list.
#### Fixed
- [remove.txt](remove.txt):
	- Fixed *popsicle* package not removing *popsicle-gtk*

### Version [2.2.1](https://github.com/nico-castell/PopOS-Setup/releases/tag/2.2.1) - *2021-10-15*
This release completes the plan for 2.2.0 by adding support for installing **Virt Manager** (a type
1 hypervisor) and tools for kernel development. Additionally, many bugs were patched.
#### Added
- [packages.txt](packages.txt):
	- Added **Kernel development** to the list.
	- Added **Virt Manager** to the list.
	- Added **Trash CLI** to the list.
- [fakeroot.sh](post-install.d/fakeroot.sh):
	- This file is triggered by the selection of **Kernel development**, and helps to help the user
		set up some kernel development tools.
- [kdev.sh](samples/kdev.sh):
	- This file will be installed by [fakeroot.sh](post-install.d/fakeroot.sh) and it's role is to
		help the user manage config files and kernel installations and uninstallations.
- [virt-manager.sh](post-install.d/virt-manager.sh):
	- This file configures libvirt to allow the user to run and manage virtual machines.
- [popOS_setup.sh](popOS_setup.sh):
	- The package **pixz** is now installed as essential.
- [flatpaks.txt](flatpaks.txt):
	- Added **Discord** to the list.
- [remove.txt](remove.txt):
	- Added **popsicle** and **gnome help** to the list.
#### Fixed
- [popOS_setup.sh](popOS_setup.sh):
	- Fixed the welcome message.
	- Fixed system installation of flatpaks.
- [gnome_settings.sh](scripts/gnome_settings.sh):
	- Fixed bad usage of dconf when configuring gedit.
- [zsh.sh](post-install.d/zsh.sh):
	- Fixed permission denied when writing to `/etc/zsh/zshenv`.
- [.zshrc](samples/zshrc):
	- The git prompt now doesn't dissapear if you're not in the root folder of a repository.
- [.bashrc](samples/bashrc):
	- The git prompt now doesn't dissapear if you're not in the root folder of a repository.

### Version [2.2.0](https://github.com/nico-castell/PopOS-Setup/releases/tag/2.2.0) - *2021-10-11*
This update comes after a **very** long time, the main things it brings are:
- Defined behaviour for running the *popOS_setup.sh* script as root.
- Using `/etc/zsh/zshenv` to configure the **$PATH** for all users.
#### Added
- [popOS_setup.sh](popOS_setup.sh):
	- The script now stops if you run it as root, you should run it as your user. You can use the `-s`
	- The script now sorts the package lists and removes duplicates.
	- Added a few more options for nvidia drivers.
- [packages.txt](packages.txt):
	- Added Krita drawing software.
	- Added Chromium browser.
	- Added some fun terminal commands.
- [duc_noip_install.sh](scripts/duc_noip_install.sh):
	- Now, if you pass the `-s` flag to the script, it will set up a systemd service and a systemd
		timer so it runs every time you boot the computer.
	- If you run the script as root, the "supporting" files such as No-IP's icon and the desktop entry
		will be placed in `/usr/local` instead of `~/.local`.
	- The script now shows the status of the installation as *Success* or *Failed* when it finishes.
	- The script now writes an installation log to `/usr/local/src` to help system admins delete the
		program if they no longer need it.
- [gnome_settings.sh](scripts/gnome_settings.sh):
	- The script now sets up **geary** in a lot more depth.
- [mc_server_builder.sh](scripts/mc_server_builder.sh):
	- The `compress.sh` script written by this script now shows a progress percentage while creating
		backups of the server.
- [remove.txt](remove.txt):
	- Added *Videos* and *Archive Manager* to the list of possible packages to remove.
#### Changed
- [gnome_appearance.sh](scripts/gnome_appearance.sh):
	- The file now has support for compressed archives that are not gzip format.
	- The file now extracts the themes and icons into `~/.local/share`.
- [tlp.sh](post-install.d/tlp.sh):
	- The script now offers many more configuration choices for handling the lid switch.
	- The script now restarts the *systemd-logind* service after writing to the config file.
- [zsh.sh](post-install.d/zsh.sh):
	- The script now writes to `/etc/zsh/zshenv` code to add `~/.local/bin` to the $PATH for all
		users.
- [.zshrc](samples/zshrc):
	- The file no longer modifies the $PATH. As that is now handled by `/etc/zsh/zshenv`.
- [.bashrc](samples/bashrc):
	- Some of the improvements for the Z-Shell were added to this file.
#### Fixed
- [post-install.d](post-install.d/golang.sh):
	- It now shows the separator to avoid cluttering in the terminal.
- [.zshrc](samples/zshrc):
	- The file no longer causes the shell to open with error code 1.
- [.vimrc](samples/vimrc):
	- Fixed mode() related eror when interactively replacing text.
- [init.vim](samples/nvim.vim):
	- Fixed mode() related eror when interactively replacing text.
#### Removed
- [.zshrc](post-install.d/zshrc):
	- The file no longer reads `~/.zsh_aliases`.

### Version [2.1.0](https://github.com/nico-castell/PopOS-Setup/releases/tag/2.1.0) - *2021-07-15*
This update had many more commits than usual, though there aren't that many new things. The main improvements are:
- Heavily improved the configuration of Vim and added Neovim with a similar configuration.
- Added flags to the [back_me_up.sh](back_me_up.sh) script.
- Reworked the [mc_server_builder.sh](scripts/mc_server_builder.sh) script to make it more stable.
#### Added
- [back_me_up.sh](back_me_up.sh):
	- Added `-r` flag, which tells the script to replace the latest backup.
	- Added `-s` flag, which tells the script to backup the `~/.ssh` and `~/.safe` directories.
- [golang.sh](post-install.d/golang.sh):
	- Added the choice to install development tools for Visual Studio Code.
- [packages.txt](packages.txt):
	- Added [Neovim](https://neovim.io/) package.
- [.zshrc](samples/zshrc):
  - Added `lz` and `llz` aliases to easily see SELinux tags when listing files.
- [nvim.vim](samples/nvim.vim):
	- Added a config file for neovim with many of the features of the current [.vimrc](samples/vimrc).
- [neovim.sh](post-install.d):
	- Can set up **Neovim** as the default `$EDITOR`.
	- Can write a special function to the config file to check which editor you're running when you also install **Vim**.
- [.vimrc](samples/vimrc):
	- A dynamic statusline for non-powerline vim editors. It changes based on wether the user is in an active or inactive split.
	- Set a scroll offset of 5 lines to keep your sight further from the edge of the screen.
	- Integrate with the system clipboard.
- [vim.sh](post-install.d/vim.sh):
	- Can write a special function to the config file to check which editor you're running when you also install **Neovim**.
- [git.sh](post-install.d/git.sh):
	- Integrate **Vim** and **Neovim** more deeply with Git.
	- New aliases `eflog` and `now-ignores`. They show commit log with commiter emails and tracked files that should be ignored by git, respectively.
#### Changed
- [deskcuts](deskcuts):
	- Many files inside the folder were updated to use paths such as `~/.local/share/icons/hicolor` and `/usr/local`.
- [mc_server_builder.sh](scripts/mc_server_builder.sh):
	- The script was heavily modified to make it more stable.
	- It no longer sets up the firewall by default.
	- Option `-mc` is now `-v` (for *visible*).
	- You now use the `-f` flag to tell the script to configure the firewall.
	- It no longer needs user assistance to delete firewall rules.
	- The download link is now at the top of the script for it to be easy to update.
	- There's a list of possible exit codes and their meanings.
- [.zshrc](samples/zshrc):
	- Use `awk` commands instead of combining `grep`, `rev` and `cut` for the git prompt. (Less subprocesses)
- [.vimrc](samples/vimrc):
	- Put backup, undo, and swap files in `~/.cache/vim`, and set their permissions so other users cannot read them.
	- Set textwidth for *plain text* and *markdown* to 100 characters.
	- Reconfigured some of the coloring to be more consistent on terminal and gui.
- [vim.sh](post-install.d/vim.sh):
	- Reworded some prompts to avoid confusion with neovim.
#### Fixed
- [vim.sh](post-install.d/vim.sh):
	- Fixed typo in *.csh* config file.
- [mc_server_builder.sh](scripts/mc_server_builder.sh):
	- The animation does no longer lingers in your shell if you interrupt the script (*^C*).

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
