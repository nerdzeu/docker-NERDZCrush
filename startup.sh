#!/usr/bin/env bash

if [ ! -d /home/mediacrush/MediaCrush ]; then
    cd /home/mediacrush
    git clone http://github.com/MediaCrush/MediaCrush
fi

celery2 worker -A mediacrush -Q celery,priority && python2 /home/mediacrush/MediaCrush/compile_static.py && python2 /home/mediacrush/MediaCrush/app.py
