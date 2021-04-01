#!/usr/bin/env bash

set -euo pipefail

nodeArch="$(uname -m)"

runner_image='klud/gitlab-runner'

case "$nodeArch" in
    aarch64) runnerArch='arm64' ;;
    armhf) runnerArch='arm' ;;
    armv7l) runnerArch='arm' ;;
    x86_64) runnerArch='amd64' runner_image='gitlab/gitlab-runner:alpine' ;;
    *) echo >&2 "error: unsupported architecture ($nodeArch)"; exit 1 ;;
esac

docker run \
    -d \
    --name runner \
    --platform=${run_as_platform} \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $HOME/.runner:/etc/gitlab-runner \
    $runner_image

docker exec -it runner \
    gitlab-runner \
    register \
    -n \
    --locked=false \
    --url ${gitlab_site} \
    --registration-token ${gitlab_token} \
    --executor docker \
    --description "$runnerArch runner" \
    --docker-image "docker:17.12" \
%{ if add_tags ~}
    --tag-list "docker,${run_as_platform}" \
%{ endif ~}
%{ if run_untagged ~}
    --run-untagged \
%{ endif ~}
    --docker-privileged

sudo sed -i -e 's|concurrent = 1|concurrent = ${concurrency}|g' $HOME/.runner/config.toml
sudo sed -i -e 's|"/cache"|"/var/run/docker.sock:/var/run/docker.sock","/cache"|g' $HOME/.runner/config.toml

docker restart runner
