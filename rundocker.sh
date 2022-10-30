#!/usr/bin/env bash

# Evitar erro com o uso de video
xhost +local:docker

DOCKER_IMAGE="fbot/firasim:latest"

# Executando o docker
docker run  -it \
            --rm \
            --gpus all \
            --privileged \
            --net=host \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -e DISPLAY=$DISPLAY \
            -e QT_X11_NO_MITSHM=1 \
            $DOCKER_IMAGE
