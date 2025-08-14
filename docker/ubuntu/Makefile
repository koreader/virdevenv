.DEFAULT: usage
.SILENT:

BUILDER ?= docker
REGISTRY ?= docker.io
BASEIMAGE ?= koreader/kobase:0.4.2-22.04
X_TOOLS_VERSION ?= 2025.05

IMAGES = $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))

PHONIES = all prune

# Docker support. {{{

define docker_build
docker build
endef

# }}}

# Podman support. {{{

define podman_build
buildah build --format=docker --layers
endef

# }}}

# Image rules. {{{

define image_build
	$($(BUILDER)_build)
	--build-arg REGISTRY=$(REGISTRY) --build-arg BASE=$(BASE)
	$(patsubst %,--build-arg %,$(strip $(BUILD_ARGS)))
	-t $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)
	--file - .
endef

define image_rules
$(eval IMAGE := $1)
$(eval VERSION := )
$(eval BASE := )
$(eval BUILD_ARGS := )
$(eval include $1/settings.mk)
ifeq (,$$(VERSION))
$$(error $1/settings.mk does not define a VERSION)
endif
ifeq (,$$(BASE))
$$(error $1/settings.mk does not define a BASE)
endif

.PHONY: $1 $1/ $1/push $1/shell $1/latest

$1 $1/: $1/Dockerfile
	cat Dockerfile.pre $1/Dockerfile Dockerfile.post | $(strip $(call image_build,$1))

ifeq (docker,$(BUILDER))
$1/latest:
	$(BUILDER) buildx imagetools create $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) --tag $(REGISTRY)/$(USER)/$(IMAGE):latest
endif

$1/push:
	$(BUILDER) push $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)

$1/shell:
	$(BUILDER) run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) bash -l

PHONIES += $1 $1/ $1/push $1/shell $1/latest

endef

# }}}

# Usage. {{{

define newline


endef

define USAGE

USAGE

  TARGETS:
	make IMAGE            build image
	make IMAGE/shell      run interactive shell in image
	make IMAGE/push       push image to registry
	make IMAGE/lastest    tag image version has latest (docker only)
	make prune            prune dangling images

  VARIABLES:
	USER                  repository name (e.g. koreader, default: $(USER))
	REGISTRY              remote registry to push too (default: $(REGISTRY))
	BASEIMAGE             default base image (default: $(BASEIMAGE))
	X_TOOLS_VERSION       x-tools version (default: $(X_TOOLS_VERSION))

  IMAGES:$(newline)$(foreach i,$(IMAGES),	$(i)$(newline))
endef

usage:
	$(info $(USAGE))

# }}}

prune:
	$(BUILDER) system prune -f

$(foreach i,$(IMAGES),$(eval $(call image_rules,$i)))

LEFTOVERS = $(filter-out $(PHONIES),$(MAKECMDGOALS))

$(LEFTOVERS):
	$(error no rule to make target '$@')

.PHONY: $(LEFTOVERS) $(PHONIES)

# vim: foldmethod=marker foldlevel=0
