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

echo_info "Checking for exited containers..."
exited_imgs=( $(docker ps --filter status=exited | awk '{print $1,$2}') )
running_imgs=( $(docker ps --filter status=running | awk '{print $1,$2}') )
any_imgs=( $(docker ps -all | awk '{print $1,$2}') )
# echo ${exited_imgs[@]}

shash=""
for em in ${exited_imgs[@]}
do
	if [ "x${em}" == "xalisoft:o2" ]; then
		runlistExited="${runlistExited} ${shash}"
	fi
	shash=${em}
done
nrunlistExited=$(echo ${runlistExited} | wc -w | tr -d ' ')
echo_info "Found $nrunlistExited exited containers."

shash=""
for em in ${running_imgs[@]}
do
	if [ "x${em}" == "xalisoft:o2" ]; then
		runlistRunning="${runlistRunning} ${shash}"
	fi
	shash=${em}
done
nrunlistRunning=$(echo ${runlistRunning} | wc -w | tr -d ' ')
echo_info "Found $nrunlistRunning running containers."

shash=""
for em in ${any_imgs[@]}
do
	if [ "x${em}" == "xalisoft:o2" ]; then
		runlistAny="${runlistAny} ${shash}"
	fi
	shash=${em}
done
nrunlistAny=$(echo ${runlistAny} | wc -w | tr -d ' ')
echo_info "Found $nrunlistAny any containers."

if [ "x0" == "x$nrunlistExited" ]; then
	separator "Checking for running containers..."
	docker ps --filter status=running
	echo_info "Found ${nrunlistRunning} running containers..."
	if [ "x0" == "x$nrunlistRunning" ]; then
		separator "Executing docker run..."
		gvols=""
		[ -f /etc/group ] && gvols="${gvols} --volume=\"/etc/group:/etc/group:ro\""
		[ -f /etc/passwd ] && gvols="${gvols} --volume=\"/etc/passwd:/etc/passwd:ro\""
		[ -f /etc/shadow ] && gvols="${gvols} --volume=\"/etc/shadow:/etc/shadow:ro\""
		echo_warning "Mapping volumes ${gvols}"
		docker run -it \
		--mount type=bind,source="$(pwd)/alisoft",target=/alisoft \
		-w /alisoft -h alio2dock --env-file "$(pwd)/alio2docker.env" \
		--name alio2 \
		--user $(id -u):$(id -g) \
		${gvols} \
		alisoft:o2 
		# --group-add $(id -g) \
	else
		if [ "x1" == "x$nrunlistRunning" ]; then
			separator "Attaching to ${runlistRunning} ..."
			docker container attach ${runlistRunning}
		else
			echo_error "Multiple exited containers... unclear what to do... stop here."
		fi
	fi
else
	if [ "x1" == "x$nrunlistExited" ]; then
		separator "Executing docker start on ${runlistExited} ..."
		docker start ${runlistExited}
		docker container attach ${runlistExited}
	else
		echo_error "Multiple exited containers... unclear what to do... stop here."
		docker ps --filter status=exited
	fi
fi
