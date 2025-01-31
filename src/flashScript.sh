#!/usr/bin/env nix-shell
#!nix-shell -i bash -p tpi sshpass

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: flash-script <NODE_NUMBER|NODE_RANGE|NODE_LIST> <IP_ADDRESS> <USER> <PASSWORD>"
  exit 1
fi

NODE_INPUT=$1
IP=$2
USER=$3
PASSWORD=$4

# Function to parse node input
parse_nodes() {
  local input="$1"
  local nodes=()

  if [[ $input =~ ^[1-4]$ ]]; then
    # Single number
    nodes=($input)

  elif [[ $input =~ ^([1-4])-([1-4])$ ]]; then
    # Range input
    IFS='-' read -r start end <<< "$input"
    if (( start > end )); then
      echo "Invalid range: start cannot be greater than end" >&2
      exit 1
    fi
    for ((i = start; i <= end; i++)); do
      nodes+=($i)
    done

  elif [[ $input =~ ^([1-4])(,[1-4])*$ ]]; then
    # Comma-separated list
    IFS=',' read -r -a nodes <<< "$input"

    # Check for duplicates in comma-separated lists
    declare -A unique_nodes
    for node in "${nodes[@]}"; do
      if [[ -n "${unique_nodes[$node]:-}" ]]; then
        echo "Duplicates are not allowed in comma-separated lists." >&2
        exit 1
      fi
      unique_nodes[$node]=1
    done

  else
    echo "Invalid node input format. Only values 1, 2, 3, and 4 are acceptable." >&2
    exit 1
  fi
}

# Parse nodes
echo "Parse nodes..."
NODES=$(parse_nodes "$NODE_INPUT")

echo "Building the Raspberry Pi image..."
nix build .#rpi-sd-image

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

for NODE in $NODES; do
  echo "Flashing node $NODE..."

  echo "Flashing the image to the Turing Pi node $NODE..."
  tpi flash -n "$NODE" --host "$IP" --user "$USER" --password "$PASSWORD" -l -i "/mnt/sdcard/$UNCOMPRESSED_IMG"
  tpi power -n "$NODE" --host "$IP" --user "$USER" --password "$PASSWORD" on
done