FROM base/archlinux
MAINTAINER Paolo Galeone <nessuno@nerdz.eu>

RUN sed -i -e 's#https://mirrors\.kernel\.org#http://mirror.clibre.uqam.ca#g' /etc/pacman.d/mirrorlist && \
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

RUN sudo pacman -S dirmngr --noconfirm && sudo dirmngr </dev/null && sudo pacman-key --keyserver pgp.mit.edu -r D67658D8 && sudo pacman-key -f D67658D8 && \
    sudo pacman-key --lsign-key D67658D8 && sudo pacman -Syy

RUN yaourt -S libaacplus libsndfile libbs2b opencl-headers12 libutvideo-git shine vo-aacenc vo-amrwbenc --noconfirm
RUN yaourt -S decklink-sdk --noconfirm

RUN cd /tmp && yaourt -G ffmpeg-full && cd ffmpeg-full && makepkg --skippgpcheck --noconfirm -s

USER root
RUN yes | pacman -U /tmp/ffmpeg-full/*.xz

USER mediacrush

WORKDIR /home/mediacrush
RUN git clone http://github.com/MediaCrush/MediaCrush && cd MediaCrush && virtualenv . --no-site-packages --python=python2 && source bin/activate && sudo pip install -r requirements.txt
RUN sudo npm install -g coffee-script

RUN sudo pacman -S python2-celery --noconfirm

USER root
RUN sed -i '/mediacrush/d' /etc/sudoers

EXPOSE 80 443

# mount the config.ini file to /home/mediacrush/MediaCrush/config.ini

ENTRYPOINT celery worker -A mediacrush -Q celery,priority && python2 /home/mediacrush/MediaCrush/compile_static.py && python2 /home/mediacrush/MediaCrush/app.py
