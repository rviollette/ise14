FROM ubuntu:20.04 AS builder
LABEL stage=builder

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS="yes"

# Install the minimum set of packages required to execute the installer
RUN set -eux; \
    dpkg --add-architecture i386; \
    apt-get update; \
    apt-get upgrade --yes; \
	apt-get install --yes --no-install-recommends \
      build-essential libc6-dev-i386 zlib1g:i386 \
      libncurses5 libcanberra-gtk-module libcanberra-gtk3-module \
      libusb-dev libusb-0.1-4 libftdi-dev fxload \
      libsm6 lsb \
      openjdk-8-jre \
      libglib2.0-0 libxi6 libxrender1 libxrandr2 libxtst6 libfreetype6 libfontconfig1 \
      wget; \
	rm -rf /var/lib/apt/lists/*; \
    ln -s make /usr/bin/gmake;

# Download and install Xilinx Vivado
ARG ISE_TAR_HOST
ARG ISE_TAR_FILE
ARG ISE_VERSION
ENV TERM=xterm
COPY install_config.txt /ise-installer/
RUN set -eux; \
    wget -qO - ${ISE_TAR_HOST}/${ISE_TAR_FILE}.tar | tar x --strip-components=1 -C /ise-installer; \
    yes | /ise-installer/bin/lin64/batchxsetup --batch /ise-installer/install_config.txt; \
    bash -c "source /opt/Xilinx/14.7/ISE_DS/settings64.sh && env && echo Xilinx ISE 14.7 installation successful!"; \
    rm -rf /ise-installer;

RUN set -eux; \
    cd /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64; \
    ls -la libstdc*; \
    mv libstdc++.so.6.0.8{,.bak}; \
    mv libstdc++.so.6{,.bak}; \
    mv libstdc++.so{,.bak}; \
    ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.28 libstdc++.so.6; \
    ln -s libstdc++.so.6 libstdc++.so; \
    ls -la libstdc*;


FROM builder as customizer
LABEL stage=customizer

# Install other tools
RUN set -eux; \
    apt-get update; \
	apt-get install --yes --no-install-recommends git nano vim strace htop tree less; \
	rm -rf /var/lib/apt/lists/*;

# Install python 3.7
RUN set -eux; \
    apt-get update; \
	apt-get install --yes --no-install-recommends software-properties-common; \
    add-apt-repository ppa:deadsnakes/ppa; \
	apt-get install --yes --no-install-recommends python3.7 python3.7-distutils python3-pip; \
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

# Copy provided licence into the image
COPY Xilinx.lic /opt/Xilinx/
