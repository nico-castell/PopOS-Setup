<h1 align="center">
	<br><img src="assets/logo.png" width="317" height="230">
	<br><br>Pop!_OS Setup<br>
</h1>
<p align="center">
   <a href="https://github.com/nico-castell/PopOS-Setup/commits"><img alt="GitHub commits since latest release (by date) for a branch" src="https://img.shields.io/github/commits-since/nico-castell/PopOS-Setup/latest/develop?label=Commits%20since%20last%20release&logo=git&logoColor=white&style=flat-square"></a>
   <a href="https://github.com/nico-castell/PopOS-Setup/releases"><img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/nico-castell/PopOS-Setup?color=informational&label=Release&logo=GitHub&logoColor=white&style=flat-square"></a>
   <a href="LICENSE"><img alt="GitHub" src="https://img.shields.io/github/license/nico-castell/PopOS-Setup?color=informational&label=License&logo=Open%20Source%20Initiative&logoColor=white&style=flat-square"></a>
   <a href="https://github.com/nico-castell/PopOS-Setup"><img alt="Lines of code" src="https://img.shields.io/tokei/lines/github/nico-castell/PopOS-Setup?label=Lines%20of%20code&color=informational&logo=GNU%20bash&logoColor=white&style=flat-square"></a>
</p>

This script was born from a desire to set up [Pop!_OS](https://pop.system76.com/) quickly and without too much fuzz. It focuses on 3 things:

1. Getting the OS and drivers set up properly.
2. Getting programs set up.
3. Getting GNOME set up.

<h2 align="center">The steps of the <a href="pop_OS_start.sh">script</a></h2>

1. Process options.
	* --disable-reboot) Not allow the script to reboot the computer.
	* --from-temp-file) Load previous choices.
2. Get script location for use throughout the program.
3. Get location of the file to save choices to.
4. This step can go two ways:
	* Prompt the user about how to set up the system.
	* Load previous choices and skip the prompting.
5. Preparing the environment to set up programs. This includes:
	* Handling .mydock and .ssh.
	* Firewall.
	* Aliases.
	* Test for internet connection.
6. Add universe component to package manager.
7. Remove chosen software.
8. Perform complete upgrade. This step includes:
	* Find if kernel is being updated.
	* Update everything.
	* Reboot if kernel was updated.
9. Install nvidia driver. This step includes:
	* Check if not installing [Pop!_OS](https://pop.system76.com/)' driver
	and, if that's the case, reboot to ad proper
	display settings.
	* Install driver.
	* Reboot if necessary.
10. Install user-selected packages. This step includes:
	* Preparing repositories for some packages.
	* Installing packages.
	* Handling post-installation instructions for some packages.
11. Install user-selected flatpaks.
12. Install downloaded packages.
13. Run secondary scripts. Including:
	* duc_noip_install
	* mc_server_builder
	* gnome_settings
	* gnome_apperance
14. Give the final touches. Including:
	* Ensure everything is up to date.
	* Copy deskcuts.
	* Organize app menu alphabetically.
15. If user chose so, update recovery partition.

For more information on the versions, see the [changelog](CHANGELOG.md).

<h2 align="center">How to use</h2>

I'm asumming that you've already [Pop!_OS](https://pop.system76.com/) successfully.

1. Clone this repo
	```bash
	git clone https://github.com/nico-castell/PopOS-Setup.git
	```
2. (Recommended) Change the paths to icons in the files in the [deskcuts](deskcuts) folder.
2. (Optional) The script modifies some files at runtime. You may want to remove the **.git** folder
	```bash
	cd "path/to/cloned/repo"
	rm -rf .git
	```
3. (Optional) Look at the instuctions in thme [gnome_apperance](gnome_appearance.sh) script, and configure the file structure for the script to set up the GNOME appearance with your themes.
	```
	.
	└── themes
		├── background
		│   └── image.png
		├── cursor
		│   └── cursor.tar.gz
		├── icons
		│   └── icons.tar.gz
		└── theme
			└── theme.tar.gz
	```
4. (Optional) If you plan on building a minecraft server, you should check that the `$download_link` and `$version` variables are up to date.
5. Run the pop_OS_start.sh script
	```bash
	./pop_OS_start.sh
	```
6. Answer the questions (they have a 10 second time out and default to no). You'll be asked what software you want to remove and install, and which extras you want to run.
7. Wait, as the script goes, it prompts for more instructions. It generally takes 10-20 minutes to complete, based on how up-to-date your installation already is, and wether you're installing an NVIDIA driver.

### Keep in mind:
* You **must** have an internet connection to run the script.
* The script may **restart your computer**, so try to run the script and nothing else.
* If you choose to update the backup image, it will have to download an entire image of [Pop!_OS](https://pop.system76.com/). So it can take very long, depending on your internet connection.
* If you're using an older nvidia GPU not supported by the latest nvidia driver, it might be better to download the [Pop!_OS](https://pop.system76.com/) ISO without their custom driver, and then choose the latest driver that supports your GPU from the list the script offers. (I'm talking from experience)

## Known issues

1. [*duc_noip_install*](duc_noip_install): The installer can't seem to understand symbols when typing a password, at least on my tests, the script opens *gedit* for you to copy/paste your password and work around the issue.
2. [*mc_server_builder*](mc_server_builder): The link to download the latest version of the server must be manually updated for every minecraft release.

## Licensing
This repository is available under the [MIT License](LICENSE).

> *Live long, and prosper*.  
> *Spock*
