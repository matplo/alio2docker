# our base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
	apt-get -y install gcc git 
	
RUN apt-get -y install curl libcurl4-gnutls-dev build-essential gfortran libmysqlclient-dev xorg-dev libglu1-mesa-dev libfftw3-dev libxml2-dev git unzip autoconf automake autopoint texinfo gettext libtool libtool-bin pkg-config bison flex libperl-dev libbz2-dev swig liblzma-dev libnanomsg-dev rsync lsb-release environment-modules libglfw3-dev libtbb-dev python3-dev python3-venv libncurses-dev software-properties-common

RUN add-apt-repository ppa:alisw/ppa  
RUN apt update
RUN apt -y install python3-alibuild

RUN apt-get -y install emacs vim nano

ENV LANG en_US.utf8

SHELL ["/bin/bash", "-c"]

# COPY ./alidocko2shell.sh /usr/bin
# RUN chmod +x /usr/bin/alidocko2shell.sh
# RUN /bin/bash /usr/bin/alidocko2shell.sh
# CMD /alisoft/alidocko2shell.sh

ENTRYPOINT [ "/bin/bash" ]
SHELL ["export PS1=\"(o2dock)\e[32;1m[\u\e[31;1m@\h\e[32;1m]\e[34;1m\w\e[0m\n> \""]
