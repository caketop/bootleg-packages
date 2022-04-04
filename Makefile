ostree:
	mkdir -p output/ostree
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/ostree ostree

msmtp:
	mkdir -p output/msmtp
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/msmtp msmtp

python:
	mkdir -p output/python
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/python python

.PHONY: msmtp ostree python
