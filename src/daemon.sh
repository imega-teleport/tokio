#!/bin/sh

/usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf &

inotifywait -mr -e close_write --fromfile /app/wait-list.txt | while read DEST EVENT FILE
do
    SERVICE=`echo $DEST | cut -d"/" -f3`
    UUID=`echo $(basename "$DEST")`
    case "$SERVICE" in
        "zip")
            rsync --inplace -av $DEST$FILE rsync://extractor:873/data/$UUID/
        ;;
        "parse")
            rsync --inplace -av $DEST$FILE rsync://parser:873/data/$UUID/
        ;;
    esac
done
