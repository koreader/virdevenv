VERSION=0.0.1

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/kokobo:$(VERSION) .

shell:
	docker run --rm -t -i $(USER)/kokobo:$(VERSION) bash -l
