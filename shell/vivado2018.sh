#!/bin/bash

VIVADO_IMAGE=${VIVADO_IMAGE:-"kosmos-vivado:2018.3"}
LICENSE_MAC=${LICENSE_MAC:-"74:78:27:3f:08:c3"}
XILINXD_LICENSE_FILE=${XILINXD_LICENSE_FILE:-"/opt/Xilinx/Xilinx.lic"}

VIVADO_PATH=/opt/Xilinx/Vivado
ENV_PATH="${VIVADO_PATH}/SDK/2018.3/bin:\
${VIVADO_PATH}/SDK/2018.3/gnu/microblaze/lin/bin:\
${VIVADO_PATH}/SDK/2018.3/gnu/arm/lin/bin:\
${VIVADO_PATH}/SDK/2018.3/gnu/microblaze/linux_toolchain/lin64_le/bin:\
${VIVADO_PATH}/SDK/2018.3/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin:\
${VIVADO_PATH}/SDK/2018.3/gnu/aarch32/lin/gcc-arm-none-eabi/bin:\
${VIVADO_PATH}/SDK/2018.3/gnu/aarch64/lin/aarch64-linux/bin:\
${VIVADO_PATH}/SDK/2018.3/gnu/aarch64/lin/aarch64-none/bin:\
${VIVADO_PATH}/SDK/2018.3/gnu/armr5/lin/gcc-arm-none-eabi/bin:\
${VIVADO_PATH}/SDK/2018.3/tps/lnx64/cmake-3.3.2/bin:\
${VIVADO_PATH}/DocNav:\
${VIVADO_PATH}/Vivado/2018.3/bin"

echo VIVADO_IMAGE: "${VIVADO_IMAGE}"
echo LICENSE_MAC: "${LICENSE_MAC}"
echo XILINXD_LICENSE_FILE: "${XILINXD_LICENSE_FILE}"
echo WORKPLACE: "${PWD}"

docker run --rm \
--user "$(id -u):$(id -g)" \
--mac-address "${LICENSE_MAC}" \
-v /etc/passwd:/etc/passwd:ro \
-v /etc/group:/etc/group:ro  \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY="${DISPLAY}" \
-e PATH="/bin:/sbin:${ENV_PATH}" \
-e XILINXD_LICENSE_FILE="${XILINXD_LICENSE_FILE}" \
-v "$PWD:$PWD" \
-w $PWD \
-v /dev/bus/usb:/dev/bus/usb \
--device-cgroup-rule='c *:* rmw' \
-ti "${VIVADO_IMAGE}" $@
