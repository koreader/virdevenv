VERSION=0.1.1

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kokindle:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kokindle:$(VERSION) bash -l

push:
	docker push $(USER)/kokindle:$(VERSION)

.PHONY: all clean test push shell
