#!/bin/sh

/usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf &

inotifywait -mr -e close_write --fromfile /app/wait-list.txt | while read DEST EVENT FILE
do
    SERVICE=`echo $DEST | cut -d"/" -f3`

    case "$SERVICE" in
        "zip") rsync -avP $DEST$FILE rsync://unzip:873/data
        ;;
        "unzip") echo "rsync -avP $DEST$FILE rsync://10.0.0.2:873/data"
        ;;
    esac
done
