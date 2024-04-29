VERSION=0.4.1-20.04
REGISTRY?=docker.io
X_TOOLS_VERSION=2021.12

all: build

build: Dockerfile
	docker build \
		--build-arg REGISTRY=$(REGISTRY) \
		--build-arg X_TOOLS_VERSION=$(X_TOOLS_VERSION) \
		--rm=true -t $(REGISTRY)/$(USER)/kopb:$(VERSION) --file=Dockerfile ..

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/kopb:$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/kopb:$(VERSION)

.PHONY: all clean test push shell
