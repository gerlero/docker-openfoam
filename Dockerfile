ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} AS org
ARG OPENFOAM_VERSION=12

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    wget \
    software-properties-common \
    libnss-wrapper \
 && sh -c "wget -O - https://dl.openfoam.org/gpg.key > /etc/apt/trusted.gpg.d/openfoam.asc" \
 && add-apt-repository -y http://dl.openfoam.org/ubuntu \
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

ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

ENTRYPOINT ["/openfoam/run"]
CMD ["bash"]


FROM ubuntu:${UBUNTU_VERSION} AS slim-base
ARG OPENFOAM_VERSION=2406

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
   curl \
   ca-certificates \
   libnss-wrapper \
 && curl https://dl.openfoam.com/add-debian-repo.sh | bash \
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

ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

ENTRYPOINT ["/openfoam/run"]
CMD ["/usr/local/bin/openfoam"]


FROM slim-base

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
   openfoam${OPENFOAM_VERSION}-default \
 && rm -rf /var/lib/apt/lists/*

COPY openfoam /openfoam

RUN ln -s /usr/lib/openfoam/openfoam${OPENFOAM_VERSION}/etc/bashrc /openfoam/profile.rc

SHELL ["/openfoam/bash", "-c"]

# smoke tests
RUN blockMesh -help \
 && wmake -help

ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

ENTRYPOINT ["/openfoam/run"]
CMD ["/usr/local/bin/openfoam"]
 