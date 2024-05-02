NAME = kodeb
VERSION = 0.1.0-20.04
REGISTRY ?= docker.io

all: build

build: Dockerfile
	docker build --build-arg REGISTRY=$(REGISTRY) --rm=true -t $(REGISTRY)/$(USER)/$(NAME):$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/$(NAME):$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/$(NAME):$(VERSION)

.PHONY: all clean test push shell
