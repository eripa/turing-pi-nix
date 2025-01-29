#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: flash-script <NODE_NUMBER> <IP_ADDRESS>"
  exit 1
fi

NODE=$1
IP=$2

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
tpi flash -n "$NODE" --host "$IP" --user root -i "./$UNCOMPRESSED_IMG"

echo "Done! The Raspberry Pi image has been flashed."
