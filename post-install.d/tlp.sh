# bash script to be sourced from popOS_setup.sh

Separate
printf "Successfully installed \e[36mtlp\e[00m, configuring...\n"

# Conditionally execute all the steps to configure tlp.
sudo cp /etc/{tlp.conf,tlp.conf-og}                                            && \
	cat "$script_location/samples/tlp.conf" | sudo tee /etc/tlp.conf >/dev/null && \
	sudo systemctl enable --now tlp

printf "%s\e[00m\n" $([ $? -eq 0 ] && printf "\e[32mSuccess" || printf "\e[31mFail")

printf "If you have a laptop. What do you want to do when you close the lid?\n"
CHOICE=none
select s in ignore poweroff suspend hibernate "I don't have a laptop"; do
case $s in
	ignore)                  CHOICE=ignore    ;;
	poweroff)                CHOICE=poweroff  ;;
	suspend)                 CHOICE=suspend   ;;
	hibernate)               CHOICE=hibernate ;;
	"I don't have a laptop") CHOICE=none      ;;
	*) echo "Option $s not recognized."; continue ;;
esac; break; done

if [ "$CHOICE" != "none" ]; then
	sudo sed -i "s/#HandleLidSwitch=suspend/HandleLidSwitch=$CHOICE/" /etc/systemd/logind.conf
	sudo systemctl restart systemd-logind.service
fi
unset CHOICE
