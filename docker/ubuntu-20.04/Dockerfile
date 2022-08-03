FROM ubuntu:20.04

ARG APP_NAME
ARG APP_DESC
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG VCS_BRANCH
ARG BUILD_DATE

# Include metadata
LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.name="$APP_NAME build image" \
    org.label-schema.description="$APP_DESC" \
    org.label-schema.version="$VERSION" \
    org.label-schema.vcs-url="$VCS_URL" \
    org.label-schema.vcs-ref="$VCS_REF" \
    org.label-schema.build-date="$BUILD_DATE" \
    com.gondaruk.product.name="$APP_NAME" \
    com.gondaruk.product.version="$VERSION" \
    com.gondaruk.product.vcs-ref="$VCS_REF" \
    com.gondaruk.product.vcs-branch="$VCS_BRANCH" \
    com.gondaruk.product.component="$APP_NAME" \
    com.gondaruk.docker.container.build-date="$BUILD_DATE" \
    com.gondaruk.docker.container.type="build"

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install build dependencies
RUN apt-get -y -o 'Acquire::Retries=3' update && \
	apt-get install -y --no-install-recommends \
    build-essential \
    autotools-dev \
    automake \
    pkg-config \
    autoconf \
    ca-certificates \
    git \
    wget \
    python3 \
    python3-pip \
    cmake \
    flex \
    bison \
    gettext \
    tar && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Install meson and ninja
RUN pip3 install meson ninja

# Copy gstreamer sources into container
RUN mkdir -p /build.gstreamer
COPY ./gstreamer /build.gstreamer

## Build gstreamer
RUN cd /build.gstreamer && \
    MESON_OPTIONS="-Dpython=disabled -Dlibav=disabled -Dlibnice=disabled -Dugly=disabled -Dbad=enabled -Ddevtools=disabled -Dges=disabled -Drtsp_server=disabled -Dgst-examples=disabled -Dqt5=disabled -Dtests=disabled -Dexamples=disabled -Ddoc=disabled -Dgtk_doc=disabled" && \
    meson build -D prefix=/usr $MESON_OPTIONS -D buildtype=release -D b_lto=true && \
    ninja -C build install && \
    DESTDIR=/gstreamer ninja -C build install && \
    gst-inspect-1.0

RUN tar --create \
    		--gzip \
    		--verbose \
    		--file /gstreamer.tar.gz \
    		--directory /gstreamer .


FROM ubuntu:20.04

ARG APP_NAME
ARG APP_DESC
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG VCS_BRANCH
ARG BUILD_DATE

# Include metadata
LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.name="$APP_NAME" \
    org.label-schema.description="$APP_DESC" \
    org.label-schema.version="$VERSION" \
    org.label-schema.vcs-url="$VCS_URL" \
    org.label-schema.vcs-ref="$VCS_REF" \
    org.label-schema.build-date="$BUILD_DATE" \
    com.gondaruk.product.name="$APP_NAME" \
    com.gondaruk.product.version="$VERSION" \
    com.gondaruk.product.vcs-ref="$VCS_REF" \
    com.gondaruk.product.vcs-branch="$VCS_BRANCH" \
    com.gondaruk.product.component="$APP_NAME" \
    com.gondaruk.docker.container.build-date="$BUILD_DATE"

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install build dependencies
RUN apt-get -y -o 'Acquire::Retries=3' update && \
	apt-get install -y --no-install-recommends \
    ca-certificates && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY --from=0 /gstreamer /
COPY --from=0 /gstreamer.tar.gz /
