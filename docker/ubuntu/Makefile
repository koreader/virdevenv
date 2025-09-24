DEFAULT_IMAGE_BASE    = $(REGISTRY)/$(USER)/kobase:0.5.0-22.04
DEFAULT_IMAGE_SHELL   = bash -l
DEFAULT_IMAGE_USER    = ko
DEFAULT_IMAGE_WORKDIR = /home/$(IMAGE_USER)

define DEFAULT_IMAGE_POST_CLEANUP
RUN apt-get clean
RUN rm -rf \
	/tmp/* \
	/usr/share/doc/ \
	/usr/share/fonts/ \
	/var/cache/* \
	/var/lib/apt/lists/* \
	/var/tmp/* \
	;
endef

X_TOOLS_VERSION = 2025.05

include ../rules.mk
