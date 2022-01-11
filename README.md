# Virtual dev environment for KOReader

Docker is the preferred method for building KOReader without setting up the dependencies on your local system. These are the very same Docker images used to create the KOReader builds every night.

Normally all of the Docker images should already have been built and pushed to [Docker Hub](https://hub.docker.com/u/koreader), so you only need to pull them.

To mount a local folder in your Docker container, you can use the `-v` flag. Following along from [the main project's README](https://github.com/koreader/koreader#getting-the-source), you can run a series of commands along these lines:
```
git clone https://github.com/koreader/koreader.git
docker run -v $(pwd)/koreader:/home/ko/koreader -it koreader/koappimage:latest bash
cd koreader && ./kodev fetch-thirdparty
```

You can even run the emulator directly from the Docker container provided you have a local X server, more details [here](http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/). Some further possibilities (e.g., for Mac OS X and Windows) are explored [here](https://stackoverflow.com/questions/16296753/can-you-run-gui-applications-in-a-docker-container).

**NB The following command assumes KOReader is harmless and partially breaks the regular Docker container isolation. Forwarding X11 is here be dragons territory. Some people have reported segfaults in the emulator when using this method.** You have been warned.

```
docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd)/koreader:/home/ko/koreader -it koreader/koappimage:latest bash -c "source ~/.bashrc && pushd koreader && ./kodev run"
```

See the CI setup in the main and base repos, as well as the nightly builds on GitLab for further guidance.

## Windows workflow
One possible Windows workflow uses a VNC server hosted in the same docker container as the emulator. It relies on an AppImage, extracted within the docker image, and a VNC client to view the emulator.

### Modified docker image
```
# Use the latest koappimage image as a base, but in practice you could use any tag
from koreader/koappimage:latest
USER root
RUN     apt-get update

# Install vnc, xvfb in order to create a 'fake' display
RUN     apt-get install -y x11vnc xvfb

RUN     mkdir ~/.vnc
# Setup a password
RUN     x11vnc -storepasswd 1234 ~/.vnc/passwd
# Example AppImage to install
ADD https://github.com/koreader/koreader/releases/download/v2020.07.1/koreader-appimage-x86_64-linux-gnu-v2020.07.1.AppImage appimage
RUN chmod +x ./appimage
RUN ./appimage --appimage-extract
# Start up the x11vnc server
CMD x11vnc -forever -usepw -create -shared
```
Build the docker image:
```
docker build -f <custom_docker_file> -t vnckoappimage
```
Using the modified docker image above, you can then run it headlessly, like so:
```
docker run -p 5900:5900 --name vncko vnckoappimage:latest
```
Now, you can use a VNC client to access the VNC server that is hosted within the docker container. The server will be located at `localhost` on port 5900, with 1234 as the password.

Once you're connected, you can use the `xterm` session to enter the extracted AppImage directory and run the emulator:
```
cd /home/ko/squashfs-root/
./AppRun
```
This will bring up a `koreader` emulator

You can then enter the docker container in a separate, terminal (not within the docker container, but on your windows host):
```
winpty docker exec -it vncko bash
```
From here, you can edit the frontend code. When you want to see your changes reflected, you can **Restart KOReader** from the emulator KOReader system menu.

### Notes
* For some reason, if you close down the emulator after opening it then you lose keyboard focus in the xterm window
* You need to prefix you `docker exec` in Windows with `winpty` for an interactive session to work
* The above steps were tested on Windows 10 with docker for desktop
* You could mount in the front end code using `-v` if you extracted the AppImage files locally, todo: demonstrate this
* You can of course `docker cp` your edited code out

