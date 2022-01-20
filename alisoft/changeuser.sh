#!/bin/bash

if [ -z $1 ]; then
	echo "[e] what's your username? - pass as a first argument"
else
	if [ -z "$(id $1)" ]; then
		echo "[i] creating user $1"
		sudo useradd -d $HOME -g $(id -g) -M -o -u $(id -u) -s /bin/bash $1
		sudo passwd $1
	else
		echo "[i] user $1 exists"
	fi
fi
