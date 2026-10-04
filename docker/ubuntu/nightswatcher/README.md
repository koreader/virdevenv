nightswatcher
=============

Nightly build script and image for KOReader.


Usage
-----

First, you need to setup a pipeline service hook token and trigger token
in GitHub. The webhook needs to be pointed at:
`http://YOURDOMAIN:9742/webhooks/github`.

Then spin up the service with the following Docker command:

```bash
docker run \
        --name nightswatcher \
        --rm \
        -v `pwd`/download:/data/release_download \
        -v `pwd`/ota:/data/ota \
        -p 9742:9742 \
        -e GITHUB_WEBHOOK_SECRET='bar' \
        -d koreader/nightswatcher
```

NOTE: `--rm` removes the nightswatcher name when you `docker stop nightswatcher`
so that you can more easily iterate.

All new builds will be saved into `/data/release_download` volume.
OTA related files will be saved into `/data/ota` volume.

Older builds are purged automatically as per `KEEP_FREE_GB` (default: `10`).
Oldest versions first. Always keep at least `KEEP_STABLE_AMOUNT` (default: `2`)
and `KEEP_NIGHTLY_AMOUNT` (default: `7`).
