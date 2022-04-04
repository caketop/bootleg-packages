ARG PYTHON_RELEASE=3.10
ARG PYTHON_PATCH=4
ARG PYTHON_VERSION=${PYTHON_RELEASE}.${PYTHON_PATCH}
ARG JEMALLOC_VERSION=5.2.1
ARG PYGOBJECT_VERSION=3.42.0
ARG PYTHON_APT_VERSION=2.3.0
ARG LIBGUESTFS_RELEASE=1.48
ARG LIBGUESTFS_VERSION=1.48.0

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

FROM builder_base AS python_base

ARG PYTHON_RELEASE

COPY --from=python_build /home/builder/optpython-build/optpython*.deb /tmp

RUN apt-get update && env DEBIAN_FRONTEND=noninteractive apt install -y /tmp/optpython*.deb
ENV PATH=/opt/python-${PYTHON_RELEASE}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

FROM python_base AS pygobject_build

ARG PYTHON_RELEASE PYGOBJECT_VERSION

RUN apt-get update && apt-get build-dep -y pygobject

USER builder

RUN mkdir -p /home/builder/pygobject-build/optpython${PYTHON_RELEASE}-gi
WORKDIR /home/builder/pygobject-build/optpython${PYTHON_RELEASE}-gi

COPY --chown=builder optpython-gi/Makefile /home/builder/pygobject-build/optpython${PYTHON_RELEASE}-gi/Makefile
COPY --chown=builder optpython-gi/debian/ /home/builder/pygobject-build/optpython${PYTHON_RELEASE}-gi/debian/

RUN set -x && \
    sed \
      -e "s/@PYTHON_RELEASE@/${PYTHON_RELEASE}/" \
      -e "s/@PYGOBJECT_VERSION@/${PYGOBJECT_VERSION}/" \
      -i Makefile && \
    sed "s/@PYTHON_RELEASE@/${PYTHON_RELEASE}/" -i debian/control && \
    curl https://gitlab.gnome.org/GNOME/pygobject/-/blob/${PYGOBJECT_VERSION}/COPYING -o debian/copyright && \
    env DEBFULLNAME=Caketop \
        DEBEMAIL="packages@caketop.app" \
        EDITOR=/bin/true \
        dch --create \
          --package "optpython${PYTHON_RELEASE}-gi" \
          -v "${PYGOBJECT_VERSION}-$(date --iso-8601=seconds | sed 's/[^0-9]\+//g')+focal" \
          --distribution focal "Converted from wheel"

RUN dpkg-buildpackage --build=binary -us -ui -uc

########################################################################

FROM python_base AS python_apt_build

ARG PYTHON_RELEASE PYTHON_APT_VERSION

RUN apt-get update && apt-get build-dep -y python-apt

USER builder

RUN mkdir -p /home/builder/python-apt-build/optpython${PYTHON_RELEASE}-apt
WORKDIR /home/builder/python-apt-build/optpython${PYTHON_RELEASE}-apt

COPY --chown=builder optpython-apt/Makefile /home/builder/python-apt-build/optpython${PYTHON_RELEASE}-apt/Makefile
COPY --chown=builder optpython-apt/debian/ /home/builder/python-apt-build/optpython${PYTHON_RELEASE}-apt/debian/

RUN set -x && \
    sed \
      -e "s/@PYTHON_RELEASE@/${PYTHON_RELEASE}/" \
      -e "s/@PYTHON_APT_VERSION@/${PYTHON_APT_VERSION}/" \
      -i Makefile && \
    sed "s/@PYTHON_RELEASE@/${PYTHON_RELEASE}/" -i debian/control && \
    curl https://salsa.debian.org/apt-team/python-apt/-/blob/${PYTHON_APT_VERSION}/COPYING.GPL -o debian/copyright && \
    env DEBFULLNAME=Caketop \
        DEBEMAIL="packages@caketop.app" \
        EDITOR=/bin/true \
        dch --create \
          --package "optpython${PYTHON_RELEASE}-apt" \
          -v "${PYTHON_APT_VERSION}-$(date --iso-8601=seconds | sed 's/[^0-9]\+//g')+focal" \
          --distribution focal "Converted from wheel"

