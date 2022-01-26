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

function setup_ssh()
{
	separator "setting up ssh for ${_USERNAME}"
	_user=${_USERNAME}
	sudo runuser -u ${_USERNAME} -- ssh-keygen -t rsa -f /home/${_USERNAME}/.ssh/id_rsa -N ''
	cp -vp /home/${_USERNAME}/.ssh/id_rsa.pub /home/${_USERNAME}/.ssh/authorized_keys
	cp -v ${THISD}/_sshd_config /etc/ssh/sshd_config
	service ssh start
	echo_info "$?"
}

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
	$(setup_ssh)
fi

# Running passed command
if [[ "$1" ]]; then
	echo_error "[exec] $@"
	separator "$HOSTNAME"
	sudo runuser -u ${_USERNAME} -- "$@"
else
	echo_error "[exec] droping to a shell..."
	separator "/bin/bash @ $HOSTNAME"
	sudo runuser -u ${_USERNAME} -- /bin/bash -l
fi
