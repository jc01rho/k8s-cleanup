#!/bin/bash

while true; do  
  sync
  echo 1 > /proc/sys/vm/compact_memory
  echo 3 > /proc/sys/vm/drop_caches
  sync

  # CONATINERD_CLEAN_INTERVAL defaults to 30min
  sleep $DROP_CACHES_INTERVAL
done
