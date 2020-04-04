#!/usr/bin/env bash

chown -R mediacrush:mediacrush /home/mediacrush

if [ ! -d /home/mediacrush/MediaCrush ]; then
    cd /home/mediacrush
    git clone https://github.com/nerdzeu/NERDZCrush MediaCrush
fi

cd /home/mediacrush/MediaCrush

virtualenv . --python=python2
source bin/activate
pip2 install -r requirements.txt

if [ ! -d /home/mediacrush/storage ]; then
    mkdir /home/mediacrush/storage
fi

source bin/activate
python compile_static.py

celery worker -A mediacrush -Q celery,priority &
PORT=9999 gunicorn -w 4 app:app
