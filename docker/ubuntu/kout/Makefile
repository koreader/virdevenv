VERSION=0.0.1

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kout:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kobase-python:$(VERSION) bash -l

push:
	docker push $(USER)/kout:$(VERSION)
