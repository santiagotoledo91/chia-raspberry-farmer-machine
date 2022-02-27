#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

DOCKER_COMPOSE="docker-compose -f ~/chia/docker-compose.yml"

BKP1="${HOME}/chia/disks/chia-fd-1/chia-backup"
BKP2="${HOME}/chia/disks/chia-fd-2/chia-backup"

echo  "$(date) | ${GREEN}->Starting backup"

if test -d "${BKP1}"; then
  echo "$(date) | ${GREEN}-> Current backup found, rotating"
  echo "$(date) | ${GREEN}--> Removing old backup"
  rm -rf "${BKP2}"
  echo "$(date) | ${GREEN}--> Moving ${BKP1} to ${BKP2}"
  mv "${BKP1}" "${BKP2}"
fi

echo "$(date) | ${GREEN}-> Creating backup directory"
mkdir "${BKP1}"

echo "$(date) | ${GREEN}-> Stopping the chia-farmer service"
${DOCKER_COMPOSE} stop chia

sleep 10

echo "$(date) | ${GREEN}-> Starting new backup"

echo "$(date) | ${GREEN}--> Backing up the wallet db"
cp ~/chia/.chia/mainnet/wallet/db/blockchain_wallet_v1_mainnet_*.sqlite "${BKP1}/"

echo "$(date) | ${GREEN}--> Backing up the blockchain db"
cp ~/chia/.chia/mainnet/db/blockchain_v1_mainnet.sqlite "${BKP1}/"

echo "$(date) | ${GREEN}-> Starting the chia-farmer service"
${DOCKER_COMPOSE} start chia

echo "$(date) | ${GREEN}-> Adding nodes to speed up the sync${NC}"
${DOCKER_COMPOSE} exec -d bash /scripts/add-nodes.sh

echo "$(date) | ${GREEN}-> Backup complete!"
