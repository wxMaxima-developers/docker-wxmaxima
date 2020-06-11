#FROM ubuntu:trusty
FROM debian:oldstable

ARG ARCH=x86_64

RUN apt-get update && apt-get -q -y install git autoconf python binutils \
    texinfo gcc libtool vim desktop-file-utils pkgconf libcairo2-dev \
    libssl-dev libfuse-dev zsync wget fuse bzip2 gawk g++ gperf \
    libgtk-3-dev doxygen libatspi2.0-dev

# Debian-oldstable provides a sbcl. But as sbcl is evolving rapidly we want to use
# a more recent version.
RUN wget --quiet 'http://prdownloads.sourceforge.net/sbcl/sbcl-1.4.16-x86-64-linux-binary.tar.bz2' -O /tmp/sbcl.tar.bz2 && \
    mkdir /sbcl && \
    tar jxf /tmp/sbcl.tar.bz2 --strip-components=1 -C /sbcl && \
    cd /sbcl && \
    sh install.sh && \
    rm -f /tmp/sbcl.tar.bz2

RUN wget --quiet 'https://github.com/wxWidgets/wxWidgets/releases/download/v3.1.3/wxWidgets-3.1.3.tar.bz2' && \
    bzcat wxWidgets-3.1.3.tar.bz2 | tar xf -
RUN cd wxWidgets-3.1.3 && \
    mkdir buildgtk && \
    cd buildgtk && \
    ../configure --with-gtk=3 && \
    make -j 2&& \
    make install && \
    ldconfig

RUN git clone https://git.code.sf.net/p/gnuplot/gnuplot-main && \
    cd gnuplot-main && \
    git checkout tags/5.2.8
RUN cd gnuplot-main && \
    ./prepare && \
    ./configure --prefix=`pwd`/dist && \
    make -s -j 2 && \
    make install

RUN wget --quiet -O libpng-1.2.59.tar 'https://sourceforge.net/projects/libpng/files/libpng12/1.2.59/libpng-1.2.59.tar.gz/download' && \
    zcat libpng-1.2.59.tar | tar xf -
RUN cd libpng-1.2.59 && \
    ./configure  && \
    make -s -j 2&& \
    make install

ENV maxima_build tags/5.44.0

RUN git clone https://git.code.sf.net/p/maxima/code maxima-code && \
    cd maxima-code && \
    git checkout ${maxima_build}

RUN cd maxima-code && \
    mkdir dist && \
    ./bootstrap && \
    ./configure --enable-sbcl-exec --enable-quiet-build --prefix=`pwd`/dist && \
    make -s -j 2&& \
    make install

# Debian-oldstable provides too old an cmake3 version for building wxMaxima.
# At least the debian-oldstable that was active in Jan 2019 did.
RUN wget --quiet 'https://github.com/Kitware/CMake/releases/download/v3.13.3/cmake-3.13.3.tar.gz' && \
    zcat cmake-3.13.3.tar.gz | tar xf - && \
    cd cmake-3.13.3 && \
    ./bootstrap && \
    make -s -j 2&& \
    make install

ENV wxmaxima_build Version-20.06.6

RUN git clone https://github.com/wxMaxima-developers/wxmaxima.git && \
    cd wxmaxima && \
    git checkout ${wxmaxima_build}

RUN cd wxmaxima && \
    mkdir -p build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/wxmaxima-inst  -DCMAKE_CXX_FLAGS="-static-libgcc -static-libstdc++" -DCMAKE_LD_FLAGS="-static-libgcc -static-libstdc++" .. && \
    cmake -- build . && \
    cmake --build . -- install

COPY appimagetool-$ARCH.AppImage /
RUN chmod +x appimagetool-$ARCH.AppImage
RUN ./appimagetool-$ARCH.AppImage --appimage-extract && \
    cp -R squashfs-root/* .

RUN mkdir maxima-squashfs
WORKDIR maxima-squashfs
RUN mkdir -p usr/bin

RUN cp -ar /gnuplot-main/dist gnuplot-inst
RUN ln -s ../../gnuplot-inst/bin/gnuplot usr/bin/gnuplot

RUN (cd .. && tar cf - sbcl) | tar xf -
RUN ln -s ../../sbcl/run-sbcl.sh usr/bin/sbcl

RUN mkdir -p usr/lib
RUN cp -a /usr/local/lib/libwx* /usr/local/lib/libpng* usr/lib

RUN mkdir maxima-inst && \
    (cd ../maxima-code/dist && tar cf - *) | (cd maxima-inst && tar xf -)
RUN ln -s share/info maxima-inst/info
RUN ln -s ../../maxima-inst/bin/maxima usr/bin/maxima

RUN (cd .. && tar cf - wxmaxima-inst) | tar xf -
RUN ln -s ../../wxmaxima-inst/bin/wxmaxima usr/bin/wxmaxima

RUN mkdir -p usr/share/metainfo
COPY wxmaxima.appdata.xml usr/share/metainfo/

COPY AppRun .
RUN chmod +x AppRun
COPY wxmaxima.desktop .
COPY maxima.png .

WORKDIR /
RUN ARCH=$ARCH appimagetool maxima-squashfs
