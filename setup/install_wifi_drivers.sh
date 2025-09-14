#!/bin/bash

set -e

echo "Installing b43-fwcutter..."
sudo dpkg -i ./b43-fwcutter_019-3_amd64.deb

echo "Installing firmware-b43-installer..."
sudo dpkg -i ./firmware-b43-installer_019-3_all.deb || echo "Skipping firmware download (offline install assumed)"

echo "Extracting Broadcom firmware tarball..."
mkdir -p ~/b43-firmware
tar -xjf ./broadcom-wl-5.100.138.tar.bz2 -C ~/b43-firmware

echo "Extracting firmware with b43-fwcutter..."
sudo b43-fwcutter -w /lib/firmware ~/b43-firmware/broadcom-wl-5.100.138/linux/wl_apsta.o

echo "Unloading any conflicting modules..."
sudo modprobe -r b43 ssb wl brcmsmac bcma || echo "Some modules not loaded, skipping..."

echo "Loading b43 driver..."
sudo modprobe b43

echo "Blacklisting conflicting Broadcom modules..."
echo -e "blacklist bcma\nblacklist brcmsmac\nblacklist wl" | sudo tee /etc/modprobe.d/blacklist-broadcom.conf > /dev/null

echo "Ensuring b43 loads on boot..."
echo b43 | sudo tee -a /etc/modules > /dev/null
sudo update-initramfs -u

echo "Done. Rebooting to apply changes..."
sleep 2
sudo reboot
