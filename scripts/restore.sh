#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

BKP1="/home/chia/farmer-disks/chia-fd-1/chia-backup"

if ! sudo test -d $BKP1; then
  echo "$(date) | {RED}-> Whoops! Looks like there is no backup on ${BKP1}${NC}"
  exit 1
fi

echo "$(date) | ${GREEN}-> Starting restore${NC}"

echo "$(date) | ${GREEN}-> Stopping chia-farmer.service${NC}"
sudo systemctl stop chia-farmer.service

echo "$(date) | ${GREEN}-> Restoring wallet backup from ${BKP1}${NC}"
rm -rf /home/chia/.chia/mainnet/wallet
mkdir -p /home/chia/.chia/mainnet/wallet/db
cp -r /home/chia/farmer-disks/chia-fd-1/chia-backup/blockchain_wallet_v1_mainnet_*.sqlite /home/chia/.chia/mainnet/wallet/db/

echo "$(date) | ${GREEN}-> Restoring blockchain backup from /home/chia/farmer-disks/chia-fd-1${NC}"
rm -rf /home/chia/.chia/mainnet/db
mkdir -p /home/chia/.chia/mainnet/db
cp -r /home/chia/farmer-disks/chia-fd-1/chia-backup/blockchain_v1_mainnet.sqlite /home/chia/.chia/mainnet/db/

echo "$(date) | ${GREEN}-> Starting chia-farmer.service${NC}"
sudo systemctl start chia-farmer.service

echo "$(date) | ${GREEN}-> Adding nodes to speed up the sync${NC}"
bash -c "curl https://chia.keva.app/ | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do timeout 5s chia show -a \$line:8444 ;done"

echo "$(date) | ${GREEN}-> Done!${NC}"

