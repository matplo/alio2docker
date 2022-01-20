#!/bin/bash -i

set -e

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

if [ -f ${THISD}/.current_user.sh ]; then
	echo_info "changing to current/host user..."
	source ${THISD}/.current_user.sh 
	if [ $(getent group ${_GID}) ]; then
		echo_info "a roup id ${_GID} exists - not creating... $(cat /etc/group | grep ${_GID})"
	else
		groupadd -g ${_GID} $_USERNAME
	fi
	useradd -d /home/$_USERNAME -g ${_GID} --create-home -o -u ${_UID} -s /bin/bash $_USERNAME
	echo "${_USERNAME}:${_USERNAME}!" | chpasswd
	# adduser ${_USERNAME} sudo
	echo "${_USERNAME}  ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${_USERNAME}
	cat /alisoft/_bash_aliases >> /home/$_USERNAME/.bash_aliases
	echo_info "written to /home/$_USERNAME/.bash_aliases "
	if [ -d /alisoft/.globus ]; then
		echo_info "propagating .globus..."
		cp -pr /alisoft/.globus /home/$_USERNAME/
	fi
	chown -R ${_UID}:${_GID} /home/$_USERNAME
fi

# Running passed command
if [[ "$1" ]]; then
	#eval "$@"
	echo_error "[exec] $@"
	# sudo su - $_USERNAME "$(/bin/bash \"$@\")"
	sudo runuser -u ${_USERNAME} -- $@
	#else
	#	exec "$@"
	#fi
else
	echo_error "[exec] droping to a shell..."
	sudo runuser -u ${_USERNAME} -- /bin/bash -l
fi
