.PHONY: ostree
ostree:
	mkdir -p output/ostree
	docker buildx build --pull $(BUILDX_ARGS) --output type=local,dest=./output/ostree ostree
