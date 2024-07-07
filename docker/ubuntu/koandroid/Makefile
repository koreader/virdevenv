VERSION=0.8.2-20.04
REGISTRY?=docker.io
JDK=17
NDK=android-ndk-r23c
NDK_SUM=e5053c126a47e84726d9f7173a04686a71f9a67a
SDK=10406996_latest
SDK_SUM=87b485c7283cba69e41c10f05bf832d2fd691552

all: build

build: Dockerfile
	docker build \
		--build-arg REGISTRY=$(REGISTRY) \
		--build-arg JDK=$(JDK) \
		--build-arg NDK=$(NDK) \
		--build-arg NDK_SUM=$(NDK_SUM) \
		--build-arg SDK=$(SDK) \
		--build-arg SDK_SUM=$(SDK_SUM) \
		--rm=true -t $(REGISTRY)/$(USER)/koandroid:$(VERSION) .

shell:
	docker run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/koandroid:$(VERSION) bash -l

push:
	docker push $(REGISTRY)/$(USER)/koandroid:$(VERSION)

.PHONY: all clean test push shell
