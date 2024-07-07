VERSION=0.3.4-20.04
REGISTRY?=docker.io

all: build

build: Dockerfile
	docker build --build-arg REGISTRY=$(REGISTRY) --rm=true -t $(REGISTRY)/$(USER)/kobase-clang:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/kobase-clang:$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/kobase-clang:$(VERSION)

.PHONY: all clean test push shell
