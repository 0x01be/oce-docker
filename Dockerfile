FROM alpine:3.12.0 as builder

RUN apk add --no-cache --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    git \
    build-base \
    cmake \
    mesa-dev \
    freetype-dev \
    fontconfig-dev \
    glew-dev \
    tcl-dev \
    tk-dev

RUN git clone --depth 1 https://github.com/tpaviot/oce.git /oce

# https://github.com/tpaviot/oce/issues/675
# https://stackoverflow.com/a/58576593
# https://dev.alpinelinux.org/~clandmeter/other/forum.alpinelinux.org/comment/690.html#comment-690
COPY oce.patch /oce/
WORKDIR /oce
RUN patch -p0 < oce.patch
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

RUN mkdir /oce/build
WORKDIR /oce/build

RUN cmake -DOCE_INSTALL_PREFIX:PATH=/opt/oce/  \
    -DOCE_WITH_FREEIMAGE:BOOL=ON \
    -DOCE_WITH_GL2PS:BOOL=ON \
    -DOCE_DRAW:BOOL=ON \
    ..
RUN make
RUN make install/strip

