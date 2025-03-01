FROM ubuntu:26.04

ARG TARGETARCH

ENV TZ=Europe/Vienna
ENV PATH="/build/renpy/.venv/bin:/root/.local/bin:$PATH"

# Copy install script first
COPY install-deps.sh /tmp/install-deps.sh

# Install dependencies using shared script + Docker-specific extras
RUN chmod +x /tmp/install-deps.sh \
    && /tmp/install-deps.sh \
    && apt-get install -y \
        debootstrap \
        qemu-user-binfmt \
        sudo \
    && rm /tmp/install-deps.sh \
    && git config --global --add safe.directory /build/renpy \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

COPY . /build

# Setup SDKs - Android NDK only available for x86_64
RUN mkdir -p /build/steam/sdk \
    && git clone --quiet https://github.com/rlabrecque/SteamworksSDK.git /build/steam/sdk \
    && cd /build/steam/sdk \
    && git checkout --quiet 494c2d680b9e47bbc369496b57568f44ef2f6796 \
    && rm -rf .git \
    && cd /build/steam \
    && zip -qr steamworks_sdk_163.zip sdk \
    && mv steamworks_sdk_163.zip /build/tars \
    && rm -rf /build/steam \
    && sed -i '/update $(git remote get-url origin)/ s/^/# /' /build/nightly/git.sh \
    && if [ "$TARGETARCH" = "amd64" ]; then \
        cd /build/tars \
        && if [ ! -f android-ndk-r29-linux.zip ]; then \
            wget -q https://dl.google.com/android/repository/android-ndk-r29-linux.zip; \
        fi; \
    fi \
    && cd /build \
    && ./prepare.sh \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
WORKDIR /build
