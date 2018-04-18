VERSION=0.0.6

all: build

build: Dockerfile bootstrap.sh
	docker build --rm=true -t $(USER)/kobase:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(USER)/kobase:$(VERSION) bash -l
