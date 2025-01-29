#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: flash-script <NODE_NUMBER> <IP_ADDRESS> <USER> <PASSWORD>"
  exit 1
fi

NODE=$1
IP=$2
USER=$3
PASSWORD=$4

echo "Building the Raspberry Pi image..."
nix build .#images.rpi-example

echo "Uncompressing the image..."
IMG_PATH=$(ls result/sd-image/nixos-sd-image-*.img.zst)
if [[ ! -f "$IMG_PATH" ]]; then
  echo "Error: Image file not found. Ensure the build process completed successfully."
  exit 1
fi

UNCOMPRESSED_IMG=rpiImage.img
unzstd -f "$IMG_PATH" -o "$UNCOMPRESSED_IMG"

echo "Checking if the SD card is already mounted on the Turing Pi..."
sshpass -p "$PASSWORD" ssh -T "$USER@$IP" << 'EOF'
if ! mountpoint -q /mnt/sdcard; then
  echo "Mounting the SD card..."
  if [ -b /dev/mmcblk0p1 ]; then
    mount /dev/mmcblk0p1 /mnt/sdcard
  elif [ -b /dev/mmcblk0 ]; then
    mount /dev/mmcblk0 /mnt/sdcard
  else
    echo "Error: SD card device not found."
    exit 1
  fi
else
  echo "SD card is already mounted."
fi
EOF

echo "Copy the image to the SD card..."
sshpass -p "$PASSWORD" scp "./$UNCOMPRESSED_IMG" "$USER@$IP":/mnt/sdcard/

echo "Flashing the image to the Turing Pi node..."
tpi flash -n "$NODE" --host "$IP" --user "$USER" --password "$PASSWORD" -l -i "/mnt/sdcard/$UNCOMPRESSED_IMG"
tpi power -n "$NODE" --host "$IP" --user "$USER" --password "$PASSWORD" on
