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
source ${THISD}/util.sh
separator "${BASH_SOURCE}"

cd ${THISD}
echo "export ALIBUILD_WORK_DIR=\"${THISD}/sw\"" > ${THISD}/alicerc.sh
echo "eval \"`alienv shell-helper`\"" >> ${THISD}/alicerc.sh
. ${THISD}/.alicerc.sh

aliBuild init O2Physics@master --defaults o2
aliDoctor O2Physics --defaults o2
aliBuild build O2Physics --defaults o2
