VERSION=0.3.3-20.04
REGISTRY?=docker.io
X_TOOLS_VERSION=2021.12

all: build

build: Dockerfile
	docker build \
		--build-arg REGISTRY=$(REGISTRY) \
		--build-arg X_TOOLS_VERSION=$(X_TOOLS_VERSION) \
		--rm=true -t $(REGISTRY)/$(USER)/kokobo:$(VERSION) --file=Dockerfile ..

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/kokobo:$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/kokobo:$(VERSION)

.PHONY: all clean test push shell
