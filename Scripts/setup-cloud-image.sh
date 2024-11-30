
# Prompt for the disk image file path
# read -p "Enter the path to your disk image file: " image_path

# Prompt for URL
echo "Please enter the URL to download:"
read url

# Check if URL is provided
if [ -z "$url" ]; then
    echo "Error: No URL provided"
    exit 1
fi


mkdir -p /tmp/cloud-image-script
# Extract filename from URL and append date
FILENAME="downloaded-image.img"
VMID="8001"

# Download using wget with custom filename
echo "Downloading from: $url"
echo "Saving as: /tmp/cloud-image-script/$FILENAME"
wget "$url" -O "/tmp/cloud-image-script/$FILENAME"

# Check if download was successful
if [ $? -eq 0 ]; then
    echo "Download completed successfully in /tmp/cloud-image-script directory"
else
    echo "Download failed"
fi

## Check if the file exists
#if [ ! -f "$image_path" ]; then
#    echo "Error: File '$image_path' does not exist."
#    exit 1
#fi
#
## Verify the file is readable
#if [ ! -r "$image_path" ]; then
#    echo "Error: Cannot read file '$image_path'. Check permissions."
#    exit 1
#fi

qm create "$VMID" --memory 2048 --core 2 --name ubuntu-cloud-test --net0 virtio,bridge=vmbr0
qm disk import "$VMID" "/tmp/cloud-image-script/$FILENAME" local-lvm
qm set "$VMID" --scsihw virtio-scsi-pci --scsi0 local:vm-"$VMID"-disk-0
qm set "$VMID" --ide2 local-lvm:cloudinit
qm set "$VMID" --boot c --bootdisk scsi0
qm set "$VMID" --serial0 socket --vga serial0

rm -r "/tmp/cloud-image-script/"