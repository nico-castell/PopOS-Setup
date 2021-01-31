# Change log

All significant changes to **PopOS Start** will be documented here

1. [Released](#Released)
1. [Previous Repository](#Previous-repository)
1. [Pre Releases](#Pre-Releases)

## Released
### Version [0.1.2](https://github.com/nico-castell/PopOS-Setup/releases/tag/0.1.2) - *2021-01-31*
#### Changed
Now the project is hosted on a new repository.
#### Deprecated
The old repository is deprecated and will be removed within the next 14 days.

---

## Previous repository

### Version 0.1.1 - *2021-01-28*
#### Added
1. Implementation of rsync in *back_me_up*.
1. Implementation of wait animations in *back_me_up* and *pop_OS_start*.
1. Adding **signal-desktop** to *pop_OS_start*.
1. Added Extension Development to select menu in Visual Studio Code setup.
1. Improved documentation.

### Version 0.1.0 - *2021-01-10*
#### About
This is the first official release, there were other minor and not so minor
upgrades to the project before it was published. Previous versions were not
documented so information about then is very limited.

#### Added
1. Add animations on a few package manager short operations
1. Copying .zshrc to root
1. Configuring powerline-shell on root user.

#### Fixed
1. zsh auto-package-completion fixed (and pip3 powerline-shell installation)
1. Copying .zshrc sample to root
1. Copying deskcuts when accessing a directory containing spaces.

---

## Pre-Releases

### Version 0.0.3
#### Changed
This was a major **re-writing** of the pop_OS_start script, it allowed for
more expandability, simplified processes and seriously reduced the number of
bugs.

### Version 0.0.2
#### Added
1. **Reboot the machine** after upgrading the kernel or installing a
proprietary NVIDIA driver.
1. Load choices from a temporary file.

### Version 0.0.1
#### Added
1. Choose packages to remove or install and flatpaks to install
**at the start** of the script, not when the operation is about to be
performed.
