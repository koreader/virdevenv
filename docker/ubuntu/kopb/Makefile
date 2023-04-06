VERSION=0.3.3
REGISTRY?=docker.io

all: build

build: Dockerfile
	docker build --build-arg REGISTRY=$(REGISTRY) --rm=true -t $(REGISTRY)/$(USER)/kopb:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/kopb:$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/kopb:$(VERSION)

.PHONY: all clean test push shell
