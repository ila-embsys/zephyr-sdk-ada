PROJECT_PREFIX = zephyr-sdk-ada
REGISTRY_BASE = zephyrada/

DOCKER_BUILD_STRING = docker build -f "$(PROJECT_PREFIX)-$@/Dockerfile" -t $(REGISTRY_BASE)$(PROJECT_PREFIX)-$@ "$(PROJECT_PREFIX)-$@"

.PHONY: all \
	build-base \
	base \
	arm \
	riscv64

all: arm \
	riscv64

build-base:
	$(DOCKER_BUILD_STRING)

base:
	$(DOCKER_BUILD_STRING)

arm: build-base base
	$(DOCKER_BUILD_STRING)

riscv64: build-base base
	$(DOCKER_BUILD_STRING)
