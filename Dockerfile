FROM registry.gitlab.steamos.cloud/steamrt/sniper/platform
LABEL author="BuSheeZy"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

ARG DEBIAN_FRONTEND=noninteractive
RUN sudo apt update; sudo apt install software-properties-common; sudo apt-add-repository non-free; sudo dpkg --add-architecture i386; sudo apt update
RUN sudo apt install -y steamcmd jq

RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd
RUN steamcmd +quit

VOLUME $HOME/gs

COPY entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]