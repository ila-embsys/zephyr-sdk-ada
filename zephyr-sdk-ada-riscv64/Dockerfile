ARG TARGET=riscv64

#
# build toolchain image
#
FROM zephyrada/zephyr-sdk-ada-build-base:v0.1.0-alpha as zephyr-sdk-ada-build-riscv64

ARG TARGET

USER build-user

ENV OUTPUT_DIR=${SDK_NG_HOME}/build/output

RUN mkdir -p ${OUTPUT_DIR}/sources

RUN echo "Building ${TARGET}" && \
    mkdir -p build/build_${TARGET}

WORKDIR ${SDK_NG_HOME}/build/build_${TARGET}

RUN ${CT_NG} defconfig DEFCONFIG=${GITDIR}/configs/${TARGET}.config && \
    ${CT_NG} savedefconfig DEFCONFIG=${TARGET}.config && \
    ${CT_NG} list-steps

RUN cat .config | grep CT_EXPERIMENTAL && \
    cat .config | grep CT_CC_LANG_ADA && \
    cat .config | grep CT_CC_GCC_EXTRA_CONFIG_ARRAY

RUN CT_PREFIX=${OUTPUT_DIR} ${CT_NG} build.$(nproc)

FROM zephyrada/zephyr-sdk-ada-base:v0.1.0-alpha

ARG TARGET=riscv64

COPY --from=zephyr-sdk-ada-build-riscv64 /opt/zephyr-sdk /opt/zephyr-sdk
COPY --from=zephyr-sdk-ada-build-riscv64 /home/build-user/sdk-ng/build/output/${TARGET}-zephyr-elf /opt/zephyr-sdk/${TARGET}-zephyr-elf

ENV PATH="/opt/zephyr-sdk/${TARGET}-zephyr-elf/bin:${PATH}"

USER root
# make directories as the original installer makes
RUN cd /opt/zephyr-sdk/ && \
    mkdir info-zephyr-sdk-${ZEPHYR_SDK_VERSION} && \
    cp version-x86_64-pokysdk-linux info-zephyr-sdk-${ZEPHYR_SDK_VERSION} && \
    echo "${ZEPHYR_SDK_VERSION}" > sdk_version

USER $USERNAME

