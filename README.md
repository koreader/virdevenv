# Virtual dev environment for KOReader

Docker is the preferred method for building KOReader without setting up the dependencies on your local system. These are the very same Docker images used to create the KOReader builds every night.

Normally all of the Docker images should already have been built and pushed to [Docker Hub](https://hub.docker.com/u/koreader), so you only need to pull them.

To mount a local folder in your Docker container, you can use the `-v` flag. Following along from [the main project's README](https://github.com/koreader/koreader#getting-the-source), you can run a series of commands along these lines:
```
git clone https://github.com/koreader/koreader.git
docker run -v $(pwd)/koreader:/home/ko/koreader -it koreader/koappimage:latest bash
cd koreader && ./kodev fetch-thirdparty
```

You can even run the emulator directly from the Docker container provided you have a local X server, more details [here](http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/). Some further possibilities (e.g., for Mac OS X and Windows) are explored [here](https://stackoverflow.com/questions/16296753/can-you-run-gui-applications-in-a-docker-container). NB The following command assumes KOReader is harmless and partially breaks the regular Docker container isolation.

```
docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd)/koreader:/home/ko/koreader -it koreader/koappimage:0.1.5 bash -c "source ~/.bashrc && pushd koreader && ./kodev run"
```

See the CI setup in the main and base repos, as well as the nightly builds on GitLab for further guidance.
