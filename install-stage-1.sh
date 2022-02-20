#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

echo "${GREEN}-> Executing Stage 1${NC}"

if id "chia" &>/dev/null; then
  echo "${GREEN}-> Chia user already created!${NC}"
else
  echo "${GREEN}-> Creating the 'chia' user${NC}"
  sudo adduser --disabled-password --gecos "" chia
  echo "${GREEN}-> Adding the 'chia' user to 'sudo' and 'video' groups ${NC}"
  sudo usermod -aG sudo,video chia
  echo "${GREEN}-> Set a password for the 'chia' user${NC}"
  sudo passwd chia
fi

if [[ $(sudo grep "# Custom config" /home/chia/.profile) != "" ]]; then
  echo "${GREEN}-> Chia profile already configured!${NC}"
else
  echo "${GREEN}-> Configuring chia profile${NC}"
  cat <<EOT | sudo tee -a /home/chia/.profile
# Custom config
source ~/chia-blockchain/activate 2>/dev/null || echo "Unable to load venv, chia not installed yet"

alias reboot="sudo systemctl stop chia-farmer.service && shutdown -r now"
alias bash-edit="vim ~/.profile"
alias bash-reload="source ~/.profile"
alias chia-logs="tail -f /home/chia/.chia/mainnet/log/debug.log"
alias chia-add-nodes="curl https://chia.keva.app/ | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do timeout 5s chia show -a \$line:8444 ;done"
alias temp-cpu="vcgencmd measure_temp"
EOT
fi

if sudo test -f /home/chia/install-stage-2.sh; then
  echo "${GREEN}-> Stage 2 script already downloaded!${NC}"
else
  echo "${GREEN}-> Downloading Stage 2 script${NC}"
  sudo curl -L https://raw.githubusercontent.com/santiagotoledo91/chia-raspberry-farmer-machine/main/install-stage-2.sh -o /home/chia/install-stage-2.sh
  sudo chown chia:chia /home/chia/install-stage-2.sh
  sudo chmod 755 /home/chia/install-stage-2.sh
fi

if sudo test -f /home/chia/install-stage-3.sh; then
  echo "${GREEN}-> Stage 3 script already downloaded!${NC}"
else
  echo "${GREEN}-> Downloading Stage 3 script${NC}"
  sudo curl -L https://raw.githubusercontent.com/santiagotoledo91/chia-raspberry-farmer-machine/main/install-stage-3.sh -o /home/chia/install-stage-3.sh
  sudo chown chia:chia /home/chia/install-stage-3.sh
  sudo chmod 755 /home/chia/install-stage-3.sh
fi

if [[ $(timedatectl | grep Europe/Madrid) != "" ]]; then
  echo "${GREEN}-> Timezone already set!${NC}"
else
  echo "${GREEN}-> Setting the timezone to Europe/Madrid${NC}"
  sudo timedatectl set-timezone Europe/Madrid
fi

if [[ $(sudo grep "# Overclocking" /boot/firmware/config.txt) != "" ]]; then
  echo "${GREEN}-> Already overclocked to 2Ghz!${NC}"
else
  echo "${GREEN}-> Overclocking to 2Ghz${NC}"
  echo -e "\n# Overclocking\nover_voltage=6\narm_freq=2000" | sudo tee -a /boot/firmware/config.txt
  echo "${GREEN}-> Overclocked! This will make things a bit faster${NC}"
fi

echo "${GREEN}Stage 1 finished!"
read -n 1 -s -r -p "${RED}-> Press any key to reboot...${NC}"
sudo reboot now
