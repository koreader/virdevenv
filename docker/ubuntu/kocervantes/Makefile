VERSION=0.1.1

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kocervantes:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kocervantes:$(VERSION) bash -l

push:
	docker push $(USER)/kocervantes:$(VERSION)

.PHONY: all clean test push shell
