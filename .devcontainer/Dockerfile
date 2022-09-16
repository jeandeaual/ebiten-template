# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/go/.devcontainer/base.Dockerfile

ARG VARIANT="1.19-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/go:0-${VARIANT}

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        # Required by Ebiten
        libasound2-dev \
        libgl1-mesa-dev \
        libxcursor-dev \
        libxi-dev \
        libxinerama-dev \
        libxrandr-dev \
        libxxf86vm-dev \
        # Additional tools
        xz-utils \
        brotli \
    && rm -rf /var/lib/apt/lists/*

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.49.0

USER vscode

RUN go install golang.org/x/tools/cmd/godoc@v0.1.12 \
    && go install github.com/hajimehoshi/ebiten/v2/cmd/ebitenmobile@v2.4.3 \
    && go install github.com/hajimehoshi/wasmserve@latest
