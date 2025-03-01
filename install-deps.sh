#!/bin/bash
# Install system dependencies for building Ren'Py/Oka'Py
# This script is used by both local development and CI

set -e

LLVM_MAJOR=22

# Use sudo only if not running as root
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

$SUDO apt-get update
$SUDO env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    autoconf \
    autoconf-archive \
    automake \
    bc \
    build-essential \
    ccache \
    clang-$LLVM_MAJOR \
    cmake \
    curl \
    debootstrap \
    fcitx-libs-dev \
    git \
    libasound2-dev \
    libarchive-tools \
    libassimp-dev \
    libaudio-dev \
    libavcodec-dev \
    libavformat-dev \
    libbz2-dev \
    libdbus-1-dev \
    libegl1-mesa-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libglu1-mesa-dev \
    libgmp-dev \
    gnupg \
    libharfbuzz-dev \
    libibus-1.0-dev \
    libjpeg-dev \
    liblzma-dev \
    lsb-release \
    libmpc-dev \
    libmpfr-dev \
    libpulse-dev \
    libsamplerate0-dev \
    libsdl3-dev \
    libsdl3-image-dev \
    libsndio-dev \
    libssl-dev \
    software-properties-common \
    libswresample-dev \
    libswscale-dev \
    libtool-bin \
    libudev-dev \
    libusb-1.0-0-dev \
    libwayland-dev \
    libx11-dev \
    libxcursor-dev \
    libxext-dev \
    libxi-dev \
    libxinerama-dev \
    libxkbcommon-dev \
    libxml2-dev \
    libxrandr-dev \
    libxss-dev \
    libxxf86vm-dev \
    llvm-$LLVM_MAJOR \
    ninja-build \
    p7zip-full \
    pkg-config \
    python3-dev \
    python3-jinja2 \
    python3-pip \
    python3-venv \
    qemu-user-binfmt \
    quilt \
    unzip \
    wget \
    zip

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
