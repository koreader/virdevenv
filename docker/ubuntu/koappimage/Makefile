VERSION=0.4.3-20.04
REGISTRY?=docker.io

all: build

build: Dockerfile
	docker build --build-arg REGISTRY=$(REGISTRY) --rm=true -t $(REGISTRY)/$(USER)/koappimage:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/koappimage:$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/koappimage:$(VERSION)

.PHONY: all clean test push shell
