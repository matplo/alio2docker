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

# prefer locally build docker image but download if not found
# note: docker images -q slower than docker image inspect (on a system with many images)
docker_image_local=alisoft:o2
# [ "$(docker images -q ${docker_image_local} 2> /dev/null)" == "" ]
if [ ! -z $(docker images -q ${docker_image_local}) ]; then
	echo_info "will use local image ${docker_image_local}"
	echo_info "local images tagged ${docker_image_local} : $(docker images -q ${docker_image_local})"
else
	docker_image_local="nobetternick/${docker_image_local}"
	if [ ! -z $(docker images -q ${docker_image_local}) ]; then
		echo_info "will use local image ${docker_image_local}"
		echo_info "local images tagged ${docker_image_local} : $(docker images -q ${docker_image_local})"
	else
		echo_info "pulling image ${docker_image_local}"
		docker pull ${docker_image_local}
		if [ ! -z $(docker images -q ${docker_image_local}) ]; then
			echo_info "will use local image ${docker_image_local}"
			echo_info "local images tagged ${docker_image_local} : $(docker images -q ${docker_image_local})"
		else
			error "local image ${docker_image_local} does not exist. stop here."
			exit 1
		fi
	fi
fi


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
		if [ "x${em}" == "x$docker_image_local" ]; then
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

function create_current_user_files()
{
	echo_info "creating current user files..."
	fout=${THISD}/alisoft/.current_user.sh
	echo "export _USERNAME=$(whoami)" > $fout
	echo "export _UID=$(id -u)" >> $fout
	echo "export _GID=$(id -g)" >> $fout
	if [ -d ${HOME}/.globus ]; then
		if [ -d ${THISD}/alisoft/.globus ]; then
			echo_warning "[info] ${THISD}/alisoft/.globus already exists - pass..."
		else
			echo_info "copying ${HOME}/.globus to ${THISD}/alisoft/.globus"
			cp -pr ${HOME}/.globus ${THISD}/alisoft/
			_globus_copied=1
		fi
	fi
}
export -f create_current_user_files

########

check_ps_states

if [ "x0" != "x$nrunlistExited" ]; then
	echo_warning "Removing container $runlistExited"
	docker rm $runlistExited
fi

create_current_user_files

_interactive="-it"
_cmnd=""

# check if a command to execute
if [ ! -z "${1}" ]; then
		_cmnd="$@"
		_interactive=""
fi

echo_info "interactive? ${_interactive}"
echo_info "cmnd to execute: ${_cmnd}"

# note about running containers
if [ "x0" != "x$nrunlistRunning" ]; then
	echo_warning "[info] note, you already have ${nrunlistRunning} running instances [${runlistRunning}]"
fi

_tmp_name=$(mktemp)
_slash="/"
_dash="-"
_tmp_cont_name=${_tmp_name//$_slash/$_dash}
_tmp_cont_name="alisoft.o2-${_tmp_cont_name}"
echo_info "instance name: ${_tmp_cont_name}"

# run the container
separator "running container"
docker run ${_interactive} --rm \
	--mount type=bind,source="$(pwd)/alisoft",target=/alisoft \
	-w /alisoft -h alio2dock --env-file "$(pwd)/alio2docker.env" \
	--name ${_tmp_cont_name} \
	--shm-size=8g \
	--user root \
	${docker_image_local} \
	${_cmnd}
separator "."

if [ -d ${THISD}/alisoft/.globus ]; then
	if [[ ${_globus_copied} ]]; then
		echo_info "removing ${THISD}/alisoft/.globus"
 		rm -rf ${THISD}/alisoft/.globus
	fi
fi

echo_info "removing ${_tmp_name}"
rm -rf ${_tmp_name}

separator "${BASH_SOURCE} done."
