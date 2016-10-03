VERSION=0.0.3

all: build

build: Dockerfile bootstrap.sh
	docker build --rm=true -t $(USER)/kobase:$(VERSION) .

shell:
	docker run --rm -t -i $(USER)/kobase:$(VERSION) bash -l
