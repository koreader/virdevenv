VERSION=0.0.1

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/koandroid:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/koandroid:$(VERSION) bash -l
