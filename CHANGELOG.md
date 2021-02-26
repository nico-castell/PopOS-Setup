# Change log
All significant changes to **PopOS Start** will be documented here.

1. [Unreleased](#unreleased)
1. [Released](#Released)
1. [Previous Repository](#Previous-repository)
1. [Pre Releases](#Pre-Releases)

## Unreleased
### Changed
- General improvements and fixes in [mc_server_builder](mc_server_builder.sh).
- Favorite apps in [gnome_settings](gnome_settings.sh).

### Fixed
- Excel browser [shortcut](deskcuts/browser-msexcel.desktop).
- Java JDK installation in [pop_OS_start](pop_OS_start.sh).
- Git ppa repository reporting fail after success [pop_OS_start](pop_OS_start.sh).
- Fixing [gnome_appearance](gnome_appearance.sh).

## Released

### Version [0.1.4](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.1.4) - *2021-02-24*
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
* Some `tput setaf` commands were changed from ANSI escape codes.

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
