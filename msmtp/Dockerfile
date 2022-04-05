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
RUN dget -u http://snapshot.debian.org/archive/debian/20220224T210146Z/pool/main/m/msmtp/msmtp_1.8.16-1.dsc && \
    mk-build-deps --install \
      -t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y -t focal-backports" \
      msmtp-1.8.16/debian/control

COPY msmtp-autoreconf.patch /usr/src/msmtp-autoreconf.patch
RUN rm *.debian.tar.* *.dsc *.deb

WORKDIR /usr/src/msmtp-1.8.16
RUN patch -p1 < ../msmtp-autoreconf.patch && rm ../msmtp-autoreconf.patch
RUN DEBFULLNAME=Caketop DEBEMAIL="packages@caketop.app" EDITOR=/bin/true dpkg-source --commit . autoreconf
RUN DEBFULLNAME=Caketop DEBEMAIL="packages@caketop.app" dch --distribution focal --local .caketop.focal.$(date --iso-8601=seconds | sed 's/[^0-9]\+//g') "Automatic build"
RUN DEB_BUILD_OPTIONS="nocheck nodoc" dpkg-buildpackage

WORKDIR /usr/src
RUN rm -rf msmtp-1.8.16

FROM scratch AS packages

COPY --from=build /usr/src/* /
