ARG PYTHON_RELEASE=3.10
ARG LIBGUESTFS_RELEASE=1.48
ARG LIBGUESTFS_VERSION=1.48.0

FROM caketop/python-build:latest AS python_apt_build

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

FROM scratch AS packages

COPY --from=python_apt_build /home/builder/libguestfs-build/*.deb /
COPY --from=python_apt_build /home/builder/libguestfs-build/*.ddeb /
