FROM ubuntu:20.04 AS builder
LABEL stage=builder
ENV DEBIAN_FRONTEND=noninteractive

ADD Xilinx_ISE_DS_Lin_14.7_1015_1.tar /xilinx

RUN set -eux; \
    apt-get update; \
	apt-get install -y libncurses5 libcanberra-gtk-module libcanberra-gtk3-module libusb-dev libusb-0.1-4 fxload \
                       libusb-dev build-essential libc6-dev-i386 fxload libftdi-dev libsm6 \
                       openjdk-8-jre lsb;\
	rm -rf /var/lib/apt/lists/*; \
    ln -s make /usr/bin/gmake;

FROM builder AS installer

COPY install_config.txt /xilinx/
COPY Xilinx.lic /opt/Xilinx/

SHELL ["/bin/bash", "-c"]

RUN set -eux; \
    export TERM=xterm; \
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
    ln -s libstdc++.so.6.0.8 libstdc++.so.6; \
    ls -la libstdc* ; \
    cd -; \

RUN set -eux; \
    apt-get update; \
	apt-get install -y git nano htop \
	rm -rf /var/lib/apt/lists/*; \


#RUN set -eux; \
#    apt-get update; \
#    apt-get -y install \
#        libusb-dev fxload \
#        libsm6 libglib2.0-0 libxi6 libxrender1 libxrandr2 \
#        libxtst6 \
#        libfreetype6 libfontconfig1 gcc; \
#    rm -rf /var/lib/apt/lists/*; \
#    cp /opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/xusbdfwu.hex /usr/share/ ; \
#    ln -s libusb-1.0.so.0 /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/libusb.so;


########################################################################################################################
#    KOSMOS project - Xilinx ISE 14.7 development environment
#
# Install guide: https://docs.google.com/document/d/143Wox7iSaGKZ-A4FaMCTEtapix6P3wG7SSQslLsq0K0/edit#heading=h.byto6eh4x46x
#
########################################################################################################################

#RUN set -eux; \
#    apt-get update; \
#	apt-get install -y libncurses5 libcanberra-gtk-module libcanberra-gtk3-module libusb-dev libusb-0.1-4 fxload \
#                       git libusb-dev build-essential libc6-dev-i386 fxload libftdi-dev libsm6; \
#    ln -s make /usr/bin/gmake; \
#    apt install -y openjdk-8-jre; \
#    cd /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64; \
#    ls -la libstdc*; \
#    rm -fv libstdc++.so*; \
#    ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.28 libstdc++.so.6; \
#    ln -s libstdc++.so.6 libstdc++.so; \
#    ls -la libstdc* ; \
#    cd -; \
#    apt install -y lsb; \
#	rm -rf /var/lib/apt/lists/*; \
