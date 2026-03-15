Use `mkpipevt.sh` to create a number of pipeline events and associated artifacts,
e.g. for 1 stable followed by 2 nightlies and another stable:

```
▸ ./nightswatcher/tests/mkpipevt.sh v2025.10 v2025.10-156-g7fdba6a99_2026-03-01 v2025.10-167-g0c6d217e3_2026-03-05 v2026.03
```

Then to run nightwatcher in testing mode:
```
▸ make nightwatcher/test
```

This will mount `./nightwatcher` to `/nightwatcher`, so `./nightwatcher/tests`
can be accessed, and there's no need to rebuild the image when hacking on
`./nightswatcher/nightswatcher.py`. State will be saved in `./nightswatcher/data`
(mounted to `/data`). Each pipeline event JSON created by `mkpipevt.sh` will
be used to trigger a corresponding pipeline event (in increasing version
order).
