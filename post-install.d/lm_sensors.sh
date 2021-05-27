# bash script to be sourced from fedora_setup.sh

# Interact with the user to configure "sensors" package
Separate 4
printf "Successfully installed \e[36mLM Sensors\e[00m, configuring...\n"
sleep 1.5 # Time for the user to read
sudo sensors-detect
