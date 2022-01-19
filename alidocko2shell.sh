#!/bin/bash -i

set -e

export PS1="(o2dock)\e[32;1m[\u\e[31;1m@\h\e[32;1m]\e[34;1m\w\e[0m\n> "

## Running passed command
if [[ "$1" ]]; then
	#eval "$@"
	exec "$@"
fi
