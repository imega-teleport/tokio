# Build rootfs for tokio

TELEPORT_FILEMAN ?= imegateleport/tokio
TELEPORT_EXTRACTOR ?= imegateleport/vigo
TELEPORT_PARSER ?= imegateleport/oslo

build: build-fs
	@docker build -t $(TELEPORT_FILEMAN) .

push:
	@docker push $(TELEPORT_FILEMAN):latest

build_dir:
	@-mkdir -p $(CURDIR)/build

build-fs: build_dir
	@docker run --rm \
		-v $(CURDIR)/runner:/runner \
		-v $(CURDIR)/build:/build \
		-v $(CURDIR)/src:/src \
		imega/base-builder:1.1.1 \
		--packages="busybox rsync inotify-tools"

get_containers:
	$(eval CONTAINERS := $(subst build/containers/,,$(shell find build/containers -type f)))

stop: get_containers
	@-docker stop $(CONTAINERS)

clean: stop
	@-docker rm -fv $(CONTAINERS)
	@-rm -rf build/containers/*

data_dir:
	@-mkdir -p $(CURDIR)/data/zip $(CURDIR)/data/parse $(CURDIR)/data/storage
	@-chmod -R 777 $(CURDIR)/data

build/containers/teleport_fileman:
	@mkdir -p $(shell dirname $@)
	@docker run -d \
		--name teleport_fileman \
		--restart=always \
		-v $(CURDIR)/data:/data \
		$(TELEPORT_FILEMAN)
	@touch $@

build/containers/teleport_extractor:
	@mkdir -p $(shell dirname $@)
	@docker run -d \
		--name teleport_extractor \
		--restart=always \
		--link teleport_fileman:fileman \
		$(TELEPORT_EXTRACTOR)
	@touch $@

build/containers/teleport_parser:
	@mkdir -p $(shell dirname $@)
	@docker run -d \
		--name teleport_parser \
		--restart=always \
		-v $(CURDIR)/data/parse:/data \
		--link teleport_fileman:fileman \
		$(TELEPORT_PARSER)
	@touch $@

discovery_extractor:
	@while [ "`docker inspect -f {{.State.Running}} teleport_extractor`" != "true" ]; do \
		@echo "wait teleport_extractor"; sleep 0.3; \
	done
	$(eval IP := $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' teleport_extractor))
	@docker exec teleport_fileman sh -c 'echo -e "$(IP)\textractor" >> /etc/hosts'

discovery_parser:
	@while [ "`docker inspect -f {{.State.Running}} teleport_parser`" != "true" ]; do \
		@echo "wait teleport_parser"; sleep 0.3; \
	done
	$(eval IP := $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' teleport_parser))
	@docker exec teleport_fileman sh -c 'echo -e "$(IP)\tparser" >> /etc/hosts'

build/containers/teleport_tester:
	@cd tests;docker build -t imegateleport/tokio_tester .

containers: build/containers/teleport_fileman \
	build/containers/teleport_extractor \
	build/containers/teleport_parser \
	build/containers/teleport_tester

test: data_dir containers discovery_extractor discovery_parser
	@docker run --rm \
		--link teleport_fileman:fileman \
		-v $(CURDIR)/tests/fixtures:/data \
		imegateleport/tokio_tester \
		rsync --inplace -av /data/9915e49a-4de1-41aa-9d7d-c9a687ec048d rsync://fileman/zip
	@sleep 1
	@if [ `ls data/storage/9915e49a-4de1-41aa-9d7d-c9a687ec048d/ | wc -l` != 6 ];then \
		exit 1; \
	fi

.PHONY: build
