FROM frenzie/kobase:0.1.0

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends python \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
