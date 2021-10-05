VERSION=0.2.2

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/koappimage:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/koappimage:$(VERSION) bash -l

push:
	docker push $(USER)/koappimage:$(VERSION)

.PHONY: all clean test push shell
