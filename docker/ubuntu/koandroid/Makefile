VERSION=0.0.1

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/koandroid:$(VERSION) .

shell:
	docker --detach-keys "ctrl-q,ctrl-q" run --rm -t -i $(USER)/koandroid:$(VERSION) bash -l
