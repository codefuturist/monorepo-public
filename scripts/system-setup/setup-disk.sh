#!/usr/bin/env bash

# Usage: sudo ./setup_disk.sh /dev/sdX /mount/point

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <disk_device> <mount_point>"
    exit 1
fi

DISK="$1"
MOUNT_POINT="$2"

echo "WARNING: This script will destroy all data on ${DISK}. Proceeding..."
read -p "Are you sure you want to continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Aborting."
    exit 1
fi

# Create a new GPT partition table
echo "Creating GPT partition table on ${DISK}..."
parted -s "$DISK" mklabel gpt

# Create a new primary partition that spans the entire disk
echo "Creating a primary partition..."
parted -s -a optimal "$DISK" mkpart primary ext4 0% 100%

# Allow time for the system to register the new partition
sleep 2

# Identify the new partition
# For most disks (e.g. /dev/sdb), the partition will be /dev/sdb1.
# For NVMe drives, it might be /dev/nvme0n1p1.
PARTITION=$(ls ${DISK}* 2>/dev/null | grep -E "^${DISK}[0-9]+" | head -n 1)
if [ -z "$PARTITION" ]; then
    echo "Error: Unable to determine the partition name for ${DISK}."
    exit 1
fi

echo "New partition created: ${PARTITION}"

# Format the partition with ext4 filesystem
echo "Formatting ${PARTITION} with ext4..."
mkfs.ext4 "$PARTITION"

# Create the mount point directory if it does not exist
echo "Creating mount point directory ${MOUNT_POINT}..."
mkdir -p "$MOUNT_POINT"

# Mount the new partition
echo "Mounting ${PARTITION} to ${MOUNT_POINT}..."
mount "$PARTITION" "$MOUNT_POINT"

# Retrieve the UUID of the new partition
UUID=$(blkid -s UUID -o value "$PARTITION")
if [ -z "$UUID" ]; then
    echo "Error: Could not retrieve UUID for ${PARTITION}."
    exit 1
fi

# Backup the current /etc/fstab
echo "Backing up /etc/fstab to /etc/fstab.bak..."
cp /etc/fstab /etc/fstab.bak

# Add an entry to /etc/fstab to mount the partition automatically on boot
echo "Adding entry to /etc/fstab..."
echo "UUID=${UUID}  ${MOUNT_POINT}  ext4  defaults  0  2" >> /etc/fstab

echo "Disk setup complete. ${PARTITION} is formatted with ext4 and mounted on ${MOUNT_POINT}."
