VERSION=0.2.0

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kout:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kout:$(VERSION) bash -l

push:
	docker push $(USER)/kout:$(VERSION)

.PHONY: all clean test push shell
