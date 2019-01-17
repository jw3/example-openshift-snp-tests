#!/usr/bin/env bash

set -xe

if [[ "$@" =~ "clean" ]]; then sbt clean docker:stage; fi
if [[ "$@" =~ "multi" ]]; then cp Dockerfile.multistage target/docker/stage/Dockerfile; fi

# hack in the group id mod for openshift to reduce image size
if [[ $(id -u) -eq 0 ]]; then
  echo "=== performing group modifications ==="
  chgrp -R 0 target/docker/stage/opt
  chmod -R g+rwX target/docker/stage/opt
fi

docker build --no-cache -t "myimage:$1" target/docker/stage
