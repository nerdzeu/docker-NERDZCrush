#!/usr/bin/env bash

cd /home/mediacrush/MediaCrush
if [ ! -d venv ]; then
    virtualenv --python=python3 venv
    source venv/bin/activate
    pip3 install --ignore-installed six
    pip3 install -r requirements.txt
fi

source venv/bin/activate

if [ ! -d storage ]; then
    mkdir storage
fi

python compile_static.py

celery worker -A mediacrush -Q celery,priority &
PORT=9999 gunicorn -w 2 app:app
