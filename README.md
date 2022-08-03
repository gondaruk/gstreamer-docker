# GStreamer Docker

This repository contains build instructions for gstreamer and its docker images which can be used for ci purposes.

### Run container
Image contains GStreamer (base, good, bad) installed in /usr, so you can use it out of the box like 
```bash
# list available plugins
docker run -it --rm gondaruk/gstreamer:1.20 gst-inspect-1.0
```

### Use with other base image
Image also container GStreamer compiled artifacts in `/gstreamer.tar.gz`, so you can use it just to move GStreamer to another image:
```Dockerfile
FROM gondaruk/gstreamer:1.20

RUN mkdir /gstreamer && \
  tar --extract \
      --verbose \
      --gzip \
      --file /gstreamer.tar.gz  \
      --directory /gstreamer

# -------------------------------------------------------------
FROM ghcr.io/cross-rs/aarch64-unknown-linux-gnu:latest

COPY install-dependencies.sh /usr/bin/install-dependencies.sh
RUN /usr/bin/install-dependencies.sh

COPY --from=0 /gstreamer /

```