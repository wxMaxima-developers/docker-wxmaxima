#FROM ubuntu:trusty
FROM debian:bookworm

ARG ARCH=x86_64

RUN apt-get update && apt-get -q -y install git autoconf python3 binutils \
    texinfo gcc libtool vim desktop-file-utils pkgconf libcairo2-dev \
    libssl-dev libfuse3-dev zsync wget fuse3 bzip2 gawk g++ gperf \
    libgtk-3-dev doxygen libatspi2.0-dev ninja-build make flatpak flatpak-builder \
    libwebkit2gtk-4.0-dev appstream appstream-util curl sbcl

RUN apt-get update && apt-get -q -y install cmake

RUN apt-get update && apt-get -q -y install libwxgtk3.2-dev libwxgtk-webview3.2-dev libwxgtk-media3.2-dev gnuplot  libpng-dev 

ENV maxima_build tags/5.47.0

RUN git clone https://git.code.sf.net/p/maxima/code maxima-code && \
    cd maxima-code && \
    git checkout ${maxima_build}

RUN cd maxima-code && \
    mkdir dist && \
    ./bootstrap && \
    ./configure --enable-sbcl-exec --enable-quiet-build --prefix=`pwd`/dist && \
    make -s -j 2&& \
    make install

ENV wxmaxima_build Version-23.05.1

RUN git clone https://github.com/wxMaxima-developers/wxmaxima.git && \
    cd wxmaxima && \
    git checkout ${wxmaxima_build}

RUN cd wxmaxima && \
    mkdir -p build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/wxmaxima-inst  -DCMAKE_CXX_FLAGS="-static-libgcc -static-libstdc++" -DCMAKE_LD_FLAGS="-static-libgcc -static-libstdc++" .. && \
    cmake --build . && \
    cmake --build . -- install

COPY appimagetool-$ARCH.AppImage /
RUN chmod +x appimagetool-$ARCH.AppImage
RUN ./appimagetool-$ARCH.AppImage --appimage-extract && \
    cp -R squashfs-root/* .

RUN mkdir maxima-squashfs
WORKDIR maxima-squashfs
RUN mkdir -p usr/bin


RUN mkdir maxima-inst && \
    (cd ../maxima-code/dist && tar cf - *) | (cd maxima-inst && tar xf -)
RUN ln -s share/info maxima-inst/info
RUN ln -s ../../maxima-inst/bin/maxima usr/bin/maxima

RUN (cd .. && tar cf - wxmaxima-inst) | tar xf -
RUN ln -s ../../wxmaxima-inst/bin/wxmaxima usr/bin/wxmaxima

RUN mkdir -p usr/share/metainfo
COPY io.github.wxmaxima_developers.wxMaxima.appdata.xml usr/share/metainfo/
COPY linux_1.png .

COPY AppRun .
RUN chmod +x AppRun
COPY io.github.wxmaxima_developers.wxMaxima.desktop .
RUN mkdir -p /usr/share/applications/
COPY io.github.wxmaxima_developers.wxMaxima.desktop /usr/share/applications/
COPY maxima.png .
RUN mkdir -p /usr/share/pixmaps/
COPY maxima.png /usr/share/pixmaps/io.github.wxmaxima_developers.wxMaxima.png

WORKDIR /

# https://github.com/AppImage/AppImageKit for "-n" option
RUN ARCH=$ARCH appimagetool -n maxima-squashfs


