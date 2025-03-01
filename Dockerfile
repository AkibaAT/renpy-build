FROM ubuntu:24.04

ENV TZ=Europe/Vienna
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        autoconf \
        autoconf-archive \
        automake \
        bc \
        build-essential \
        ccache \
        clang \
        cmake \
        curl \
        curl \
        debootstrap \
        git \
        git \
        libarchive-tools \
        libassimp-dev \
        libavcodec-dev \
        libavformat-dev \
        libbz2-dev \
        libfreetype6-dev \
        libfribidi-dev \
        libgmp-dev \
        libharfbuzz-dev \
        libjpeg-dev \
        liblzma-dev \
        libmpc-dev \
        libmpfr-dev \
        libsdl2-dev \
        libsdl2-gfx-dev \
        libsdl2-image-dev \
        libsdl2-mixer-dev \
        libsdl2-ttf-dev \
        libssl-dev \
        libswresample-dev \
        libswscale-dev \
        libtool-bin \
        libxml2-dev \
        llvm \
        ninja-build \
        python3-dev \
        python3-jinja2 \
        python3-pip \
        python3-venv \
        qemu-user-static \
        quilt \
        software-properties-common \
        sudo \
        unzip \
        zip \
    && git config --global --add safe.directory /build/renpy \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && wget -O /tmp/llvm.sh https://apt.llvm.org/llvm.sh \
    && chmod +x /tmp/llvm.sh \
    && /tmp/llvm.sh 18 \
    && rm /tmp/llvm.sh \
    && rm -rf /var/lib/apt/lists/*

COPY . /build
RUN mkdir -p /build/steam/sdk \
    && git clone https://github.com/rlabrecque/SteamworksSDK.git /build/steam/sdk \
    && cd /build/steam/sdk \
    && git checkout e7bb839178fc5a48aa380d85e2ad04cc97d9d11c \
    && rm -rf .git \
    && cd /build/steam \
    && zip -r steamworks_sdk_160.zip sdk \
    && mv steamworks_sdk_160.zip /build/tars \
    && sed -i '/update $(git remote get-url origin)/ s/^/# /' /build/nightly/git.sh \
    && cd /build/tars \
    && wget https://dl.google.com/android/repository/android-ndk-r27c-linux.zip \
    && cd /build \
    && ./prepare.sh \
    && mv /build/docker/entrypoint.sh /entrypoint.sh \
    && chmod +x /entrypoint.sh \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
WORKDIR /build
