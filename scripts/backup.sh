#!/usr/bin/env bash

BKP1="/home/chia/farmer-disks/chia-fd-1/chia-backup"
BKP2="/home/chia/farmer-disks/chia-fd-2/chia-backup"

echo  "$(date) | Starting backup"

if test -d $BKP1; then
  echo "$(date) | -> Current backup found, rotating"
  echo "$(date) | --> Removing old backup"
  rm -rf "${BKP2}"
  echo "$(date) | --> Moving ${BKP1} to ${BKP2}"
  mv "${BKP1}" "${BKP2}"
  echo "$(date) | --> Assigning ${BKP2} to chia:chia"
  chown -R chia:chia "${BKP2}"
fi

echo "$(date) | -> Creating backup directory"
mkdir "${BKP1}"

echo "$(date) | -> Stopping the chia-farmer service"
systemctl stop chia-farmer.service

echo "$(date) | -> Starting new backup"

echo "$(date) | --> Backing up the wallet db"
cp /home/chia/.chia/mainnet/wallet/db/blockchain_wallet_v1_mainnet_*.sqlite "${BKP1}/"

echo "$(date) | --> Backing up the blockchain db"
cp /home/chia/.chia/mainnet/db/blockchain_v1_mainnet.sqlite "${BKP1}/"

echo "$(date) | --> Assigning ${BKP1} to chia:chia"
chown -R chia:chia "${BKP1}"

echo "$(date) | -> Starting the chia-farmer service"
systemctl start chia-farmer.service

echo "$(date) | Backup complete!"
