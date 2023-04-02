VERSION=0.3.0

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kobase-clang:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kobase-clang:$(VERSION) bash -l

push:
	docker push $(USER)/kobase-clang:$(VERSION)

.PHONY: all clean test push shell
