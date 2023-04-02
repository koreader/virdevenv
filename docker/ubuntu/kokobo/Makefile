VERSION=0.2.3

all: build

build: Dockerfile
	docker build --rm=true -t $(REGISTRY)$(USER)/kokobo:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)$(USER)/kokobo:$(VERSION) bash -l

push:
	docker push $(REGISTRY)$(USER)/kokobo:$(VERSION)

.PHONY: all clean test push shell
