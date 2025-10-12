DEFAULT_IMAGE_BASE     = $(REGISTRY)/$(NAMESPACE)/kobase:0.5.2-22.04
DEFAULT_IMAGE_PLATFORM = x86_64
DEFAULT_IMAGE_SHELL    = bash -l
DEFAULT_IMAGE_USER     = ko
DEFAULT_IMAGE_WORKDIR  = /home/$(IMAGE_USER)

UBUNTU_IMAGE = docker.io/library/ubuntu:jammy

define DEFAULT_IMAGE_PRE
USER 0
WORKDIR $${WORKDIR}
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]
endef

define DEFAULT_IMAGE_POST
RUN apt-get clean
RUN rm -rf \
	/tmp/* \
	/usr/share/doc/ \
	/usr/share/fonts/ \
	/var/cache/* \
	/var/lib/apt/lists/* \
	/var/tmp/* \
	;
RUN dpkg-query -W -f='$${Installed-Size;8}  $${Package}\n' | sort -n
endef

include ../rules.mk
