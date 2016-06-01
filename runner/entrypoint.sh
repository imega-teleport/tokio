#!/bin/bash -x
#/usr/bin/env bash
mkdir -p $ROOTFS/var/run
mkdir -p $ROOTFS/app

cp $SRC/daemon.sh $ROOTFS/app/daemon.sh
chmod +x $ROOTFS/app/daemon.sh
cp $SRC/wait-list.txt $ROOTFS/app/wait-list.txt

cp $SRC/supervisord.conf $ROOTFS/etc/supervisord.conf
cp $SRC/rsyncd.conf $ROOTFS/etc/rsyncd.conf

