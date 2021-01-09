FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ARG CMAKE_ADA_MODULES_GIT_URL=https://github.com/zephyr-ada/cmake-ada.git

# common dependencies

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    gperf \
    ccache \
    dfu-util \
    device-tree-compiler \
    wget \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-tk \
    python3-wheel \
    xz-utils \
    file \
    make \
    libsdl2-dev \
    ssh \
    clangd

# install west

RUN pip3 install west pyelftools

# install cmake modules

RUN git clone ${CMAKE_ADA_MODULES_GIT_URL} && \
    cd cmake-ada && \
    cmake -P install.cmake && \
    cd .. && \
    rm -rf cmake-ada

# prepare environment

ENV ZEPHYR_SDK_INSTALL_DIR /opt/zephyr-sdk
ENV ZEPHYR_TOOLCHAIN_VARIANT zephyr
ENV ZEPHYR_SDK_VERSION 0.11.2

# Create the user

ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set Xserver
# ===========

ENV DISPLAY=host.docker.internal:0

# set arg value to env to be visible on child images
ENV USERNAME=$USERNAME
USER $USERNAME

WORKDIR /home/$USERNAME