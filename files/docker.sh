#!/usr/bin/env bash

set -euo pipefail

nodeArch="$(uname -m)"

case "$nodeArch" in
    aarch64) hostArch='arm64' ;;
    armhf) hostArch='armhf' ;;
    armv7l) hostArch='arm' ;;
    x86_64) hostArch='amd64' ;;
    *) echo >&2 "error: unsupported architecture ($nodeArch)"; exit 1 ;;
esac

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository -y \
   "deb [arch=${hostArch}] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker ubuntu
