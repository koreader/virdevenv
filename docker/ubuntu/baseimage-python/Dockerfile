FROM frenzie/kobase:0.1.0

USER root
RUN apt-get update
RUN apt-get install -y --no-install-recommends python
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
