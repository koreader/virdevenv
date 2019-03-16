VERSION=0.1.2

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kobase-python:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kobase-python:$(VERSION) bash -l

push:
	docker push $(USER)/kobase-python:$(VERSION)
