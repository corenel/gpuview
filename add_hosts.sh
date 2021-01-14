#!/usr/bin/env bash

for node_id in 60 61 70 71 72 73 80 81 84 85 86; do
  echo "add node${node_id}"
  sudo gpuview add --url http://192.168.199.${node_id}:9988 --name node${node_id}
done 

echo "all hosts"
sudo gpuview hosts
