VERSION=0.2.3

all: build

build: Dockerfile
	docker build --rm=true -t $(REGISTRY)$(USER)/koremarkable:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)$(USER)/koremarkable:$(VERSION) bash -l

push:
	docker push $(REGISTRY)$(USER)/koremarkable:$(VERSION)

.PHONY: all clean test push shell
