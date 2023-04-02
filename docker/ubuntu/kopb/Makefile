VERSION=0.3.3

all: build

build: Dockerfile
	docker build --rm=true -t $(REGISTRY)$(USER)/kopb:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)$(USER)/kopb:$(VERSION) bash -l

push:
	docker push $(REGISTRY)$(USER)/kopb:$(VERSION)

.PHONY: all clean test push shell
