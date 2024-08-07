FROM ubuntu:24.04 AS org
ARG OPENFOAM_VERSION=12

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    wget \
    software-properties-common \
 && sh -c "wget -O - https://dl.openfoam.org/gpg.key > /etc/apt/trusted.gpg.d/openfoam.asc" \
 && add-apt-repository -y http://dl.openfoam.org/ubuntu \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    openfoam${OPENFOAM_VERSION} \
 && rm -rf /var/lib/apt/lists/*

COPY openfoam /openfoam

SHELL ["/bin/bash", "-c"]

RUN echo ". /opt/openfoam${OPENFOAM_VERSION}/etc/bashrc" >> /openfoam/profile.sh \
 # smoke test
 && . /openfoam/profile.sh \
 && blockMesh -help

ENTRYPOINT ["/openfoam/run"]
CMD ["bash"]


FROM ubuntu:24.04 AS slim
ARG OPENFOAM_VERSION=2406

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
   curl \
   ca-certificates \
 && curl https://dl.openfoam.com/add-debian-repo.sh | bash \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
   openfoam${OPENFOAM_VERSION} \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /usr/bin/openfoam${OPENFOAM_VERSION} /usr/local/bin/openfoam

COPY openfoam /openfoam

SHELL ["/bin/bash", "-c"]

RUN echo ". /usr/lib/openfoam/openfoam${OPENFOAM_VERSION}/etc/bashrc" >> /openfoam/profile.sh \
 # smoke test
 && . /openfoam/profile.sh \
 && blockMesh -help
 
ENTRYPOINT ["/openfoam/run"]
CMD ["/usr/local/bin/openfoam"]


FROM slim

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
   openfoam${OPENFOAM_VERSION}-default \
 && rm -rf /var/lib/apt/lists/*
