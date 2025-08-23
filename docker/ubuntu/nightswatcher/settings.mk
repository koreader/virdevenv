VERSION = 1.0.0

IMAGE_BASE    = ubuntu:jammy
IMAGE_USER    = 0
IMAGE_WORKDIR = /

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

PHONIES += nightswatcher/lint

nightswatcher/lint:
	pylint --fail-on=E --fail-under=8 --rcfile nightswatcher/.pylintrc nightswatcher/nightswatcher.py
