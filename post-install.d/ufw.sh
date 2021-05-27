# bash script to be sourced from popOS_setup.sh

# Enabe ufw firewall
[[ $(sudo ufw status 2>&1 | grep Status) == *"inactive" ]] && \
	sudo ufw enable &>/dev/null
