VERSION=0.3.0

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kobookeen:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kobookeen:$(VERSION) bash -l

push:
	docker push $(USER)/kobookeen:$(VERSION)

.PHONY: all clean test push shell
