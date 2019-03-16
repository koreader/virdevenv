VERSION=0.1.2

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kopb:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kopb:$(VERSION) bash -l

push:
	docker push $(USER)/kopb:$(VERSION)
