VERSION = 1.1.0

IMAGE_BASE     = $(UBUNTU_IMAGE)
IMAGE_PLATFORM = arm64
IMAGE_USER     = 0
IMAGE_WORKDIR  = /

define IMAGE_CMD
[
"gunicorn",
"--access-logfile",
"-",
"-b",
"0.0.0.0:9742",
"-w",
"1",
"-k",
"gevent",
"nightswatcher:api"
]
endef
IMAGE_CMD := $(strip $(IMAGE_CMD))

PHONIES += nightswatcher/pylint

nightswatcher/lint: nightswatcher/pylint

nightswatcher/pylint: nightswatcher/nightswatcher.py
	$(info pylint $<)
	@pylint --fail-on=E --fail-under=8 --rcfile nightswatcher/.pylintrc $<
