ARG PYTHON_RELEASE=3.10
ARG PYTHON_APT_VERSION=2.3.0

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
