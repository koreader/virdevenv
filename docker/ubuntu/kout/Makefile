VERSION=0.2.0

all: build

build: Dockerfile
	docker build --rm=true -t $(REGISTRY)$(USER)/kout:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)$(USER)/kout:$(VERSION) bash -l

push:
	docker push $(REGISTRY)$(USER)/kout:$(VERSION)

.PHONY: all clean test push shell
