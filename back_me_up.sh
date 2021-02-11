#!/bin/bash
# A script to back up user files.

# MIT License

# Copyright (c) 2021 nico-castell

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#region Options
while [ -n "$1" ]; do
    case "$1" in
        -r | --remove-previous) REMOVEPREV=true ;;           # Remove previous backups.
        -sms | --skip-minecraft-server) SKIPMCSERVER=true ;; # Skip minecraft server.
        -smc | --skip-minecraft-client) SKIPMCCLIENT=true ;; # Skip minecraft.
        -vms | --virtual-machines) INCLUDEVMS=true ;;        # Include VirtualBox VM's
        -root) INCLUDEROOT=true ;;                           # Include files from the root directory.
        -h | --help)                                         # Offer help text.
            echo "This script creates a backup of your files in the secondary drive."
            echo "Options:"
            echo "  -r | --remove-previous)"
            echo "      Remove previous backups."
            echo "  -smc | --skip-minecraft-client)"
            echo "      Skip minecraft."
            echo "  -sms | --skip-minecraft-server)"
            echo "      Skip minecraft server."
            echo "  -vms | --vitual-machines)"
            echo "      Include VirtualBox VMs."
            echo "  -root)"
            echo "      Include files from root directory."
            echo "  -h)"
            echo "      Show this menu."
            echo "Using arguments for the destination drive and folders:"
            echo "  Use \"--\" to specify a drive in the first position"
            echo "  Use the other positions to specify folders to copy from the home directory."
            echo "  Note: When specifying folders, you must also specify the drive."
            exit 0
            ;;

        --) shift && break ;;
        *) echo "ERROR: Option $1 not recognized" && exit 1 ;;
esac; shift; done
#endregion Options


# Set all defaults, unless the user overrides them.
if [ -z $1 ]; then
    DESTINATION=("/media/$USER/Data & BackUps")
else
    DESTINATION=("/media/$USER/$1")
fi
shift
if [ -z $1 ]; then
    LIST=("Desktop" "Documents" "Development" "Templates" "GIMP" ".mydock" "Pictures" "Music" "Videos" ".bashrc" ".zshrc" ".zsh_aliases" ".vimrc" ".clang-format")
else
    LIST=("$@")
fi

#region Preparations
#===========================================================================
# Test for secondary drive and prepare destination.

