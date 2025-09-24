TOP := $(abspath ../$(dir $(lastword $(MAKEFILE_LIST))))

.DEFAULT: usage
.SILENT:

DRY_RUN := $(findstring n,$(firstword -$(MAKEFLAGS)))

BUILDER ?= docker
REGISTRY ?= docker.io
PLATFORM ?=

define DOCKERFILE
# Automatically generated, do not edit!

# PRE {{{

ARG BASE=scratch
FROM $${BASE} AS build
ARG USER WORKDIR
$(IMAGE_PRE)

# }}}

# $< {{{

$(file <$1)

# }}}

# POST {{{

# hadolint ignore=DL3002
USER 0
$(IMAGE_POST)
FROM scratch AS final
COPY --from=build / /
ARG USER WORKDIR
USER $${USER}
WORKDIR $${WORKDIR}

# }}}

CMD $(or $(IMAGE_CMD),$(call to_json_array,$(IMAGE_SHELL)))

# vim: foldmethod=marker foldlevel=0 sw=4
endef

IMAGES = $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))

PHONIES = all lint prune

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

platform_arg = $(if $(PLATFORM),--platform $(PLATFORM))

define image_build
	$($(BUILDER)_build)
	$(platform_arg)
	--build-arg BASE=$(IMAGE_BASE)
	--build-arg USER=$(IMAGE_USER)
	--build-arg WORKDIR=$(IMAGE_WORKDIR)
	$(patsubst %,--build-arg %,$(strip $(BUILD_ARGS)))
	-t $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)
	--progress plain
	--file
endef

comma = ,
shell_escape = '$(subst ','\'',$1)'
to_json_array = [$(patsubst %,"%"$(comma),$(wordlist 2,$(words $1),1 $1)) "$(lastword $1)"]

define image_rules
$(eval IMAGE := $1)
$(eval VERSION := )
$(foreach v,BUILD_ARGS IMAGE_BASE IMAGE_CMD IMAGE_POST IMAGE_PRE IMAGE_SHELL IMAGE_USER IMAGE_WORKDIR,
$(eval $v := $$(DEFAULT_$v))
)
$(eval include $1/settings.mk)
$(foreach v,IMAGE_BASE IMAGE_SHELL VERSION,
ifeq (,$$($v))
$$(error $1: $v not defined)
endif
)

$1_DOCKERFILE := $$(call DOCKERFILE,$1/Dockerfile)

build/$1.dockerfile: | build/
ifneq (,$$(DRY_RUN))
	$$(info cat >$$@ <<'DOCKERFILE_EOF'$$(newline)$$($1_DOCKERFILE)$$(newline)DOCKERFILE_EOF)
else
	$$(file >$$@,$$($1_DOCKERFILE))
endif

$1 $1/: build/$1.dockerfile
	$(strip $(call image_build,$1)) $$< .

$1/inspect:
	$(BUILDER) image inspect $(platform_arg) $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) | jq --sort-keys

$1/hadolint: build/$1.dockerfile
	hadolint --config $(TOP)/.hadolint.yaml $$<

ifeq (docker,$(BUILDER))
$1/latest:
	$(BUILDER) buildx imagetools create $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) --tag $(REGISTRY)/$(USER)/$(IMAGE):latest
endif

$1/lint: $1/hadolint

$1/push:
	$(BUILDER) push $(platform_arg) $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)

$1/run:
	$(BUILDER) run $(platform_arg) --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)

$1/shell:
	$(BUILDER) run $(platform_arg) --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) $(IMAGE_SHELL)

PHONIES += $1 $1/ $1/hadolint $1/latest $1/lint $1/inspect $1/push $1/run $1/shell build/$1.dockerfile

endef

# }}}

# Usage. {{{

define newline


endef

define USAGE
TARGETS:
	make IMAGE            build image
	make IMAGE/inspect    inspect image
	make IMAGE/run        run image
	make IMAGE/shell      run interactive shell in image
	make IMAGE/push       push image to registry
	make IMAGE/lastest    tag image version has latest (docker only)
	make prune            prune dangling images

VARIABLES:
	USER                  repository name (e.g. koreader, default: $(USER))
	REGISTRY              remote registry to push too (default: $(REGISTRY))
	PLATFORM              platform to build the image for (default: current system)

IMAGES:$(foreach i,$(IMAGES),$(newline)	$(i))
endef

usage:
	$(info $(USAGE))

# }}}

prune:
	$(BUILDER) system prune -f

build/:
	mkdir -p $@

$(foreach i,$(IMAGES),$(eval $(call image_rules,$i)))

hadolint: $(IMAGES:%=%/hadolint)

lint: $(IMAGES:%=%/lint)

.PHONY: $(PHONIES)

# vim: foldmethod=marker foldlevel=0
