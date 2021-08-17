/bash

echo -------------------------
echo 1. install prerequisites
echo -------------------------

sudo apt-get update 

sudo apt-get -y --no-install-recommends install \
    build-essential \
    pkg-config \
    git \
    cmake \
    autoconf \
    autopoint \
    unzip \
    libssl1.0-dev \
    curl \
    libconfig-dev

echo -------------------------
echo 2. install build tools
echo -------------------------	
sudo apt install -y python3 git ninja-build python3-pip

pip3 install --user meson

echo ----------------------------------
echo 3. install gstreamer dependencies
echo ----------------------------------

sudo apt-get -y install \
    m4 \
    libmicrohttpd-dev \
    libjansson-dev  \
    libssl-dev \
    libsrtp-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libogg-dev \
    libcurl4-openssl-dev \
    liblua5.3-dev \
    libconfig-dev  \
    pkg-config \
    gengetopt \
    libtool \
    automake \
    gtk-doc-tools \
    glib-2.0 \
    bison \
    flex \
    libglib2.0-dev \
    libunwind-dev \
    libdw-dev \
    libgtk-3-dev \
	libcairo-dev \
	libspeex-dev \
	libdv-dev \
	libsoup2.4-dev \
	qtdeclarative5-dev \
	libwavpack-dev
echo ----------------------------------------------
echo 3.1  Install AAC lib:
echo ----------------------------------------------
sudo apt-get -y install libvo-aacenc-dev


echo ----------------------------------------------
echo 4. build and install gstreamer - master branch
echo ----------------------------------------------

sudo rm -rf gst-build
git clone https://gitlab.freedesktop.org/gstreamer/gst-build
cd gst-build
meson build
ninja -C build
sudo ninja -C build install

echo -------------------------
echo 5. remove old gstreamer
echo -------------------------

sudo apt-get remove -y \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-doc \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-rtsp \
    libnice-dev \
    gstreamer1.0-nice \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer1.0-0 \
    libgstreamer1.0-dev
