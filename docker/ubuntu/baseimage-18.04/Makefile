VERSION=0.3.0

all: build

build: Dockerfile bootstrap.sh
	docker build --rm=true -t $(REGISTRY)$(USER)/kobase-18.04:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)$(USER)/kobase-18.04:$(VERSION) bash -l

push:
	docker push $(REGISTRY)$(USER)/kobase-18.04:$(VERSION)

.PHONY: all clean test push shell
