VERSION=0.0.3

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kokobo:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kokobo:$(VERSION) bash -l

push:
	docker push $(USER)/kokobo:$(VERSION)
