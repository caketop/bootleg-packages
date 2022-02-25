.PHONY: ostree
ostree:
	mkdir -p output/ostree
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/ostree ostree

.PHONY: msmtp
msmtp:
	mkdir -p output/msmtp
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/msmtp msmtp
