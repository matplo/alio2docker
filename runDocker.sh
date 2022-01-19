#!/bin/bash

docker run -it \
	--mount type=bind,source="$(pwd)",target=/alisoft \
	-w /alisoft -h alio2dock --env-file alio2dockenvs.sh \
	alisoft:o2 
	
	#\
	#/bin/bash 
#	/alisoft/alidocko2shell.sh
