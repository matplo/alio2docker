#!/bin/bash

username=$1
uid=$2
gid=$3

if [ -z ${username} ]; then
	echo "[e] username not specified - 1st argument"
else
	if [ -z $(id $username) ]; then
		useradd --create-home --home-dir /home/${username} -u $uid -g $gid ${username}
		echo "${username}:${username}!" | chpasswd
	else
		echo "[i] user ${username} exists."
	fi
fi
