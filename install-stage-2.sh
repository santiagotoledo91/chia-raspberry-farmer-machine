#!/usr/bin/env bash

GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

if [[ $(whoami) != "chia" ]]; then
  echo "${RED}You need to run this as 'chia'!${NC}"
  exit 1
fi

echo "${GREEN}-> Executing Stage 2${NC}"

if sudo test -f /etc/systemd/system/chia-farmer.service; then
  echo "${GREEN}-> chia-farmer.service already created!${NC}"
else
  echo "${GREEN}-> Creating the chia-farmer.service${NC}"
  cat <<EOT | sudo tee /etc/systemd/system/chia-farmer.service
[Unit]
  Description=Chia farmer
  Wants=network-online.target
  After=network.target network-online.target
  StartLimitIntervalSec=0

  [Service]
  Type=forking
  Restart=always
  RestartSec=1
  User=chia

  Environment=PATH=/home/chia/chia-blockchain/venv/bin:\${PATH}
  ExecStart=/usr/bin/env chia start farmer
  ExecStop=/usr/bin/env chia stop all -d
  TimeoutStopSec=300

  [Install]
  WantedBy=multi-user.target
EOT
fi

if [[ $(sudo grep "# Chia farmer disks" /etc/fstab) != "" ]]; then
  echo "${GREEN}-> Farmer disks automount already configured!${NC}"
else
  echo "${GREEN}-> Configuring automount, adding the entries to the /etc/fstab${NC}"
  cat <<EOT | sudo tee -a /etc/fstab
# Chia farmer disks
LABEL=chia-fd-1    /home/chia/farmer-disks/chia-fd-1    ext4    defaults,nofail    0    2
LABEL=chia-fd-2    /home/chia/farmer-disks/chia-fd-2    ext4    defaults,nofail    0    2
LABEL=chia-fd-3    /home/chia/farmer-disks/chia-fd-3    ext4    defaults,nofail    0    2
LABEL=chia-fd-4    /home/chia/farmer-disks/chia-fd-4    ext4    defaults,nofail    0    2
LABEL=chia-fd-5    /home/chia/farmer-disks/chia-fd-5    ext4    defaults,nofail    0    2
LABEL=chia-fd-6    /home/chia/farmer-disks/chia-fd-6    ext4    defaults,nofail    0    2
EOT
fi

if sudo test -f "/etc/modprobe.d/disable-uas.conf"; then
  echo "${GREEN}-> UAS already disabled for Seagate 8TB drives!${NC}"
else
  echo "${GREEN}-> Disabling UAS for Seagate 8TB drivers (S.M.A.R.T problem)${NC}"
  echo "options usb-storage quirks=0bc2:3343:u" | sudo tee /etc/modprobe.d/disable-uas.conf
  echo "${GREEN}--> Rebuilding initrd${NC}"
  sudo update-initramfs -u
fi

echo "${GREEN}-> Installing the basic packages${NC}"

echo "${GREEN}--> Updating packages list${NC}"
sudo apt update

echo "${GREEN}--> Installing new packages${NC}"
sudo apt install -y net-tools nmap nmon speedometer smartmontools

#echo "${GREEN}--> Upgrading packages${NC}"
#apt upgrade -y

echo "${GREEN}--> Cleaning up${NC}"
sudo apt autoclean
sudo apt autoremove

if [[ $(sudo grep "Port 45622" /etc/ssh/sshd_config) != "" ]]; then
  echo "${GREEN}-> SSH already configured!${NC}"
else
  echo "${GREEN}-> Configuring SSH${NC}"

  echo "${GREEN}--> Enabling SSH on the UFW${NC}"
  sudo ufw allow ssh

  echo "${GREEN}--> Changing the default SSH port to 45622${NC}"
  sudo sed -i "s/#Port 22/Port 45622/g" /etc/ssh/sshd_config

  echo "${GREEN}--> Configuring pubkeyauthentication${NC}"
  mkdir /home/chia/.ssh
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+g1dNHXKLZ9Ajp7+Q3C/nGiWdYpXfWE044DY1AXYKtESa9oLNCku6/j9pnfsA2EKgLSHQ7r9r4qkzcWGiG4kG/o4AYfxPSmoHB+ZggEeK+IAUlA04KlBGDsdeja72wP25iT+wT3xPylw7RVWGSRLsPnRUjlAIOjGqZBaHsh2nvKqbrfX0YegHzOE+8wipYhg1421cjTVWror33BAKjvXrHf/Nr47cSIZ8Tq52MGkLri8XB/Y6ga8+Fu/KPxuHpZm/9knlj/5ecAqad9MApsOWp3Lh+dsyBtsy4F8tO9NZiwiMmIGCSVsWQnTizgxeFES2w1KxzDlK5Qd5nkmFxVouJv06qrr+jTmsZAZVpbg/YbsOTGJMwjwliNXFxHCf/Er+dIN0lqv8ie0gT1viHZCjK6+WfWt7AyshmMsdmCcumwGI7lklVz4Xo40RAGe9whLo/EMv18JmK3Ek6g0eX3s6quNgRm6Xo/8WdUgUTtRSc8DS265jOgdb7rHFe/dGGBc= santiagotoledo@Developer---Santiago-T" >> /home/chia/.ssh/authorized_keys

  echo "${GREEN}--> Reloading the SSH service${NC}"
  sudo systemctl reload sshd
