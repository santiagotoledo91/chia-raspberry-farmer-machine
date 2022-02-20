#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

echo "${GREEN}-> Executing Stage 3${NC}"

echo "${GREEN}-> Add your mnemonic words${NC}"
chia keys add

echo "${GREEN}-> Enabling the chia-farmer service${NC}"
sudo systemctl enable chia-farmer.service

echo "${GREEN}-> Cleaning up install files${NC}"
sudo rm /home/ubuntu/install-stage-1.sh
sudo rm /home/chia/install-stage-2.sh
sudo rm /home/chia/install-stage-3.sh

bash /home/chia/scripts/restore.sh

echo "${GREEN}-> Stage 3 finished!${NC}"
