To run nightwatcher in testing mode, fill-in `GITHUB_WEBHOOK_SECRET` in
`nightswatcher/tests/env`, and run:


```
▸ make nightwatcher/test
```

This will mount `./nightwatcher` to `/nightwatcher`, so `./nightwatcher/tests`
can be accessed, and there's no need to rebuild the image when hacking on
`./nightswatcher/nightswatcher.py`. State will be saved in `./nightswatcher/data`
(mounted to `/data`). Additionally, gunicorn is started with `--reload`, so changes
to `nightswatcher/nightswatcher.py` will automatically trigger a reload.

To manually simulate a webhook event using cURL (assuming `body.json` contains the payload):
```
▸ . ./nightswatcher/tests/env
▸ signature="$(openssl dgst -sha256 -hex -hmac "${GITHUB_WEBHOOK_SECRET}" <body.json | sed '/^SHA2-256(stdin)= /!Q1;s///')"
▸ curl \
    -X POST \
    -H 'Accept: */*' \
    -H 'Content-Type: application/json' \
    -H 'X-Github-Event: release' \
    -H "X-Hub-Signature-256: sha256=${signature}" \
    --data-binary @body.json http://127.0.0.1:9742/webhooks/github
```
