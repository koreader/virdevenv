nightswatcher
=============

Nightly build script and image for KOReader.


Usage
-----

First, you need to setup a pipeline service hook token and trigger token
in gitlab. The webhook needs to be pointed at:
`http://YOURDOMAIN:9742/webhooks/gitlab-pipeline`.

Then spin up the service with the following Docker command:

```bash
docker run \
        --name nightswatcher \
        --rm \
        -v `pwd`/download:/data/release_download \
        -v `pwd`/ota:/data/ota \
        -v `pwd`/metadata:/metadata \
        -p 9742:9742 \
        -e GITLAB_TRIGGER_TOKEN='foo' \
        -e GITLAB_WEBHOOK_TOKEN='bar' \
        -e APK_SIGN_KEY_PASS='foo' \
        -e APK_SIGN_STORE_PASS='foo' \
        -e APK_SIGN_KEY_STORE_PATH='/metadata/apk.keystore' \
        -d koreader/nightswatcher
```

NOTE: `--rm` removes the nightswatcher name when you `docker stop nightswatcher`
so that you can more easily iterate.

All new builds will be saved into `/data/release_download` volume.
OTA related files will be saved into `/data/ota` volume.
