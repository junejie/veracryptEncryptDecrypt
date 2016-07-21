FROM ubuntu:16.04
MAINTAINER junejieruzol1@gmail.com

COPY test.sh build/test/
COPY docker/main.sh build/src/
RUN ls -lh build/test
RUN ls -lh build/src
RUN useradd -r -s /bin/bash  junejie
RUN usermod -aG sudo junejie
RUN apt-get update
RUN apt-get -y install sudo git git-core build-essential checkinstall
RUN sudo bash -c 'echo "junejie ALL=(ALL:ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)'