IMAGE = kobase
VERSION = 0.3.3-20.04
REGISTRY ?= docker.io

all: build

build:
	docker build --build-arg REGISTRY=$(REGISTRY) --rm=true -t $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)

.PHONY: all clean test push shell
