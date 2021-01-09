FROM ubuntu:focal

ARG CROSSTOOL_NG_VERSION=v0.11.4

ARG DEBIAN_FRONTEND=noninteractive

#
# common dependencies
#

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    diffstat \
    chrpath \
    curl \
    gcc \
    g++ \
    git \
    patch \
    automake  \
    make \
    flex \
    sed \
    texinfo \
    xz-utils \
    unzip \
    help2man \
    file \
    gawk \
    libtool-bin \
    libncurses-dev \
    bison \
    byacc \
    ccache \
    libreadline-dev \
    gperf \
    python3-dev \
    python3-pip \
    gnat \
    wget

RUN update-ca-certificates

#
# install prebuild host-tools
#

ENV HOSTTOOLS_NAME zephyr-sdk-x86_64-hosttools-standalone-0.9.sh
ENV ZEPHYR_SDK_INSTALL_DIR /opt/zephyr-sdk
ENV ZEPHYR_SDK_VERSION ${CROSSTOOL_NG_VERSION}

RUN wget --progress=dot:giga https://github.com/zephyrproject-rtos/sdk-ng/releases/download/$ZEPHYR_SDK_VERSION/${HOSTTOOLS_NAME} \
    && chmod +x ${HOSTTOOLS_NAME} \
    && ./${HOSTTOOLS_NAME} -y -d $ZEPHYR_SDK_INSTALL_DIR \
    && rm ${HOSTTOOLS_NAME}

#
# get sdk, patch and prepare for build
#

WORKDIR /
RUN useradd -ms /bin/bash build-user
USER build-user
WORKDIR /home/build-user

RUN git clone -b ${CROSSTOOL_NG_VERSION}  https://github.com/zephyrproject-rtos/sdk-ng.git

# Ada language support
# https://github.com/crosstool-ng/crosstool-ng/issues/1216
COPY patches/0001-Enable-CC_LANG_ADA-for-BARE_METAL.patch /home/build-user/sdk-ng/patches
COPY patches/0002-Add-disable-libada-in-CC_GCC_EXTRA_CONFIG_ARRAY.patch /home/build-user/sdk-ng/patches
# Fix build error when libada disabled from compilation
# https://gcc.gnu.org/legacy-ml/gcc-patches/2019-09/msg01665.html
COPY patches/gcc/9.2.0/0001-gcc-lang-no-install-gnatlib.patch /home/build-user/sdk-ng/patches/gcc/9.2.0
# Fix generation of ADA specification for union anonymous fields
COPY patches/gcc/9.2.0/0002-ada-Fix-generation-of-specification-for-union-anonym.patch /home/build-user/sdk-ng/patches/gcc/9.2.0
# Fix mark spec file with subtype as limited
COPY patches/gcc/9.2.0/0003-ada-Fix-mark-spec-file-with-subtype-as-limited.patch /home/build-user/sdk-ng/patches/gcc/9.2.0

WORKDIR /home/build-user/sdk-ng/configs

# Add crosstool-ng config parameters to files if them does not added
# WORKDIR /home/build-user/sdk-ng/configs
RUN for config in $(ls); do grep -qF 'CT_EXPERIMENTAL' ${config} || echo "CT_EXPERIMENTAL=y" >> ${config}; done && \
    for config in $(ls); do grep -qF 'CT_CC_LANG_ADA' ${config} || echo "CT_CC_LANG_ADA=y" >> ${config}; done && \
    for config in $(ls); do sed -i 's/CT_CC_GCC_EXTRA_CONFIG_ARRAY="/CT_CC_GCC_EXTRA_CONFIG_ARRAY="--disable-libada /' ${config}; done && \
    for config in $(ls); do echo "\n###\n${config}\n###" && \
                            cat ${config} | grep CT_EXPERIMENTAL && \
                            cat ${config} | grep CT_CC_LANG_ADA && \
                            cat ${config} | grep CT_CC_GCC_EXTRA_CONFIG_ARRAY; done

WORKDIR /home/build-user/sdk-ng

##
# build ct-ng
##

ENV COMMIT="3f461da11f1f8e9dcfdffef24e1982b5ffd10305"
ENV GITDIR=/home/build-user/sdk-ng
ENV SDK_NG_HOME=/home/build-user/sdk-ng

RUN git clone https://github.com/crosstool-ng/crosstool-ng.git && \
    echo "Patching tree" && \
    cd crosstool-ng && \
    git checkout ${COMMIT} && \
    for p in ${GITDIR}/patches/*.patch; do patch -p1 < $p; done

RUN cd crosstool-ng && \
    ./bootstrap && \
    CFLAGS="-DKBUILD_NO_NLS" ./configure --prefix=${SDK_NG_HOME} && \
    make && make install

ENV CT_NG=${SDK_NG_HOME}/bin/ct-ng