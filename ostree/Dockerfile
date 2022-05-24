FROM ubuntu:20.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y -t focal-backports && \
    apt-get install --no-install-recommends -y -t focal-backports \
      build-essential \
      ca-certificates \
      curl \
      devscripts \
      equivs \
      libdistro-info-perl \
      locales && \
    apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

WORKDIR /usr/src
RUN dget -u http://snapshot.debian.org/archive/debian/20220404T205647Z/pool/main/o/ostree/ostree_2022.2-3.dsc && \
    mk-build-deps --install \
      -t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y -t focal-backports" \
      ostree-2022.2/debian/control

COPY *.patch /usr/src/

RUN rm *.debian.tar.* *.dsc *.deb

WORKDIR /usr/src/ostree-2022.2
RUN patch -p1 < ../ostree-caketop.patch && rm ../ostree-caketop.patch
RUN patch -p1 < ../no-grub-cfg-header.patch && rm ../no-grub-cfg-header.patch

RUN EDITOR=/bin/true DEBFULLNAME=Caketop DEBEMAIL="packages@caketop.app" dpkg-source --commit . no-grub-cfg-header
RUN DEBFULLNAME=Caketop DEBEMAIL="packages@caketop.app" dch --distribution focal --local .$(date --iso-8601=seconds | sed 's/[^0-9]\+//g') "Automatic build"
RUN DEB_BUILD_OPTIONS="nocheck nodoc" dpkg-buildpackage

WORKDIR /usr/src
RUN rm -rf ostree-2022.2

FROM scratch AS packages

COPY --from=build /usr/src/* /
