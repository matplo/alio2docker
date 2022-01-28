# our base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y install gcc git openssh-server
	
RUN apt-get -y install curl libcurl4-gnutls-dev build-essential gfortran libmysqlclient-dev xorg-dev libglu1-mesa-dev libfftw3-dev libxml2-dev git unzip autoconf automake autopoint texinfo gettext libtool libtool-bin pkg-config bison flex libperl-dev libbz2-dev swig liblzma-dev libnanomsg-dev rsync lsb-release environment-modules libglfw3-dev libtbb-dev python3-dev python3-venv libncurses-dev software-properties-common

# added by MP - failed build of boost/latest - Jan 27 2022
RUN apt-get -y install pip

RUN add-apt-repository ppa:alisw/ppa  
RUN apt-get update
RUN apt-get -y install python3-alibuild

RUN apt-get -y install emacs vim nano

ENV LANG en_US.utf8
ENV PS1 "(o2dock)\e[32;1m[\u\e[31;1m@\h\e[32;1m]\e[34;1m\w\e[0m\n> "
# ENV color_prompt yes

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
	apt-get -y install sudo

# know the root pass
RUN echo 'root:alice!' | chpasswd

# Set up a user group
ARG username=alice
ARG id=9999
RUN groupadd -g ${id} ${username} \
	&& useradd --no-create-home --home-dir /alisoft -u ${id} -g ${username} ${username} \
	&& echo "${username}:${username}!" | chpasswd \
	&& adduser ${username} sudo
#    && useradd --create-home --home-dir /home/${username} -u ${id} -g ${username} ${username}
USER ${username}
# ENV HOME /home/${username}
ENV HOME /alisoft
WORKDIR ${HOME}

COPY ./alisoft/_bash_aliases /home/${username}/.bash_aliases

# ENTRYPOINT [ "/bin/bash", "-i" ]
ENTRYPOINT [ "/alisoft/_alidocko2shell.sh" ]