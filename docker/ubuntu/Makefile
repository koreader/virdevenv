BASEIMAGE ?= koreader/kobase:0.4.2-22.04
X_TOOLS_VERSION ?= 2025.05

define USAGE_EXTRA
	X_TOOLS_VERSION       x-tools version (default: $(X_TOOLS_VERSION))
endef

define IMAGE_POST_CLEANUP
RUN sudo apt-get clean
RUN sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
endef

include ../rules.mk
