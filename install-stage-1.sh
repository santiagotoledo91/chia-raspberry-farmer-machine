#!/usr/bin/env bash

# Colors
GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

SSH_PORT=45622
FARMER_DISKS=6

echo "${GREEN}-> Executing Stage 1${NC}"

if [[ $(timedatectl | grep Europe/Madrid) == "" ]]; then
  echo "${GREEN}-> Setting the timezone to Europe/Madrid${NC}"
  sudo timedatectl set-timezone Europe/Madrid
fi

if ! grep -q -E "^docker:" /etc/group; then
  echo "${GREEN}-> Creating the 'docker' group${NC}"
  sudo groupadd docker
fi

if ! grep -q "docker" "$(groups)"; then
  echo "${GREEN}-> Adding ${USER} to 'docker' group ${NC}"
  sudo usermod -aG docker "${USER}"
fi

if ! grep -q "# Custom config" ~/.profile; then
  echo "${GREEN}-> Configuring bash profile${NC}"
  # TODO FIX THIS!!!!!
  cat <<EOT | sudo tee -a ~/.profile
# Custom config

source ~/chia-blockchain/activate 2>/dev/null || echo "Unable to load venv, chia not installed yet"

alias reboot="sudo systemctl stop chia-farmer.service && shutdown -r now"
alias bash-edit="vim ~/.profile"
alias bash-reload="source ~/.profile"
alias chia-logs="tail -f /home/chia/.chia/mainnet/log/debug.log"
alias chia-logs-wallet="tail -f /home/chia/.chia/mainnet/log/debug.log | grep --color=never 'wallet'"
alias chia-logs-blockchain="tail -f /home/chia/.chia/mainnet/log/debug.log | grep --color=never 'Added blocks'"
alias chia-add-nodes="curl https://chia.keva.app/ | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do timeout 5s chia show -a \$line:8444 ;done"
alias chia--backup="sudo /home/chia/scripts/backup.sh"
alias chia--restore="sudo /home/chia/scripts/restore.sh"
alias temp-cpu="vcgencmd measure_temp"
EOT
fi

if [[ ! -d ~/chia ]]; then
  echo "${GREEN}-> Cloning repo${NC}"
  git clone https://github.com/santiagotoledo91/chia-raspberry-farmer-machine.git chia
fi

# TODO improve so it checks if all the packages are installed
if ! grep -q "docker.io"; then
  echo "${GREEN}--> Installing needed packages${NC}"

  sudo apt update
  #sudo apt upgrade -y
  sudo apt install -y net-tools nmap smartmontools docker.io
  sudo apt autoclean
  sudo apt autoremove
fi

if ! grep -q "Port ${SSH_PORT}" /etc/ssh/sshd_config; then
  echo "${GREEN}-> Configuring SSH${NC}"
  sudo ufw allow ssh
  sudo sed -i "s/#Port 22/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
  sudo systemctl reload sshd
fi

if ! test -f "/etc/modprobe.d/disable-uas.conf"; then
  echo "${GREEN}-> Disabling UAS for Seagate 8TB drivers (S.M.A.R.T problem)${NC}"
  echo "options usb-storage quirks=0bc2:3343:u" | sudo tee /etc/modprobe.d/disable-uas.conf
  sudo update-initramfs -u
fi

if ! grep -q "# Overclocking" /boot/firmware/config.txt; then
  echo "${GREEN}-> Already overclocked to 2Ghz!${NC}"
else
  echo "${GREEN}-> Overclocking to 2Ghz${NC}"
  echo -e "\n# Overclocking\nover_voltage=6\narm_freq=2000" | sudo tee -a /boot/firmware/config.txt
fi

if [[ $(find ~/chia/disks -maxdepth 1 -name 'chia-fd-*' | wc -l | xargs ) != "${FARMER_DISKS}" ]]; then
  echo "${GREEN}-> Creating farmer disks mount points${NC}"
  # TODO parametrise to make FARMER_DISKS actually usable
  mkdir -p ~/chia/disks/chia-fd-1
  mkdir -p ~/chia/disks/chia-fd-2
  mkdir -p ~/chia/disks/chia-fd-3
  mkdir -p ~/chia/disks/chia-fd-4
  mkdir -p ~/chia/disks/chia-fd-5
  mkdir -p ~/chia/disks/chia-fd-6

  sudo chmod -R 755 ~/chia/disks
fi

if ! grep "# Chia farmer disks" /etc/fstab; then
  echo "${GREEN}-> Configuring automount, adding the entries to the /etc/fstab${NC}"
  cat <<EOT | sudo tee -a /etc/fstab
# Chia farmer disks
LABEL=chia-fd-1    /home/ubuntu/chia/disks/chia-fd-1    ext4    defaults,nofail    0    2
LABEL=chia-fd-2    /home/ubuntu/chia/disks/chia-fd-2    ext4    defaults,nofail    0    2
LABEL=chia-fd-3    /home/ubuntu/chia/disks/chia-fd-3    ext4    defaults,nofail    0    2
LABEL=chia-fd-4    /home/ubuntu/chia/disks/chia-fd-4    ext4    defaults,nofail    0    2
LABEL=chia-fd-5    /home/ubuntu/chia/disks/chia-fd-5    ext4    defaults,nofail    0    2
LABEL=chia-fd-6    /home/ubuntu/chia/disks/chia-fd-6    ext4    defaults,nofail    0    2
EOT
fi

echo "${GREEN}Stage 1 finished!${NC}"
read -n 1 -s -r -p "${RED}-> Press any key to shutdown...${NC}"
sudo shutdown now
