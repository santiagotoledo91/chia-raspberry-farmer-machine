#!/usr/bin/env bash

NODES=$(curl -s 'https://chia.keva.app' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

for NODE_IP in ${NODES}; do
 timeout 5s chia show -a "${NODE_IP}:8444"
done

echo "Nodes added!"
