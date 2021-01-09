# Zephyr ADA containers
Containers to develop Ada programs based on Zephyr RTOS.

## Container Hierarchy

    zephyr-sdk-ada-build-base   zephyr-sdk-ada-base
                |                       |
                |                       |
                +-----------+-----------+
                            |
                +-----------+-----------+
                |                       |
                |                       |
        zephyr-sdk-ada-arm   zephyr-sdk-ada-riscv64

### zephyr-sdk-ada-build-base (auxiliary)
The base container with the environment to build Zephyr SDK.
Does the same as the original build script but also have some patches for crosstool-ng and original configs to make the toolchain with Ada support.
It provides only preparation without the final build step.

### zephyr-sdk-ada-base (auxiliary)
The base container with the environment for the Zephyr SDK itself. Without build dependencies. And without built toolchain itself.

### zephyr-sdk-ada-arm
The container inherited from *zephyr-sdk-ada-base*.
The Dockerfile build also makes the final build stage of toolchain for *arm* architecture in separate internal *zephyr-sdk-ada-build-arm* Docker stage based on *zephyr-sdk-ada-build-base*.

### zephyr-sdk-ada-riscv64
Same as *zephyr-sdk-ada-arm* but for *riscv64* architecrure.

## Quick start
Run Docker image. For example *arm* toolchain version

    docker run -it zephyrada/zephyr-sdk-ada-arm

Create a project folder

    mkdir myproject && cd myproject

Initialize West and update Modules

    west init && west update

Go to sample and build it

    cd zephyr/samples/basic/blinky
    west build -b stm32f429i_disc1

## How to build containers
You can use make targets.

### Note about registry
Pass REGISTRY_BASE="<registry_base>" to the make argument if needs to replace container prefix.
For example:

    make REGISTRY_BASE="" base

will build *zephyr-sdk-ada-base*

    make REGISTRY_BASE="myname/" base

will build *myname/zephyr-sdk-ada-base*

be carefill to keep slash at the end of REGISTRY_BASE


### Build commands

Build base containers by invoke:

    make base
    make build-base

Build container with target architecture. For example:

    make arm

or

    make riscv64