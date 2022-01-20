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

function run_container()
{
	separator "running container"
	echo_warning "Running -it with $@"
	docker run -d \
	--mount type=bind,source="$(pwd)/alisoft",target=/alisoft \
	-w /alisoft -h alio2dock --env-file "$(pwd)/alio2docker.env" \
	--name alisoft.o2 \
	$@ \
	alisoft:o2 
}
export -f run_container

function container_create_current_user()
{
	separator "creating user $(id -u) $(whoami)"
	echo_warning "Note: username not available in passwd file - not mapping passwd/groups"
	userconfig=""
	docker exec \
	--user root \
	$1 \
	/alisoft/createuser.sh $(whoami) $(id -u) $(id -g)
}
export -f container_create_current_user

function exec_it()
{
	separator "executing docker bash ${1} ..."
	# docker exec -it ${1} /bin/bash
	docker container start -ai ${1}
	docker ps -all
	# docker container attach ${runlistExited}
}
export -f exec_it

docker ps -all
check_ps_states
echo_info "Found $nrunlistExited EXITED containers [$runlistExited]."
echo_info "Found $nrunlistRunning RUNNING containers [$runlistRunning]."
echo_info "Found $nrunlistAny ANY containers [$runlistAny]."

# run first time and create user if needed
if [ "x0" == "x$nrunlistExited" ]; then
	suname=$(id -u)
	grepuname=$(grep ${suname} /etc/passwd)
	userconfig="--user $(id -u):$(id -g)"
	if [ ! -z ${grepuname} ]; then
		[ -f /etc/group ] && gvolgroup="--volume=/etc/group:/etc/group:ro "
		[ -f /etc/passwd ] && gvolpasswd="--volume=/etc/passwd:/etc/passwd:ro "
		[ -f /etc/shadow ] && gvolshadow="--volume=/etc/shadow:/etc/shadow:ro "
	fi

	run_container ${gvolgroup} ${gvolpasswd} ${gvolshadow} ${userconfig}

	if [ -z ${grepuname} ]; then
		check_ps_states
		if [ "x1" == "x$nrunlistExited" ]; then
			container_create_current_user $runlistExited
		fi
	fi
else
	if [ "x1" == "x$nrunlistExited" ]; then
		exec_it $runlistExited
	else
		echo_error "unclear what to do... stop here."
		docker ps --filter status=exited
	fi
fi
