FROM base/archlinux
MAINTAINER Paolo Galeone <nessuno@nerdz.eu>

RUN sed -i -e 's#https://mirrors\.kernel\.org#http://mirror.us.leaseweb.net#g' /etc/pacman.d/mirrorlist && \
       pacman -Sy haveged archlinux-keyring --noconfirm && haveged -w 1024 -v 1 && \
       pacman-key --init && pacman-key --populate archlinux

RUN yes | pacman -S lzo

RUN pacman -Su sudo base-devel nginx subversion libunistring git imagemagick python2 python-virtualenv \
        nodejs libjpeg-turbo texlive-bin tidyhtml optipng \
        libtheora libvorbis libx264 libvpx redis python-pip wget ghostscript openexr openjpeg2 libwmf \
        librsvg libxml2 libwebp ladspa  libvdpau yasm hardening-wrapper yajl --noconfirm

RUN pacman-db-upgrade

RUN useradd -m -s /bin/bash mediacrush && echo "mediacrush ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER mediacrush

RUN cd /tmp && curl -O https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz && \
        tar zxvf package-query.tar.gz && cd package-query && makepkg

USER root
RUN pacman -U /tmp/package-query/*.xz --noconfirm

USER mediacrush
RUN  cd /tmp && curl -O https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz && tar zxvf yaourt.tar.gz && \
        cd yaourt && makepkg

RUN sudo pacman -U /tmp/yaourt/*.xz --noconfirm

RUN yaourt -S libaacplus libsndfile libbs2b opencl-headers20 libutvideo-git shine vo-aacenc vo-amrwbenc --noconfirm

RUN mkdir /tmp/deck

COPY decklink-pkgbuild /tmp/deck/PKGBUILD

RUN yaourt -S glu qt4 --noconfirm

RUN cd /tmp/deck && makepkg && sudo pacman -U decklink-sdk*.xz --noconfirm

RUN mkdir /tmp/libubv

COPY libutvideo-pkgbuild /tmp/libubv/PKGBUILD

RUN cd /tmp/libubv && makepkg && sudo pacman -U libut*.xz --noconfirm

RUN cd /tmp && yaourt -G ffmpeg-full && cd ffmpeg-full && makepkg --skippgpcheck --noconfirm -s

USER root

RUN yes | pacman -U /tmp/ffmpeg-full/*.xz
RUN pacman -S python2-pip python2-celery python2-flask jhead librsvg npm --noconfirm && npm install -g coffee-script

RUN sed -i '/mediacrush/d' /etc/sudoers

EXPOSE 81

VOLUME /home/mediacrush

COPY startup.sh /opt/

ENTRYPOINT bash /opt/startup.sh
