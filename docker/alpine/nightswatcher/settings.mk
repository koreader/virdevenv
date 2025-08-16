VERSION = 1.0.0
BASE = $(BASEIMAGE)
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
NIGHTSWATCHER_VERSION = 3a35cf695c0bb1f91cf3a3d94ddf234d12b9b3fc

define BUILD_ARGS
NIGHTSWATCHER_VERSION=$(NIGHTSWATCHER_VERSION)
endef
