VERSION=0.2.2

all: build

build: Dockerfile
	docker build --rm=true -t $(REGISTRY)$(USER)/kobase-python:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)$(USER)/kobase-python:$(VERSION) bash -l

push:
	docker push $(REGISTRY)$(USER)/kobase-python:$(VERSION)

.PHONY: all clean test push shell
