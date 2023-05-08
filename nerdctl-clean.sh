#!/bin/bash

while true; do  
  if ! [ -x "$(command -v nerdctl)" ]; then
  echo 'Error: nerdctl is not installed.' >&2
  else
  nerdctl image prune --all --force
  nerdctl container prune -f
  nerdctl volume prune -f
  nerdctl -n k8s.io image prune --all --force
  nerdctl -n k8s.io container prune -f
  nerdctl -n k8s.io volume prune -f
  fi

  # CONATINERD_CLEAN_INTERVAL defaults to 30min
  sleep $CONATINERD_CLEAN_INTERVAL
done