# Show an animation while waiting for a process to finish (usage: Animate & pid=$!; kill $pid)
Animate() {
    CICLE=('|' '/' '-' '\')
    while true; do
        for i in "${CICLE[@]}"; do
            printf "Removing previous backups %s\r" $i
            sleep 0.2
        done
    done
}

pushd . >/dev/null
cd ~

# Setting the destination folder name.
TODAY=$( date +"%Y-%m-%d_%H-%M" )

if [ "$INCLUDEROOT" ]; then
    sudo echo > /dev/null
    if [ ! $? -eq 0 ]; then exit 1; fi
fi

# Testing if the secondary Drive is connected.
if [ ! -d "$DESTINATION" ]; then
    echo -e "\e[31mERROR: \"${DESTINATION/"/media/$USER/"/""}\" drive not found.\e[00m"
    exit 1
fi

echo -e "Backing up in \"\e[36m${DESTINATION/"/media/$USER/"/""}\e[00m\"..."

# Test for the backings directory, creae it if necessary.
if [ ! -d "$DESTINATION/Backings/" ]; then mkdir "$DESTINATION/Backings"; fi

# If the option to remove prev backups is selected, only delete if there are prev backups.
if [ "$REMOVEPREV" ] && [ ! -z "$(ls -A "$DESTINATION/Backings/")" ]; then
    Animate & PID=$!
    rm -rf "$DESTINATION"/Backings/*
    kill $PID; printf "Removing previous backups, \e[32mDone\e[00m\n"
fi

# Testing if the user is backing up again too soon.
if [ -d "$DESTINATION/Backings/$TODAY" ]; then
    echo -e "\e[31mERROR: You have to wait to make another back up.\e[00m"
    exit 1
fi

# Create destination directory and store it in a variable.
if [ ! -d "$DESTINATION"/Backings/$TODAY/ ]; then mkdir "$DESTINATION/Backings/$TODAY"; fi
DESTINATION=("$DESTINATION/Backings/$TODAY")

# Add extra folders to the lists
if [ ! "$SKIPMCSERVER" ]; then LIST+=(".mcserver" "mcserver"); fi                                          # Minecraft Server
if [ ! "$SKIPMCCLIENT" ]; then LIST+=(".minecraft"); fi                                                    # Minecraft Client
if [ "$INCLUDEVMS" ];     then LIST+=(".vms" "VirtualBox VMs"); fi                                         # VirtualBox
if [ "$INCLUDEROOT" ];    then LIST+=("root-.bashrc" "root-.zshrc" "root-.zsh_aliases" "root-.vimrc"); fi  # Root user

#===========================================================================
#endregion Preparations


#region Making the BackUp
#===========================================================================
# Copy the files and handle special instructions.

# Override the animation while waiting for a process to finish (usage: Animate & pid=$!; kill $pid)
Animate() {
    CICLE=('|' '/' '-' '\')
    while true; do
        for i in "${CICLE[@]}"; do
            printf "Copying \e[33m%s\e[00m %s\r" $1 $i
            sleep 0.2
        done
    done
}

# Copy the items in the SUBLIST.
copy_sublist () {
    # It tests for the presence of the file before copying, so to avoid errors as some of them may not have been created.
    for i in ${SUBLIST[@]}; do
        if [ -f ~/$d/$i ] || [ -d ~/$d/$i ]; then
            cp -r ~/$d/$i "$DESTINATION"/${d/"."/""}/
        fi
    done
}

# Iterate though the list.
for d in ${LIST[@]}; do

    # Look for the file or directory in the home directory first. If it's a directory check that it's
    # not empty, only then copy the file. But, if the file is not found in the home folder, and it's
    # prefix with the keyword 'root-', check that if it's present in the root home folder, if it is,
    # copy it to the destination while prefixing it with 'root'.

    unset FOUND
    # Find in home directory.
    if [ -f ~/$d ] || ( [ -d ~/$d/ ] && [ ! -z "$(ls -A ~/$d/)" ] ); then
        FOUND=true
    fi

    # If the file is prefixed by 'root-0', find it in the root home directory.
    if [[ "$d" == "root-"* ]]; then
        #          Check it's a file                         Check it's directory and it's not empty.
        if sudo [ -f /root/${d/"root-"/""} ] || ( sudo [ -d /root/${d/"root-"/""} ] && [ ! -z "$(sudo ls -A /root/${d/"root-"/""}/)" ] ); then
            FOUND=true
        fi
    fi

    # If the file wasn't found skip this iteration.
    if [ "$FOUND" != true ]; then continue; fi

    case $d in
        Templates) # Manage the Empty file template.
        if [ ! -z "$(ls -A ~/$d/ | grep -v "Empty")" ]; then
            Animate "$d" & PID=$!
            rsync -r --exclude 'Empty' "$d" "$DESTINATION/"
            kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" $d
        fi
        ;;

        .mydock) # Work with .mydock.
        Animate "$d" & PID=$!
        rsync -r --exclude 'noip*' "$d" "$DESTINATION/"
        mv "$DESTINATION/$d" "$DESTINATION/${d/"."/""}"
        kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" $d
        ;;

        .minecraft) # Copy only relevant files (SUBLIST) in .minecraft.
        Animate "$d" & PID=$!
        mkdir "$DESTINATION/${d/"."/""}"
        SUBLIST=("saves" "resourcepacks" "screenshots" "launcher_profiles.json" "options.txt" "optionsof.txt" "servers.dat" "servers.dat_old")
        copy_sublist
        kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" $d
        ;;

        .mcserver) # Copy only relevant files (SUBLIST) in .mcserver.
        Animate "$d" & PID=$!
        mkdir "$DESTINATION/${d/"."/""}"
        SUBLIST=("banned-ips.json" "banned-players.json" "ops.json" "whitelist.json" "server.properties" "run" "server-icon.png" "server*.jar")
        # Get the world name and add it to the list.
        WORLD=$(cat ~/$d/server.properties | grep "level-name")
        WORLD=${WORLD/"level-name="/""}
        SUBLIST+=($WORLD)
        copy_sublist
        kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" $d
        ;;

        Documents) # Avoid copying .git folders and folders marked as 'Repo'.
        Animate "$d" & PID=$!
        rsync -r --exclude 'Repo' --exclude '.git' "$d" "$DESTINATION"
        kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" $d
        ;;

        Development) # Avoid copying node modules and .git folders, make the process much faster.
        #region Exclude file ============================================================
        echo "node_modules" >> "`dirname "$0"`/.tmp_exclude"
        echo ".git"         >> "`dirname "$0"`/.tmp_exclude"
        echo "out"          >> "`dirname "$0"`/.tmp_exclude"
        echo "bin"          >> "`dirname "$0"`/.tmp_exclude"
        echo "obj"          >> "`dirname "$0"`/.tmp_exclude"
        #endregion Exclude file ============================================================
        Animate "$d" & PID=$!
        rsync -r --exclude-from "`dirname "$0"`/.tmp_exclude" "$d" "$DESTINATION/"
        kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" $d
        rm "`dirname "$0"`/.tmp_exclude"
        ;;

        root-*) # Copy files from the root user's home directory.
        Animate "${d/"root-"/""} from root" & PID=$!
        sudo cp -r "/root/${d/"root-"/""}" "$DESTINATION/root${d/"root-"/""}"
        kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" "${d/"root-"/""} from root"
        ;;

        *)
        Animate "$d" & PID=$!
        cp -r ~/"$d" "$DESTINATION"/${d/"."/""}
        kill $PID; printf "Copying \e[33m%s\e[00m, \e[32mDone\e[00m\n" $d
        ;;
    esac
done

#===========================================================================
#endregion Making the BackUp
popd >/dev/null

# Thanks for downloading, and enjoy!
