VERSION=0.0.1

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kokindle:$(VERSION) .

shell:
	docker --detach-keys "ctrl-q,ctrl-q" run --rm -t -i $(USER)/kokindle:$(VERSION) bash -l
