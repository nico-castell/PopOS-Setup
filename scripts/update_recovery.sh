#!/bin/bash

# MIT License - Copyright (c) 2021 Nicolás Castellán
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

if [ ! -d /recovery ]; then
	printf "You don't have a recovery partition to update\n" >&2
	exit 1
fi

printf "Upgrading recovery partition...\n"
sudo pop-upgrade recovery upgrade from-release
