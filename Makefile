# Build rootfs for composer

build:
	@docker run --rm \
		-v $(CURDIR)/runner:/runner \
		-v $(CURDIR)/build:/build \
		-v $(CURDIR)/src:/src \
		imega/base-builder:1.1.1 \
		--packages="supervisor rsync incron@testing" \
		-d="curl"

.PHONY: build
