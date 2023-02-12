FROM ubuntu:20.04 AS builder
LABEL stage=builder
ENV DEBIAN_FRONTEND=noninteractive

ADD Xilinx_ISE_DS_Lin_14.7_1015_1.tar /xilinx

RUN set -eux; \
    dpkg --add-architecture i386; \
    apt-get update; \
	apt-get install --no-install-recommends --yes \
      build-essential libc6-dev-i386 zlib1g:i386 \
      libncurses5 libcanberra-gtk-module libcanberra-gtk3-module \
      libusb-dev libusb-0.1-4 libftdi-dev fxload \
      libsm6 lsb \
      openjdk-8-jre \
      libglib2.0-0 libxi6 libxrender1 libxrandr2 libxtst6 libfreetype6 libfontconfig1; \
	rm -rf /var/lib/apt/lists/*; \
    ln -s make /usr/bin/gmake;

FROM builder AS installer

COPY install_config.txt /xilinx/
COPY Xilinx.lic /opt/Xilinx/

SHELL ["/bin/bash", "-c"]

RUN set -eux; \
    export TERM=xterm-256color; \
    yes | /xilinx/Xilinx_ISE_DS_Lin_14.7_1015_1/bin/lin64/batchxsetup --batch /xilinx/install_config.txt; \
    bash -c "source /opt/Xilinx/14.7/ISE_DS/settings64.sh && env && echo Xilinx ISE 14.7 installation successful!"; \
    rm -rf /xilinx;

RUN set -eux; \
    cd /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64; \
    ls -la libstdc*; \
    mv libstdc++.so.6.0.8{,.bak}; \
    mv libstdc++.so.6{,.bak}; \
    mv libstdc++.so{,.bak}; \
    ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.28 libstdc++.so.6; \
    ln -s libstdc++.so.6 libstdc++.so; \
    ls -la libstdc*;


FROM installer as customizer

# Install other tools
RUN set -eux; \
    apt-get update; \
	apt-get install --no-install-recommends --yes git nano vim strace htop tree; \
	rm -rf /var/lib/apt/lists/*;

# Install python 3.7
RUN set -eux; \
    apt-get update; \
	apt-get install --no-install-recommends --yes software-properties-common; \
    add-apt-repository ppa:deadsnakes/ppa; \
	apt-get install --no-install-recommends --yes python3.7 python3.7-distutils python3-pip; \
	rm -rf /var/lib/apt/lists/*; \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1; \
    update-alternatives --set python /usr/bin/python3.7; \
    python -V && python3 -V && whereis python; \
    python -m pip install --upgrade pip; \
    python -m pip -V && pip -V && pip3 -V && whereis pip;

# Install python pip packages
RUN pip install \
    Jinja2>=3.1.2 \
    PyYAML>=5.3.1 \
    dacite>=1.8.0;
