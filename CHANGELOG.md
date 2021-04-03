# Change log
All significant changes to **PopOS Start** will be documented here.

1. [Unreleased](#unreleased)
1. [Released](#Released)
1. [Previous Repository](#Previous-repository)
1. [Pre Releases](#Pre-Releases)

## Unreleased
### Fixed
- [pop_OS_start](pop_OS_start.sh):
  - Fixed colored prompt when confirming packages.
  - Fixed appending to powerline config file when it should be rewritten.

## Released

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

---
## Previous repository

### Version 0.1.1 - *2021-01-28*
#### Added
1. Implementation of rsync in *back_me_up*.
2. Implementation of wait animations in *back_me_up* and *pop_OS_start*.
3. Adding **signal-desktop** to *pop_OS_start*.
4. Added Extension Development to select menu in Visual Studio Code setup.
5. Improved documentation.

### Version 0.1.0 - *2021-01-10*
This is the first official release, there were other minor and not so minor upgrades to the project before it was published. Previous versions were not documented so information about then is very limited.

#### Added
1. Add animations on a few package manager short operations
2. Copying .zshrc to root
3. Configuring powerline-shell on root user.

#### Fixed
1. zsh auto-package-completion fixed (and pip3 powerline-shell installation)
2. Copying .zshrc sample to root
3. Copying deskcuts when accessing a directory containing spaces.

---
## Pre-Releases

### Version 0.0.3
#### Changed
This was a major **re-writing** of the pop_OS_start script, it allowed for more expandability, simplified processes and seriously reduced the number of bugs.

### Version 0.0.2
#### Added
1. **Reboot the machine** after upgrading the kernel or installing a proprietary NVIDIA driver.
1. Load choices from a temporary file.

### Version 0.0.1
#### Added
1. Choose packages to remove or install and flatpaks to install **at the start** of the script, not when the operation is about to be performed.
