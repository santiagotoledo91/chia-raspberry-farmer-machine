#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

echo "${GREEN}-> Executing Stage 2${NC}"

echo "${GREEN}-> Starting environment${NC}"
docker-compose up -d

echo "${GREEN}-> Add your mnemonic words${NC}"
docker-compose exec -it chia venv/bin/chia keys add

# TODO fix?
bash /home/chia/scripts/restore.sh

echo "${GREEN}-> Stage 3 finished!${NC}"


