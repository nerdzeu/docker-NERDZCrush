#!/usr/bin/env bash

if [ ! -d /home/mediacrush/MediaCrush ]; then
    cd /home/mediacrush
    git clone http://github.com/MediaCrush/MediaCrush
    cd MediaCrush

    virtualenv . --python=python2
    source bin/activate
    pip2 install -r requirements.txt
fi

if [ ! -d /home/mediacrush/storage ]; then
    mkdir /home/mediacrush/storage
fi

cd /home/mediacrush/MediaCrush

source bin/activate
python compile_static.py

celery worker -A mediacrush -Q celery,priority &
PORT=81 gunicorn -w 4 app:app
