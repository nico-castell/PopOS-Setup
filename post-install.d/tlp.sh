# bash script to be sourced from fedora_setup.sh

Separate 4
printf "Successfully installed \e[36mtlp\e[00m, configuring...\n"

# Conditionally execute all the steps to configure tlp.
sudo mv /etc/tlp.conf /etc/tlp.conf-og && \
cat "$script_location/samples/tlp.conf" | sudo tee /etc/tlp.conf >/dev/null && \
sudo systemctl enable tlp && \
sudo systemctl restart tlp

printf "%s\e[00m\n" $([ $? -eq 0 ] && printf "\e[32mSuccess" || printf "\e[31mFail")

read -rp "Do you want to suspend the OS when you close the lid? (laptops only) (Y/n) "
[[ ${REPLY,,} == "y" ]] && sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=suspend/' /etc/systemd/logind.conf
