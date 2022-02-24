ARG BASE_IMAGE=ubuntu:20.04

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
      build-essential \
      ca-certificates \
      curl \
      devscripts \
      equivs && \
    apt-get clean

WORKDIR /usr/src
RUN dget -u http://snapshot.debian.org/archive/debian/20210426T151833Z/pool/main/o/ostree/ostree_2021.2-1.dsc && \
    mk-build-deps --install \
      -t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" \
      ostree-2021.2/debian/control

WORKDIR /usr/src/ostree-2021.2
RUN dpkg-buildpackage
