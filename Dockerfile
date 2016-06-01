FROM imega/base-builder:1.2.0

MAINTAINER Dmitry Gavriloff <info@imega.ru>

EXPOSE 873

ADD build/rootfs.tar.gz /

CMD ["/app/daemon.sh"]
