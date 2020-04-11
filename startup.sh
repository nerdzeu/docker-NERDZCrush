#!/usr/bin/env bash

cd /home/mediacrush/MediaCrush
if [ ! -d venv ]; then
    virtualenv --python=python2 venv
    source venv/bin/activate
    pip2 install --ignore-installed six
    pip2 install -r requirements.txt
fi

source venv/bin/activate

if [ ! -d /home/mediacrush/storage ]; then
    mkdir /home/mediacrush/storage
fi

python compile_static.py

celery worker -A mediacrush -Q celery,priority &
PORT=9999 gunicorn -w 4 app:app
