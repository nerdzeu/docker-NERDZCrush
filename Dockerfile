FROM base/archlinux
MAINTAINER Paolo Galeone <nessuno@nerdz.eu>

RUN sed -i -e 's#https://mirrors\.kernel\.org#http://mirror.us.leaseweb.net#g' /etc/pacman.d/mirrorlist && \
       pacman -Sy haveged archlinux-keyring --noconfirm && haveged -w 1024 -v 1 && \
       pacman-key --init && pacman-key --populate archlinux && pacman -Syy

RUN yes | pacman -S lzo

RUN pacman -Su sudo base-devel nginx subversion libunistring git imagemagick python2 python-virtualenv \
        nodejs libjpeg-turbo texlive-bin tidyhtml optipng \
        libtheora libvorbis libx264 libvpx redis python-pip wget ghostscript openexr openjpeg2 libwmf \
        librsvg libxml2 libwebp ladspa  libvdpau yasm hardening-wrapper yajl perl --noconfirm

RUN pacman-db-upgrade

RUN useradd -m -s /bin/bash mediacrush && echo "mediacrush ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER mediacrush

ENV PATH /usr/bin/core_perl:$PATH

RUN cd /tmp && curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/cower-git.tar.gz && \
        tar zxvf cower-git.tar.gz && cd cower-git && makepkg

RUN cd /tmp && curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/expac-git.tar.gz && \
        tar zxvf expac-git.tar.gz && cd expac-git && makepkg

USER root
RUN pacman -U /tmp/cower-git/*.xz /tmp/expac-git/*.xz --noconfirm

USER mediacrush
RUN  cd /tmp && curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz && tar zxvf pacaur.tar.gz && \
        cd pacaur && makepkg

RUN sudo pacman -U /tmp/pacaur/*.xz --noconfirm

RUN pacaur -S libaacplus libsndfile libbs2b opencl-headers libutvideo-git shine vo-aacenc vo-amrwbenc --noconfirm

RUN mkdir /tmp/deck

COPY decklink-pkgbuild /tmp/deck/PKGBUILD
COPY Blackmagic_DeckLink_SDK_10.3.zip /tmp/deck/

RUN pacaur -S glu qt4 --noconfirm

RUN cd /tmp/deck && makepkg && sudo pacman -U decklink-sdk*.xz --noconfirm

RUN mkdir /tmp/libubv

COPY libutvideo-pkgbuild /tmp/libubv/PKGBUILD

RUN cd /tmp/libubv && makepkg && sudo pacman -U libut*.xz --noconfirm

RUN gpg --no-tty --keyserver pgp.mit.edu --recv-keys FCF986EA15E6E293A5644F10B4322F04D67658D8
#RUN gpg --no-tty --lsign FCF986EA15E6E293A5644F10B4322F04D67658D8
RUN pacaur -S ffmpeg-full
#RUN cd /tmp/pacaurtmp-/ffmpeg-full/ && sudo pacman -U *.xz --noconfirm

USER root

RUN pacman -S python2-pip python2-celery python2-flask jhead librsvg npm --noconfirm && npm install -g coffee-script

RUN sed -i '/mediacrush/d' /etc/sudoers

EXPOSE 81

VOLUME /home/mediacrush

COPY startup.sh /opt/

USER mediacrush

ENTRYPOINT bash /opt/startup.sh