RUN dpkg-buildpackage --build=binary -us -ui -uc

########################################################################

FROM python_base AS libguestfs_build

ARG PYTHON_RELEASE LIBGUESTFS_RELEASE LIBGUESTFS_VERSION

RUN set -x && \
    apt-get update && \
    apt-get build-dep -y libguestfs && \
    apt-get install -y linux-image-virtual-hwe-20.04 zfsutils-linux && \
    chmod 755 /boot/*

USER builder

RUN mkdir -p /home/builder/libguestfs-build
WORKDIR /home/builder/libguestfs-build

RUN curl https://download.libguestfs.org/${LIBGUESTFS_RELEASE}-stable/libguestfs-${LIBGUESTFS_VERSION}.tar.gz -o libguestfs-${LIBGUESTFS_VERSION}.tar.gz && \
  tar -xzvf libguestfs-${LIBGUESTFS_VERSION}.tar.gz && \
  rm -rf libguestfs-${LIBGUESTFS_VERSION}/debian

COPY --chown=builder libguestfs-appliance-packagelist.diff /home/builder/libguestfs-build/
COPY --chown=builder optpython-guestfs/debian/ /home/builder/libguestfs-build/libguestfs-${LIBGUESTFS_VERSION}/debian/

WORKDIR /home/builder/libguestfs-build/libguestfs-${LIBGUESTFS_VERSION}

RUN set -x && \
    sed \
      -e"s/@PYTHON_RELEASE@/${PYTHON_RELEASE}/" \
      -e"s/@LIBGUESTFS_RELEASE@/${LIBGUESTFS_RELEASE}/" \
      -i debian/control && \
    sed \
      -e "s/@PYTHON_RELEASE@/${PYTHON_RELEASE}/" \
      -e "s#@MY_CFLAGS@#${MY_CFLAGS}#"  \
      -e "s#@MY_LDFLAGS@#${MY_LDFLAGS}#"  \
      -e "s#@MY_CPPFLAGS@#${MY_CPPFLAGS}#"  \
      -i debian/rules && \
    cp COPYING.LIB debian/copyright && \
    patch -p0 < ../libguestfs-appliance-packagelist.diff && \
    echo "/usr/bin/guestfish" > debian/guestfish${LIBGUESTFS_RELEASE}.install && \
    echo "/opt/python-${PYTHON_RELEASE}/lib/*" > debian/optpython${PYTHON_RELEASE}-guestfs.install && \
    echo "/usr/lib/libguestfs-fixed-appliance/*" > debian/libguestfs${LIBGUESTFS_RELEASE}-fixed-appliance.install && \
    env DEBFULLNAME=Caketop \
        DEBEMAIL="packages@caketop.app" \
        EDITOR=/bin/true \
        dch --create \
          --package "optpython${PYTHON_RELEASE}-guestfs" \
          -v "${LIBGUESTFS_VERSION}-$(date --iso-8601=seconds | sed 's/[^0-9]\+//g')+focal" \
          --distribution focal "Built from source"

RUN DEB_BUILD_OPTIONS="nocheck nodoc" dpkg-buildpackage --build=binary -us -ui -uc

########################################################################

FROM scratch AS artifacts

COPY --from=python_build /home/builder/optpython-build/optpython*.deb /
COPY --from=python_build /home/builder/optpython-build/optpython*.ddeb /
COPY --from=python_apt_build /home/builder/python-apt-build/*.deb /
COPY --from=python_apt_build /home/builder/python-apt-build/*.ddeb /
COPY --from=pygobject_build /home/builder/pygobject-build/*.deb /
COPY --from=pygobject_build /home/builder/pygobject-build/*.ddeb /
COPY --from=libguestfs_build /home/builder/libguestfs-build/*.deb /
COPY --from=libguestfs_build /home/builder/libguestfs-build/*.ddeb /
COPY --from=libguestfs_build /home/builder/libguestfs-build/libguestfs-*/debian/tmp/usr/lib/libguestfs-fixed-appliance/appliance-*.tar.xz /
