FROM koreader/kobase:0.1.5

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends click \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
