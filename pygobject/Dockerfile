ARG PYTHON_RELEASE=3.10
ARG PYGOBJECT_VERSION=3.42.0

FROM caketop/python-build:latest AS python_apt_build

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

FROM scratch AS packages

COPY --from=python_apt_build /home/builder/pygobject-build/*.deb /
COPY --from=python_apt_build /home/builder/pygobject-build/*.ddeb /
