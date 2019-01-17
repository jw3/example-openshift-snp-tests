#!/usr/bin/env bash

set -xe

sbt clean docker:stage

# hack in the group id mod for openshift to reduce image size
if [[ $(id -u) -eq 0 ]]; then
  echo "=== performing group modifications ==="
  chgrp -R 0 target/docker/stage/opt
  chmod -R g+rwX target/docker/stage/opt
fi

docker build -t myimage target/docker/stage
