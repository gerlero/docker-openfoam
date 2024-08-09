# Docker images of OpenFOAM

[![CI](https://github.com/gerlero/docker-openfoam/actions/workflows/ci.yml/badge.svg)](https://github.com/gerlero/docker-openfoam/actions/workflows/ci.yml)
![OpenFOAM](https://img.shields.io/badge/openfoam-.com%20|%20.org-informational)
[![Docker image](https://img.shields.io/badge/docker%20image-microfluidica%2Fopenfoam-0085a0)](https://hub.docker.com/r/microfluidica/openfoam/)

## Usage

### With `docker run`

Assuming you have [Docker](https://www.docker.com) installed, the following command will run the image and mount the current directory so that you can access the files in it.

```bash
docker run --rm -it -v $PWD:/root -w /root microfluidica/openfoam:tagname
```

Replace `tagname` with the desired tag as listed below (or leave the tag empty to get the `latest` tag).

### With OpenFOAM's [`openfoam-docker`](https://develop.openfoam.com/Development/openfoam/-/wikis/precompiled/docker) launch script

```bash
openfoam-docker -image=microfluidica/openfoam:tagname
```

### With Apptainer/Singularity

```bash
apptainer run docker://microfluidica/openfoam:tagname
```

## Available tags

### openfoam.com

- `latest`, `com`, `2406`
- `slim`, `com-slim`, `2406-slim`
- `2312`
- `2312-slim`
- `2306`
- `2306-slim`
- `2212`
- `2212-slim`
- `2206`
- `2206-slim`
- `2112`
- `2112-slim`
- `2106`
- `2106-slim`
- `2012` (amd64 only)
- `2012-slim` (amd64 only)
- `2006`
- `2006-slim`
- `1912` (amd64 only)
- `1912-slim` (amd64 only)

### openfoam.org

- `org`, `12`
- `11`
- `10` (amd64 only)
- `9` (amd64 only)
- `8` (amd64 only)
- `7` (amd64 only)
- `6` (amd64 only)
- `5` (amd64 only)
