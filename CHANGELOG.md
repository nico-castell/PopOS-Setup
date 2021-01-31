# Change log

All significant changes to **PopOS Start** will be documented here

1. [Unreleased](#Unreleased)
1. [Released](#Released)
1. [Pre Releases](#Pre-Releases)

## Unreleased

1. Add more git configs in the vscode git setup.

## Released

### Version [1.3.3](https://github.com/nico-castell/PopOS-Start/releases/tag/1.3.3) - *2021-01-28*

#### Added
1. Implementation of rsync in *back_me_up*.
1. Implementation of wait animations in *back_me_up* and *pop_OS_start*.
1. Adding **signal-desktop** to *pop_OS_start*.
1. Added Extension Development to select menu in Visual Studio Code setup.
1. Improved documentation.

### Version [1.3.2](https://github.com/nico-castell/PopOS-Start/releases/tag/1.3.2) - *2021-01-10*

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

### Version 1.3.0

#### Changed
This was a major **re-writing** of the pop_OS_start script, it allowed for
more expandability, simplified processes and seriously reduced the number of
bugs.

### Version 1.2.0

#### Added
1. **Reboot the machine** after upgrading the kernel or installing a
proprietary NVIDIA driver.
1. Load choices from a temporary file.

### Version 1.1.0

#### Added
1. Choose packages to remove or install and flatpaks to install
**at the start** of the script, not when the operation is about to be
performed.
