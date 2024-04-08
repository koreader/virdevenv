VERSION=0.3.1-20.04
REGISTRY?=docker.io

all: build

build:
	docker build --build-arg REGISTRY=$(REGISTRY) --rm=true -t $(REGISTRY)/$(USER)/kobase:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/kobase:$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/kobase:$(VERSION)

.PHONY: all clean test push shell
