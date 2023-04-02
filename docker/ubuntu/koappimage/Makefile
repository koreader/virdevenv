VERSION=0.3.0

all: build

build: Dockerfile
	docker build --rm=true -t $(REGISTRY)$(USER)/koappimage:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)$(USER)/koappimage:$(VERSION) bash -l

push:
	docker push $(REGISTRY)$(USER)/koappimage:$(VERSION)

.PHONY: all clean test push shell
