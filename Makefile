libguestfs:
	mkdir -p output/libguestfs
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/libguestfs libguestfs

msmtp:
	mkdir -p output/msmtp
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/msmtp msmtp

ostree:
	mkdir -p output/ostree
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/ostree ostree

ostree-ext-cli:
	mkdir -p output/ostree-ext-cli
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/ostree-ext-cli ostree-ext-cli

pygobject:
	mkdir -p output/pygobject
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/pygobject pygobject

python:
	mkdir -p output/python
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/python python

python-apt:
	mkdir -p output/python-apt
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/python-apt python-apt

.PHONY: libguestfs msmtp ostree ostree-ext-cli pygobject python python-apt
