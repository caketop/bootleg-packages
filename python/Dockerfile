ARG PYTHON_RELEASE=3.10
ARG PYTHON_PATCH=4
ARG PYTHON_VERSION=${PYTHON_RELEASE}.${PYTHON_PATCH}
ARG JEMALLOC_VERSION=5.2.1

FROM ubuntu:20.04 AS builder_base

ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8

RUN set -x && \
  sed 's/# deb-src/deb-src/' -i /etc/apt/sources.list && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y -t focal-backports \
    build-essential curl debhelper devscripts dpkg-dev git software-properties-common xz-utils && \
  add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
  apt-get install -y gcc-11 g++-11 cpp-11

RUN groupadd -g 1000 builder && useradd -m -u 1000 -g builder builder

ENV MY_CFLAGS="-ffile-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security" \
    MY_LDFLAGS="-Wl,-z,relro" \
    MY_CPPFLAGS="-Wdate-time -D_FORTIFY_SOURCE=2"

########################################################################

FROM builder_base AS python_build

ARG PYTHON_RELEASE PYTHON_PATCH PYTHON_VERSION JEMALLOC_VERSION

RUN set -x && \
  apt-get update && \
  apt-get install -y -t focal-backports \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

RUN apt-get build-dep -y python3-defaults

ENV PYTHON_PREFIX=/opt/python-${PYTHON_RELEASE}
RUN mkdir "${PYTHON_PREFIX}" && chown builder:builder "${PYTHON_PREFIX}"

ENV JEMALLOC_PREFIX=/opt/jemalloc
RUN mkdir "${JEMALLOC_PREFIX}" && chown builder:builder "${JEMALLOC_PREFIX}"

USER builder
WORKDIR /home/builder

ENV PATH=${PYTHON_PREFIX}/bin:$PATH

RUN mkdir /home/builder/jemalloc-build
WORKDIR /home/builder/jemalloc-build

RUN set -x && \
  curl -L "https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2" -o "jemalloc-${JEMALLOC_VERSION}.tar.bz2" && \
  tar xvjf "jemalloc-${JEMALLOC_VERSION}.tar.bz2" && \
  cd "jemalloc-${JEMALLOC_VERSION}" && \
  env CC=gcc-11 \
      CFLAGS="${MY_CFLAGS} -g" \
      CPPFLAGS="${MY_CPPFLAGS}" \
      LDFLAGS="${MY_LDFLAGS}" \
      ./configure --prefix="${JEMALLOC_PREFIX}" && \
  make install_lib_static

RUN mkdir /home/builder/python-build
WORKDIR /home/builder/python-build

# It's questionable if adding PROFILE_TASK="-m test --pgo-extended" below
# make the interpreter meaningfully faster, but it'll sure make it take
# longer to build.

RUN set -x && \
  curl -L "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz" -o "Python-${PYTHON_VERSION}.tar.xz" && \
  tar -xf "Python-${PYTHON_VERSION}.tar.xz" && \
  cd "Python-${PYTHON_VERSION}" && \
  env CC=gcc-11 \
      CFLAGS="${MY_CFLAGS} -fno-semantic-interposition" \
      CFLAGS_NODIST="-g -fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free -L ${JEMALLOC_PREFIX}/lib -ljemalloc_pic" \
      CPPFLAGS="${MY_CPPFLAGS}" \
      LDFLAGS="${MY_LDFLAGS} -Wl,-rpath=${PYTHON_PREFIX}/lib" \
      ./configure --prefix "${PYTHON_PREFIX}" --enable-shared --without-static-libpython --enable-optimizations --with-lto && \
      cp Makefile Makefile.orig && \
      sed \
        -e 's/PGO_PROF_GEN_FLAG=.*$/PGO_PROF_GEN_FLAG=-fprofile-generate -fprofile-update=prefer-atomic/' \
        -e 's/PGO_PROF_USE_FLAG=.*$/PGO_PROF_USE_FLAG=-fprofile-use -fprofile-correction -fprofile-partial-training/' \
        -i Makefile && \
      (diff -dpru Makefile.orig Makefile || true) && \
      make -j$(( $(nproc) + 1 )) && \
      make install && \
      (cd "${PYTHON_PREFIX}/lib/python${PYTHON_RELEASE}" && rm -rf \
        ctypes/test \
        distutils/tests \
        idlelib/idle_test \
        lib2to3/tests \
        test \
        tkinter/test \
        unittest/test)

RUN python3 -m pip install --upgrade pip setuptools wheel

RUN mkdir -p /home/builder/optpython-build/optpython${PYTHON_RELEASE}-${PYTHON_VERSION}
WORKDIR /home/builder/optpython-build/optpython${PYTHON_RELEASE}-${PYTHON_VERSION}

COPY --chown=builder optpython/Makefile /home/builder/optpython-build/optpython${PYTHON_RELEASE}-${PYTHON_VERSION}/Makefile
COPY --chown=builder optpython/debian/ /home/builder/optpython-build/optpython${PYTHON_RELEASE}-${PYTHON_VERSION}/debian/

RUN set -x && \
    sed "s/@PYTHON_RELEASE@/${PYTHON_RELEASE}/" -i Makefile && \
    sed "s/@PYTHON_RELEASE@/${PYTHON_RELEASE}/" -i debian/control && \
    cp /home/builder/python-build/Python-${PYTHON_VERSION}/LICENSE debian/copyright && \
    env DEBFULLNAME=Caketop \
        DEBEMAIL="packages@caketop.app" \
        EDITOR=/bin/true \
        dch --create \
          --package "optpython${PYTHON_RELEASE}" \
          -v "${PYTHON_VERSION}-$(date --iso-8601=seconds | sed 's/[^0-9]\+//g')+focal" \
          --distribution focal "Python ${PYTHON_VERSION}"

RUN dpkg-buildpackage --build=binary -us -ui -uc

########################################################################

FROM builder_base AS python_dev

ARG PYTHON_RELEASE

COPY --from=python_build /home/builder/optpython-build/optpython*.deb /tmp

RUN apt-get update && env DEBIAN_FRONTEND=noninteractive apt install -y /tmp/optpython*.deb
ENV PATH=/opt/python-${PYTHON_RELEASE}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

########################################################################

FROM scratch AS packages

COPY --from=python_build /home/builder/optpython-build/*.deb /
COPY --from=python_build /home/builder/optpython-build/*.ddeb /
