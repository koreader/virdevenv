VERSION=0.5.3

all: build

build: Dockerfile
	docker build --rm=true -t $(REGISTRY)$(USER)/koandroid:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)$(USER)/koandroid:$(VERSION) bash -l

push:
	docker push $(REGISTRY)$(USER)/koandroid:$(VERSION)

.PHONY: all clean test push shell
