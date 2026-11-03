ARG UBUNTU_VERSION=26.04

FROM ubuntu:${UBUNTU_VERSION} AS base

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    libnss-wrapper \
 && rm -rf /var/lib/apt/lists/*

ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

ENTRYPOINT ["/openfoam/run"]


FROM base AS org
ARG OPENFOAM_VERSION=14

# Signing key from https://dl.openfoam.org/gpg.key
COPY openfoam-org.asc /etc/apt/keyrings/openfoam-org.asc

RUN echo "deb [signed-by=/etc/apt/keyrings/openfoam-org.asc] http://dl.openfoam.org/ubuntu $(sed -ne 's/^VERSION_CODENAME=//p' /etc/os-release) main" >> /etc/apt/sources.list.d/openfoam.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    openfoam${OPENFOAM_VERSION} \
 && rm -rf /var/lib/apt/lists/*

COPY openfoam /openfoam

RUN ln -s /opt/openfoam${OPENFOAM_VERSION}/etc/bashrc /openfoam/profile.rc

SHELL ["/openfoam/bash", "-c"]

# smoke tests
RUN blockMesh -help \
 && wmake -help

CMD ["bash"]


FROM base AS extend
ARG OPENFOAM_VERSION=5.0

ADD --checksum=sha256:f6ea75a00a171f76071ae35b2de148d6b1d3051690a9de81e807c9403e808c84 \
    https://downloads.sourceforge.net/project/foam-extend/foam-extend-${OPENFOAM_VERSION}/foam-extend-${OPENFOAM_VERSION}_amd64_Ubuntu2204_77674d770.deb \
    /tmp/foam-extend.deb

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    /tmp/foam-extend.deb \
 && rm -rf /var/lib/apt/lists/* /tmp/foam-extend.deb

COPY openfoam /openfoam

RUN ln -s /opt/foam/foam-extend-${OPENFOAM_VERSION}/etc/bashrc /openfoam/profile.rc

SHELL ["/openfoam/bash", "-c"]

# smoke tests
RUN blockMesh -help \
 && command -v wmake

CMD ["bash"]


FROM base AS slim-base
ARG OPENFOAM_VERSION=2606

# Signing key from https://dl.openfoam.com/pubkey.gpg
COPY openfoam-com.asc /etc/apt/keyrings/openfoam-com.asc

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
 && echo "deb [signed-by=/etc/apt/keyrings/openfoam-com.asc] https://dl.openfoam.com/repos/deb $(sed -ne 's/^VERSION_CODENAME=//p' /etc/os-release) main" >> /etc/apt/sources.list.d/openfoam.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
   openfoam${OPENFOAM_VERSION} \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /usr/bin/openfoam${OPENFOAM_VERSION} /usr/local/bin/openfoam


FROM slim-base AS slim

COPY openfoam /openfoam

RUN ln -s /usr/lib/openfoam/openfoam${OPENFOAM_VERSION}/etc/bashrc /openfoam/profile.rc

SHELL ["/openfoam/bash", "-c"]

# smoke test
RUN blockMesh -help

CMD ["/usr/local/bin/openfoam"]


FROM slim-base

RUN apt-get update \
 && ([ ${OPENFOAM_VERSION} -ge 2012 ] || DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
   build-essential) \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
   openfoam${OPENFOAM_VERSION}-default \
 && rm -rf /var/lib/apt/lists/*

COPY openfoam /openfoam

RUN ln -s /usr/lib/openfoam/openfoam${OPENFOAM_VERSION}/etc/bashrc /openfoam/profile.rc

SHELL ["/openfoam/bash", "-c"]

# smoke tests
RUN blockMesh -help \
 && wmake -help

CMD ["/usr/local/bin/openfoam"]
