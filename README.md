# Chia raspberry farmer machine

This guide will help you to set up a Raspberry Pi 4 8GB to run as a Chia farmer

## Prerequisites

### Hardware
- Raspberry Pi 4 8GB
- 120GB SSD connected over USB
#### Software
- Raspberry Pi imager

## OS Install

### Setup Raspberry Pi to boot from USB
- Open **Raspberry pi imager**
- Flash the `USB Boot` image the into the SSD
- Connect the SSD to the Raspberry Pi 
- Turn it on and wait ~20 seconds, it will be automatically setup for you
- Done

### Install Ubuntu Server 21.10
- Open **Raspberry pi imager**
- Flash the `Ubuntu server 21.10` image the into the SSD (older Ubuntu will not work)
- Connect the SSD to the Raspberry Pi
- Turn it on and wait for it to boot
- Press enter and `ubuntu login:` should appear, use "ubuntu" as user and as password
- You will be asked to change the password

### Change the initial password 
If you had to enter a long/strong password and want to change it then run:
```shell
sudo passwd
```

### Execute the install script
#### Stage 1
- Login as `ubuntu`
- Download the script
  ```shell
  curl -L https://bit.ly/chia-fm-s1 -o install-stage-1.sh
  ```
- And run it
  ```shell
  bash install-stage-1.sh
  ```
- It will shut down automatically
- Move the raspberry to it's final destination
- Go to `Stage 2`
#### Stage 2
- Login as `ubuntu`
- Run the script
  ```shell
  bash install-stage-2.sh
  ```
- Go to `Stage 3`
  
#### Stage 3
**Note this stage is not idempotent, so it's intended to be run just once.**
- Login as `chia`
- Run the script
  ```shell
  bash install-stage-3.sh
  ```
- Open the crontab:
  ```shell
  sudo crontab -e
  ```
- Add the backup cron:
  ```shell
  0 7 * * 1 /home/chia/scripts/backup.sh >> /home/chia/logs/backup.log 2>&1
  ```

## Monitoring
### Scrutini (S.M.A.R.T monitor)
- Go to `https://x.x.x.x:8080`
### Network
```shell
speedometer-r eth0 -t eth0
```


