.DEFAULT: usage
.SILENT:

DRY_RUN := $(findstring n,$(firstword -$(MAKEFLAGS)))

BUILDER ?= docker
REGISTRY ?= docker.io

define DOCKERFILE
# Automatically generated, do not edit!

# PRE {{{

ARG REGISTRY=docker.io
ARG BASE=scratch
FROM $${REGISTRY}/$${BASE} AS build
ARG USER WORKDIR

# }}}

# $< {{{

$(file <$1)

# }}}

# POST {{{

USER 0
$(IMAGE_POST_CLEANUP)
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
	--build-arg REGISTRY=$(REGISTRY) --build-arg BASE=$(IMAGE_BASE)
	--build-arg USER=$(IMAGE_USER) --build-arg WORKDIR=$(IMAGE_WORKDIR)
	$(patsubst %,--build-arg %,$(strip $(BUILD_ARGS)))
	-t $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)
	--file
endef

comma = ,
shell_escape = '$(subst ','\'',$1)'
to_json_array = [$(patsubst %,"%"$(comma),$(wordlist 2,$(words $1),1 $1)) "$(lastword $1)"]

define image_rules
$(eval IMAGE := $1)
$(eval VERSION := )
$(foreach v,BUILD_ARGS IMAGE_BASE IMAGE_CMD IMAGE_POST_CLEANUP IMAGE_SHELL IMAGE_USER IMAGE_WORKDIR,
$(eval $v := $$(DEFAULT_$v))
)
$(eval include $1/settings.mk)
$(foreach v,IMAGE_BASE IMAGE_SHELL VERSION,
ifeq (,$$($v))
$$(error $1: $v not defined)
endif
)

build/$1.dockerfile: | build/
ifneq (,$$(DRY_RUN))
	$$(info cat >$$@ <<'DOCKERFILE_EOF'$$(newline)$$(call DOCKERFILE,$1/Dockerfile)$$(newline)DOCKERFILE_EOF)
else
	$$(file >$$@,$$(call DOCKERFILE,$1/Dockerfile))
endif

$1 $1/: build/$1.dockerfile
	$(strip $(call image_build,$1)) $$< .

$1/inspect:
	$(BUILDER) image inspect $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) | jq --sort-keys

ifeq (docker,$(BUILDER))
$1/latest:
	$(BUILDER) buildx imagetools create $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) --tag $(REGISTRY)/$(USER)/$(IMAGE):latest
endif

$1/push:
	$(BUILDER) push $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)

$1/run:
	$(BUILDER) run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION)

$1/shell:
	$(BUILDER) run --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(REGISTRY)/$(USER)/$(IMAGE):$(VERSION) $(IMAGE_SHELL)

PHONIES += $1 $1/ $1/inspect $1/push $1/run $1/shell $1/latest build/$1.dockerfile

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

.PHONY: $(PHONIES)

# vim: foldmethod=marker foldlevel=0
