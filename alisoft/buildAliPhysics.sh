#!/bin/bash

savedir=${PWD}

function thisdir()
{
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
	    SOURCE="$(readlink "$SOURCE")"
	      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	      done
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    echo ${DIR}
}
THISD=$(thisdir)
source ${THISD}/_util.sh
separator "${BASH_SOURCE}"

cd ${THISD}
export ALIBUILD_WORK_DIR="${THISD}/sw"
eval `alienv shell-helper`

# git clone https://github.com/alisw/alidist.git

# mkdir ./alice
# cd ./alice

aliBuild init AliPhysics@master 
aliDoctor AliPhysics --defaults o2
aliBuild build AliPhysics --defaults o2
