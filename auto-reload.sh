#!/bin/sh
inotifywait -e modify,move,create,delete -mr --timefmt '%d/%m/%y %H:%M' --format '%T %f %e' \
/home/nginx/conf/conf.d | while read event; do
    echo "$event"
    /home/nginx/sbin/nginx -s reload
done