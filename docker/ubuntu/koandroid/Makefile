VERSION=0.7.0
REGISTRY?=docker.io
JDK=8
NDK=android-ndk-r23c
NDK_SUM=e5053c126a47e84726d9f7173a04686a71f9a67a
SDK=4333796
SDK_SUM=aa190cfd7299cd6a1c687355bb2764e4

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
