#!/bin/sh
inotifywait -e modify,move,create,delete -mr --timefmt '%d/%m/%y %H:%M' --format '%T %f %e' \
/www/nginx/conf/conf.d | while read event; do
    echo "$event"
    /www/nginx/sbin/nginx -s reload
done