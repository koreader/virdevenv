VERSION = 1.2.0

IMAGE_BASE     = $(UBUNTU_IMAGE)
IMAGE_PLATFORM = arm64
IMAGE_USER     = 0
IMAGE_WORKDIR  = /

define IMAGE_CMD
[
"gunicorn",
"--access-logfile", "-",
"--bind", "0.0.0.0:9742",
"--chdir", "/nightswatcher",
"--worker-class", "gevent",
"--workers", "1",
"nightswatcher:api"
]
endef
IMAGE_CMD := $(strip $(IMAGE_CMD))

PHONIES += nightswatcher/pylint nightswatcher/test

nightswatcher/lint: nightswatcher/pylint

nightswatcher/pylint: nightswatcher/nightswatcher.py
	$(info pylint $<)
	@pylint --fail-on=E --fail-under=8 --rcfile nightswatcher/.pylintrc $<

nightswatcher/test:
	mkdir -p $(CURDIR)/nightswatcher/data/{release_download,ota}
	docker run $(platform_arg) --detach-keys "ctrl-q,ctrl-q" \
		--env-file nightswatcher/tests/env \
		-v '$(CURDIR)/nightswatcher/data:/data' \
		-v '$(CURDIR)/nightswatcher:/nightswatcher' \
		--rm -t -i $(IMAGE)
