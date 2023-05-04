#!/bin/bash

while true; do  
  if ! [ -x "$(command -v crictl)" ]; then
  echo 'Error: crictl is not installed.' >&2
  else
  crictl rmi --prune
  crictl  ps --all | grep Exited | awk '{print $1}' | xargs crictl rm
  fi

  # CONATINERD_CLEAN_INTERVAL defaults to 30min
  sleep $CONATINERD_CLEAN_INTERVAL
done
