#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

echo "${GREEN}-> Executing Stage 3${NC}"

echo "${GREEN}-> Add your mnemonic words${NC}"
chia keys add





#if [[ -d /home/chia/chia-blockchain ]]; then
#  echo "${GREEN}-> Chia blockchain already installed!${NC}"
#else
#  echo "${GREEN}-> Installing chia-blockchain${NC}"
#  echo "${GREEN}--> Cloning repository${NC}"
#  git clone https://github.com/Chia-Network/chia-blockchain.git -b latest --recurse-submodules /home/chia/chia-blockchain
#
#  echo "${GREEN}--> Moving to chia-blockchain directory${NC}"
#  cd /home/chia/chia-blockchain || exit 1
#
#  echo "${GREEN}--> Executing install script${NC}"
#  sh install.sh
#
#  echo "${GREEN}--> Loading python venv${NC}"
#  chia init
#
#  echo "${GREEN}--> Initializing${NC}"
#  chia init
#
#  echo "${GREEN}--> Fixing SSL permissions${NC}"
#  chia init --fix-ssl-permissions
#
#  echo "${GREEN}--> Add plot directories${NC}"
#  chia plots add -d '/home/chia/farmer-disks/chia-fd-1/plots'
#  chia plots add -d '/home/chia/farmer-disks/chia-fd-2/plots'
#  chia plots add -d '/home/chia/farmer-disks/chia-fd-3/plots'
#  chia plots add -d '/home/chia/farmer-disks/chia-fd-4/plots'
#  chia plots add -d '/home/chia/farmer-disks/chia-fd-5/plots'
#  chia plots add -d '/home/chia/farmer-disks/chia-fd-6/plots'
#
#  echo "${GREEN}--> Setting the log level to INFO${NC}"
#  chia configure -log-level INFO
#
#  echo "${GREEN}--> Back to previous directory${NC}"
#  cd - || exit 1
#fi

echo "${GREEN}-> Cleaning up install files${NC}"
sudo rm ~/chia/install-stage-*.sh


bash /home/chia/scripts/restore.sh

echo "${GREEN}-> Stage 3 finished!${NC}"


