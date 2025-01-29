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

echo "Reboot the BMC chip..."
tpi reboot --host "$IP" --user "$USER" --password "$PASSWORD"
sleep 10

echo "Building the Raspberry Pi image..."
nix build .#images.rpi-example

echo "Uncompressing the image..."
IMG_PATH=$(ls result/sd-image/nixos-sd-image-*.img.zst)
if [[ ! -f "$IMG_PATH" ]]; then
  echo "Error: Image file not found. Ensure the build process completed successfully."
  exit 1
fi

UNCOMPRESSED_IMG=rpiImage.img
unzstd "$IMG_PATH" -o "$UNCOMPRESSED_IMG"

echo "Flashing the image to the Turing Pi node..."
tpi flash -n "$NODE" --host "$IP" --user "$USER" --password "$PASSWORD" -i "./$UNCOMPRESSED_IMG"
tpi power -n "$NODE" --host "$IP" --user "$USER" --password "$PASSWORD" on
