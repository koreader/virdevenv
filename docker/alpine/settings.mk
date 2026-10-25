DEFAULT_IMAGE_PLATFORM = x86_64
DEFAULT_IMAGE_SHELL    = bash -l
DEFAULT_IMAGE_USER     = ko
DEFAULT_IMAGE_WORKDIR  = /home/$(IMAGE_USER)

ALPINE_IMAGE = alpine:3.24

define DEFAULT_IMAGE_PRE
USER 0
WORKDIR /root
ARG TARGETPLATFORM
RUN apk update
RUN apk add bash
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]
endef

define DEFAULT_IMAGE_POST
RUN rm -rf /var/cache/*
RUN apk list --installed --quiet | xargs apk info --size | tac \
    | sed '/^ *$$/d;N;s/ \([KBM]\)\(iB\)\?/\1/;s/\n/\t/;s/ installed size:$$//' \
    | xargs -n256 printf '%5s %s\n' | sort -h
endef

define DEFAULT_IMAGE_ENV
PATH=/usr/lib/ninja-build/bin:$${PATH}
endef
