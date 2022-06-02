VERSION=0.3.0

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/koremarkable:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/koremarkable:$(VERSION) bash -l

push:
	docker push $(USER)/koremarkable:$(VERSION)

.PHONY: all clean test push shell
