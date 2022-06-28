#!/bin/bash

while true; do
  # Remove exited containers
  docker ps -a -q -f status=exited    | xargs --no-run-if-empty docker rm -v
  # Remove dangling images
  #docker images -f "dangling=true" -q | xargs --no-run-if-empty docker rmi
  docker image prune --all --force
  # Remove dangling volumes
  docker volume ls -qf dangling=true  | xargs --no-run-if-empty docker volume rm
  
  
  
  if ! [ -x "$(command -v crictl)" ]; then
  echo 'Error: git is not installed.' >&2
  else
  crictl rmi --prune
  fi


  # DOCKER_CLEAN_INTERVAL defaults to 30min
  sleep $DOCKER_CLEAN_INTERVAL
done
