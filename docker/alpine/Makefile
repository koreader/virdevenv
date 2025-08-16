BASEIMAGE = alpine:3.22.1
IMAGE_SHELL = sh -l
IMAGE_USER = 0
IMAGE_WORKDIR = /

define IMAGE_POST_CLEANUP
RUN rm -rf /root/.cache
RUN rm -rf /var/cache/apk/*
endef

include ../rules.mk
