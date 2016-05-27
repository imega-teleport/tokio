#!/usr/bin/env bash

cp $SRC/supervisord.conf $ROOTFS/etc/supervisord.conf
cp $SRC/rsyncd.conf $ROOTFS/etc/rsyncd.conf
cp $SRC/incrontasks.conf $ROOTFS/var/spool/incron/root
