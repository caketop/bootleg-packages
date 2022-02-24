FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y -t focal-backports && \
    apt-get install --no-install-recommends -y -t focal-backports \
      build-essential \
      ca-certificates \
      curl \
      devscripts \
      equivs \
      locales && \
    apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

WORKDIR /usr/src
RUN dget -u http://snapshot.debian.org/archive/debian/20220224T145813Z/pool/main/o/ostree/ostree_2022.1-3.dsc && \
    mk-build-deps --install \
      -t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y -t focal-backports" \
      ostree-2022.1/debian/control

WORKDIR /usr/src/ostree-2022.1
RUN dpkg-buildpackage
