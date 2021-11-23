# bash script to be sourced from popOS_setup.sh

Separate
printf "Successfully installed \e[36mKernel development\e[00m, configuring...\n"
read -rep "Do you want to configure your system for developing the linux kernel? (y/N) "
if [ ${REPLY,,} == "y" ]; then

	# Create the directory structure and clone the stable branch of the kernel from kernel.org.
	printf "Creating the directory structure to develop the linux kernel...\n"
	mkdir -p ~/kernel/{built,configs}
	pushd . >/dev/null
	cd ~/kernel

	# Offer not to clone the kernel as it can take quite a long time
	read -rep "$(printf "Do you want to clone the linux kernel now? (Can take a \e[01mvery\e[00m long time) (y/N) ")"
	if [ ${REPLY,,} == "y" ]; then
		read -rep "Type in the kernel version (vX.X.X) to shallow clone: "
		if [ -n $REPLY ]; then
			# Make a shallow clone of a specific tag in the repository
			git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git 'linux-stable' -b $REPLY --depth=0
		fi
	fi

	# Offer the user a possibility to write a file allowing them extra priority with the nice command
	# without the use of sudo
	read -rep "$(printf "Do you want to configure a file to allow you to set processes with lower than 0 priority? (Helps a
lot with compile times) (Y/n) ")"
	if [ ${REPLY,,} == "y" -o -z "$REPLY" ]; then
		cat <<EOF | sudo tee /etc/security/limits.d/$USER.conf >/dev/null
# Allow user to use negative niceness
$USER	-	nice	-20
EOF
	fi

	# Copy the script to help in kernel development to the $PATH.
	mkdir -p ~/.local/bin
	cp $script_location/samples/kdev.sh ~/.local/bin/kdev
	chmod +x ~/.local/bin/kdev

	popd >/dev/null

fi
unset REPLY
