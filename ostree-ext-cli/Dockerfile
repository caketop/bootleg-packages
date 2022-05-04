ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG OSTREE_EXT_VERSION=0.7.1
ARG OSTREE_EXT_TAG=ostree-ext-v${OSTREE_EXT_VERSION}

FROM ubuntu:20.04 AS ostree_ext_cli_build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl git gnupg && \
    curl -s https://packagecloud.io/install/repositories/caketop/bootleg-packages/script.deb.sh | bash && \
    apt-get install -y build-essential debhelper devscripts dpkg-dev libostree-dev libssl-dev && \
    apt-get clean

ARG USERNAME USER_UID USER_GID

RUN groupadd -g ${USER_GID} ${USERNAME} && useradd -m -u ${USER_UID} -g ${USERNAME} -s /bin/bash ${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}
ENV USER=${USERNAME} SHELL=/bin/bash

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

ENV PATH=/home/${USERNAME}/.cargo/bin:$PATH

ARG OSTREE_EXT_TAG

RUN cargo install --git https://github.com/ostreedev/ostree-rs-ext --tag ${OSTREE_EXT_TAG}

RUN mkdir -p /home/${USERNAME}/deb-build/ostree-ext-cli/
WORKDIR /home/${USERNAME}/deb-build/ostree-ext-cli/

COPY --chown=${USERNAME} ostree-ext-cli/Makefile /home/${USERNAME}/deb-build/ostree-ext-cli/Makefile
COPY --chown=${USERNAME} ostree-ext-cli/debian/ /home/${USERNAME}/deb-build/ostree-ext-cli/debian/

ARG OSTREE_EXT_VERSION OSTREE_EXT_TAG

RUN set -x && \
    cp ~/.cargo/bin/ostree-ext-cli /home/${USERNAME}/deb-build/ostree-ext-cli/ostree-ext-cli && \
    curl https://github.com/ostreedev/ostree-rs-ext/blob/${OSTREE_EXT_TAG}/LICENSE-MIT -o debian/copyright && \
    env DEBFULLNAME=Caketop \
        DEBEMAIL="packages@caketop.app" \
        EDITOR=/bin/true \
        dch --create \
          --package "ostree-ext-cli" \
          -v "${OSTREE_EXT_VERSION}-$(date --iso-8601=seconds | sed 's/[^0-9]\+//g')+focal" \
          --distribution focal "Installed from cargo"

RUN dpkg-buildpackage --build=binary -us -ui -uc

########################################################################

FROM scratch AS packages

ARG USERNAME

COPY --from=ostree_ext_cli_build /home/${USERNAME}/deb-build/*.deb /
COPY --from=ostree_ext_cli_build /home/${USERNAME}/deb-build/*.ddeb /
