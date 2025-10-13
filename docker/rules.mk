TOP := $(abspath ../$(dir $(lastword $(MAKEFILE_LIST))))

.DEFAULT: usage
.SILENT:

DRY_RUN := $(findstring n,$(firstword -$(MAKEFLAGS)))

REGISTRY ?= docker.io
NAMESPACE ?= $(USER)
PLATFORM ?=

REGCTL ?= regctl

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
IMAGE_IDS =
BASE_IDS =

PHONIES = all ci-matrices lint prune

# Image rules. {{{

platform_arg = $(if $(PLATFORM),--platform $(PLATFORM))

define image_build
	docker buildx build
	$(platform_arg)
	--build-arg BASE=$(IMAGE_BASE)
	--build-arg USER=$(IMAGE_USER)
	--build-arg WORKDIR=$(IMAGE_WORKDIR)
	$(patsubst %,--build-arg %,$(strip $(BUILD_ARGS)))
	--tag $(IMAGE)
	--progress plain
	--file
endef

comma = ,
shell_escape = '$(subst ','\'',$1)'
to_json_array = [$(patsubst %,"%"$(comma),$(wordlist 2,$(words $1),1 $1)) "$(lastword $1)"]
target_escape = $(subst :,\:,$1)

define image_rules
$(eval VERSION := )
$(foreach v,BUILD_ARGS IMAGE_BASE IMAGE_CMD IMAGE_PLATFORM IMAGE_POST IMAGE_PRE IMAGE_SHELL IMAGE_USER IMAGE_WORKDIR,
$(eval $v := $$(DEFAULT_$v))
)
$(eval include $1/settings.mk)
$(foreach v,IMAGE_BASE IMAGE_SHELL VERSION,
ifeq (,$$($v))
$$(error $1: $v not defined)
endif
)

$(eval IMAGE := $(REGISTRY)/$(NAMESPACE)/$1:$(VERSION))

$1_DOCKERFILE := $$(call DOCKERFILE,$1/Dockerfile)

build/$1.dockerfile: | build/
ifneq (,$$(DRY_RUN))
	$$(info cat >$$@ <<'DOCKERFILE_EOF'$$(newline)$$($1_DOCKERFILE)$$(newline)DOCKERFILE_EOF)
else
	$$(file >$$@,$$($1_DOCKERFILE))
endif

IMAGE_IDS += $(IMAGE)
BASE_IDS += $(IMAGE_BASE)

$1 $1/: build/$1.dockerfile
	$(strip $(call image_build,$1)) $$< .

$(call target_escape,$(IMAGE)/ci) $1/ci: $(call target_escape,$(IMAGE_BASE)/ci)
	@echo '$(IMAGE)' 1>&2
	$(REGCTL) image digest $(IMAGE) 1>&2 || printf '%s' '{ "id": "$1 $(VERSION)", "image": "$(IMAGE)", "base": "$(IMAGE_BASE)", "platform": "$(subst ",\",$(subst $(empty) $(empty),,$(call to_json_array,$(IMAGE_PLATFORM))))" }, '

$1/inspect:
	docker image inspect $(platform_arg) $(IMAGE) | jq --sort-keys

$1/hadolint: build/$1.dockerfile
	$$(info hadolint $$<)
	@hadolint --config $(TOP)/.hadolint.yaml $$<

$1/latest:
	docker buildx imagetools create $(IMAGE) --tag $(REGISTRY)/$(NAMESPACE)/$1:latest

$1/lint: $1/hadolint

$1/push:
	docker push $(platform_arg) $(IMAGE)

$1/run:
	docker run $(platform_arg) --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(IMAGE)

$1/save:
	docker save $(platform_arg) --output '$(or $(TAR),$1.tar)' $(IMAGE)

$1/shell:
	docker run $(platform_arg) --detach-keys "ctrl-q,ctrl-q" --rm -t -i $(IMAGE) $(IMAGE_SHELL)

PHONIES += build/$1.dockerfile

$(foreach t,$1 $1/ $1/hadolint $1/latest $1/lint $1/inspect $1/push $1/run $1/save $1/shell,
$(foreach i,$(call target_escape,$(patsubst $1%,$(IMAGE)%,$t)),
$(eval PHONIES += $t $i)
$(eval $i: $t)
))

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
	make IMAGE/save       save image to tar
	make IMAGE/lastest    tag image version has latest (docker only)
	make prune            prune dangling images
	make ci-matrices      output CI build matrices

VARIABLES:
	REGISTRY              docker registry (e.g. docker.io, default: $(REGISTRY))
	NAMESPACE             docker namespace (e.g. koreader, default: $(NAMESPACE))
	PLATFORM              platform to build the image for (default: current system)

IMAGES:$(foreach i,$(IMAGES),$(newline)	$(i))
endef

usage:
	$(info $(USAGE))

# }}}

prune:
	docker system prune -f

build/:
	mkdir -p $@

$(foreach i,$(IMAGES),$(eval $(call image_rules,$i)))

hadolint: $(IMAGES:%=%/hadolint)

lint: $(IMAGES:%=%/lint)

define finalize_ci_matrices
  jq --sort-keys
  --arg registry '$(REGISTRY)'
  --arg namespace '$(NAMESPACE)'
  --from-file $(TOP)/docker/ci_matrices.jq
endef

ci-matrices: | build/
	$(MAKE) --no-print-directory --output-sync --quiet $(foreach t,$(or $(CI_IMAGES),$(IMAGE_IDS)),$(call target_escape,$t/ci)) | sed 's/^/[/;s/, $$/]/' | $(strip $(finalize_ci_matrices)) >build/ci_matrices.json

$(foreach t,$(filter-out $(IMAGE_IDS),$(BASE_IDS)),$(call target_escape,$t/ci)):

.PHONY: $(PHONIES)

# vim: foldmethod=marker foldlevel=0
