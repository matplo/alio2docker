#!/bin/bash

docker run -it \
	--mount type=bind,source="$(pwd)",target=/alisoft \
	alisoft:o2 
	
	#\
	#/bin/bash 
#	/alisoft/alidocko2shell.sh
