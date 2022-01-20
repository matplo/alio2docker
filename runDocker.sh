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
source ${THISD}/alisoft/_util.sh
separator "${BASH_SOURCE}"


function check_ps()
{
	if [ "x${1}" == "xall" ]; then
		_exited_imgs=( $(docker ps -all | awk '{print $1,$2}') )
	else
		_exited_imgs=( $(docker ps --filter status=${1} | awk '{print $1,$2}') )
	fi
	# echo_info "Checking for ${1} containers..."
	shash=""
	for em in ${_exited_imgs[@]}
	do
		if [ "x${em}" == "xalisoft:o2" ]; then
			_runlistExited="${_runlistExited} ${shash}"
		fi
		shash=${em}
	done
	echo ${_runlistExited}
}
export -f check_ps

function check_ps_states()
{
	runlistExited=$(check_ps exited)
	nrunlistExited=$(echo ${runlistExited} | wc -w | tr -d ' ')

	runlistRunning=$(check_ps running)
	nrunlistRunning=$(echo ${runlistRunning} | wc -w | tr -d ' ')

	runlistAny=$(check_ps all)
	nrunlistAny=$(echo ${runlistAny} | wc -w | tr -d ' ')
}
export -f check_ps_states

function create_current_user_file()
{
	echo_warning "Creating current user file..."
	fout=${THISD}/alisoft/.current_user.sh
	echo "export _USERNAME=$(whoami)" > $fout
	echo "export _UID=$(id -u)" >> $fout
	echo "export _GID=$(id -g)" >> $fout
}
export -f create_current_user_file

########

check_ps_states

if [ "x0" != "x$nrunlistExited" ]; then
	echo_warning "Removing container $runlistExited"
	docker rm $runlistExited
fi

create_current_user_file

separator "running container"
docker run -it --rm \
--mount type=bind,source="$(pwd)/alisoft",target=/alisoft \
-w /alisoft -h alio2dock --env-file "$(pwd)/alio2docker.env" \
--name alisoft.o2 \
--user root \
alisoft:o2 \
echo "[i] Container stop."
