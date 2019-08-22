VERSION=0.1.4

all: build

build: Dockerfile bootstrap.sh
	docker build --rm=true -t $(USER)/kobase:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kobase:$(VERSION) bash -l

push:
	docker push $(USER)/kobase:$(VERSION)
