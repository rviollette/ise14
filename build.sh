#!/bin/bash
set -eu

ISE_VERSION=14.7
ISE_IMAGE=${ISE_IMAGE:-"kosmos-ise:${ISE_VERSION}"}
ISE_TAR_FILE=Xilinx_ISE_DS_Lin_14.7_1015_1

# Start python HTTP server in background
python3 -m http.server 8147 &
PYTHON_PID=$!
sleep 1
echo "HTTP server started with PID ${PYTHON_PID}"

# Close python HTTP server when script exits
exit_trap () {
  echo -e "\nClosing HTTP server with PID ${PYTHON_PID}"
  kill ${PYTHON_PID}
}
trap exit_trap EXIT

# Build Dockerfile
docker build --network=host \
             --build-arg ISE_TAR_HOST=http://0.0.0.0:8147 \
             --build-arg ISE_TAR_FILE="${ISE_TAR_FILE}" \
             --build-arg ISE_VERSION="${ISE_VERSION}" \
             -t "${ISE_IMAGE}" .
