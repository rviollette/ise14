FROM ubuntu:20.04 AS builder
LABEL stage=builder

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS="yes"

ADD Xilinx_Vivado_SDK_2018.3_1207_2324.tar.gz /xilinx

# Add missing package dependencies: custom libpng12 package
# https://blog.lazy-evaluation.net/posts/linux/vivado-2018-3-buster.html
COPY "libpng12-0_1.2.50-2+deb8u3dzu1_amd64.deb" /xilinx/

# Add missing package dependencies
# https://support.xilinx.com/s/question/0D52E00006hpmTmSAI/vivado-20183-final-processing-hangs-at-generating-installed-device-list-on-ubuntu-1904
# https://support.xilinx.com/s/article/66184
# https://support.xilinx.com/s/article/63794
RUN set -eux; \
    apt-get update; \
    apt-get upgrade --yes; \
	apt-get install --yes --no-install-recommends \
      build-essential \
      libtinfo5 \
      libncurses5 \
      lib32stdc++6 \
      libgtk2.0-0 \
      libfontconfig1 \
      libx11-6 \
      libxext6 \
      libxrender1 \
      libsm6 \
      libice6; \
	apt-get install --yes --no-install-recommends \
      "/xilinx/libpng12-0_1.2.50-2+deb8u3dzu1_amd64.deb"; \
	rm -rf /var/lib/apt/lists/*; \
    ln -s /usr/bin/make /usr/bin/gmake;

FROM builder AS installer
LABEL stage=installer

ENV TERM=xterm
COPY install_config.txt /xilinx/
RUN set -eux; \
    /xilinx/Xilinx_Vivado_SDK_2018.3_1207_2324/xsetup \
      --agree XilinxEULA,3rdPartyEULA,WebTalkTerms \
      --batch Install \
      --config /xilinx/install_config.txt \
      --xdebug; \
    bash -c "source /opt/Xilinx/Vivado/Vivado/2018.3/settings64.sh && env && echo Xilinx Vivado 2018.3 installation successful!"; \
    rm -rf /xilinx;

# Fix for ERROR: [Common 17-258] Couldn't open 'libX11.so.6': 'libX11.so.6: cannot open shared object file: No such file or directory'
# https://support.xilinx.com/s/article/62553
# RUN sed -i '/rdi::x11_workaround/s/^/#/' /opt/Xilinx/Vivado/Vivado/2018.3/lib/scripts/rdi/features/base/base.tcl

# Fix for CRITICAL WARNING: [Common 17-741] No write access right to the local Tcl store
# https://support.xilinx.com/s/question/0D52E00006hpbifSAA/critical-warning
ENV XILINX_LOCAL_USER_DATA="no"


FROM installer as customizer
LABEL stage=customizer

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

# Copy provided licence into the image
COPY Xilinx.lic /opt/Xilinx/
