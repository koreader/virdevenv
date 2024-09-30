USER root
RUN apt-get update
RUN apt-get upgrade -y
# NOTE: libx11-dev is needed to compile libxss-dummy.
RUN apt-get install -y --no-install-recommends libsndio7.0 libx11-dev
