VERSION=0.0.1

all: build

build: Dockerfile
	docker build --rm=true -t $(USER)/koandroid:$(VERSION) .

shell:
	docker run --rm -t -i $(USER)/koandroid:$(VERSION) bash -l
