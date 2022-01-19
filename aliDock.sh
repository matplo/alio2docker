#!/bin/bash -l

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
source ${THISD}/util.sh
separator "${BASH_SOURCE}"

ALIDOCKDIR=${THISD}/alidock
mkdir -p ${ALIDOCKDIR}
cd ${ALIDOCKDIR}
docker build -t alisoft:o2 --label alisoft https://github.com/matplo/alio2docker.git#main

cp ${THISD}/alidocko2shell.sh ${ALIDOCKDIR}
chmod +x ${ALIDOCKDIR}/alidocko2shell.sh

docker run -it \
	--mount type=bind,source="$(pwd)",target=/alisoft \
	alisoft:o2 \
	/alisoft/alidocko2shell.sh 