fi

if [[ -d /home/chia/farmer-disks ]]; then
  echo "${GREEN}-> Farmer disks directories already created!${NC}"
else
  echo "${GREEN}-> Configuring farmer disks${NC}"

  echo "${GREEN}--> Creating directories${NC}"
  mkdir -p "/home/chia/farmer-disks/chia-fd-1"
  mkdir -p "/home/chia/farmer-disks/chia-fd-2"
  mkdir -p "/home/chia/farmer-disks/chia-fd-3"
  mkdir -p "/home/chia/farmer-disks/chia-fd-4"
  mkdir -p "/home/chia/farmer-disks/chia-fd-5"
  mkdir -p "/home/chia/farmer-disks/chia-fd-6"

  echo "${GREEN}--> Setting permissions to 755${NC}"
  sudo chmod -R 755 "/home/chia/farmer-disks"
fi

if [[ -d /home/chia/chia-blockchain ]]; then
  echo "${GREEN}-> Chia blockchain already installed!${NC}"
else
  echo "${GREEN}-> Installing chia-blockchain${NC}"
  echo "${GREEN}--> Cloning repository${NC}"
  git clone https://github.com/Chia-Network/chia-blockchain.git -b latest --recurse-submodules /home/chia/chia-blockchain

  echo "${GREEN}--> Moving to chia-blockchain directory${NC}"
  cd /home/chia/chia-blockchain || exit 1

  echo "${GREEN}--> Executing install script${NC}"
  sh install.sh

  echo "${GREEN}--> Loading python venv${NC}"
  chia init

  echo "${GREEN}--> Initializing${NC}"
  chia init

  echo "${GREEN}--> Fixing SSL permissions${NC}"
  chia init --fix-ssl-permissions

  echo "${GREEN}--> Add plot directories${NC}"
  chia plots add -d '/home/chia/farmer-disks/chia-fd-1/plots'
  chia plots add -d '/home/chia/farmer-disks/chia-fd-2/plots'
  chia plots add -d '/home/chia/farmer-disks/chia-fd-3/plots'
  chia plots add -d '/home/chia/farmer-disks/chia-fd-4/plots'
  chia plots add -d '/home/chia/farmer-disks/chia-fd-5/plots'
  chia plots add -d '/home/chia/farmer-disks/chia-fd-6/plots'

  echo "${GREEN}--> Setting the log level to INFO${NC}"
  chia configure -log-level INFO

  echo "${GREEN}--> Back to previous directory${NC}"
  cd - || exit 1
fi

if sudo test -d /home/chia/scripts; then
  echo "${GREEN}-> Scripts already configured!${NC}"
else
  echo "${GREEN}-> Configuring scripts${NC}"
  mkdir -p /home/chia/scripts
  echo "${GREEN}--> Downloading scripts${NC}"
  wget https://raw.githubusercontent.com/santiagotoledo91/chia-raspberry-farmer-machine/main/scripts/backup.sh -O /home/chia/scripts/backup.sh
  wget https://raw.githubusercontent.com/santiagotoledo91/chia-raspberry-farmer-machine/main/scripts/restore.sh -O /home/chia/scripts/restore.sh
  echo "${GREEN}--> Making scripts executable${NC}"
  chmod +x /home/chia/scripts/backup.sh
  chmod +x /home/chia/scripts/restore.sh
fi

echo "${GREEN}Stage 2 finished!${NC}"
read -n 1 -s -r -p "${RED}-> Press any key to shutdown...${NC}"
sudo shutdown now
