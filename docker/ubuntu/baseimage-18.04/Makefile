VERSION=0.3.0
REGISTRY?=docker.io

all: build

build: Dockerfile bootstrap.sh
	docker build --build-arg REGISTRY=$(REGISTRY) --rm=true -t $(REGISTRY)/$(USER)/kobase-18.04:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/kobase-18.04:$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/kobase-18.04:$(VERSION)

.PHONY: all clean test push shell
