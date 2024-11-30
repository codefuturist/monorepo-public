
rm -rf /tmp/cloud-image-script/

# Exit immediately if a command exits with a non-zero status
set -e

# Trap to clean up temporary files
trap 'rm -rf "/tmp/cloud-image-script/"' EXIT

# Check for required tools
# for cmd in wget qm pvesh; do
#    command -v $cmd >/dev/null 2>&1 || { echo >&2 "Error: $cmd is not installed."; exit 1; }
# done

# Prompt for the URL
read -p "Please enter the URL to download: " url

# Validate URL
if [[ -z "$url" || ! "$url" =~ ^https?:// ]]; then
    echo "Error: Invalid or no URL provided."
    exit 1
fi

# Create temporary directory
TMP_DIR="/tmp/cloud-image-script"
mkdir -p "$TMP_DIR"

# Extract filename from URL
FILENAME=$(basename "$url")
FILEPATH="$TMP_DIR/$FILENAME"

# Get next available VMID
VMID=$(pvesh get /cluster/nextid)

# Prompt for VM Name
read -p "Enter the VM name [default: cloudinit-$VMID]: " VMNAME
VMNAME=${VMNAME:-"ubuntu-cloud-$VMID"}

# VM configuration
MEMORY=2048
CORES=2
STORAGE_POOL="local-lvm"

# Download the image
echo "Downloading from: $url"
echo "Saving as: $FILEPATH"
if ! wget "$url" -O "$FILEPATH"; then
    echo "Error: Download failed."
    exit 1
fi
echo "Download completed successfully."

# Create the VM
echo "Creating VM with ID $VMID and name $VMNAME..."
qm create "$VMID" --memory "$MEMORY" --cores "$CORES" --name "$VMNAME" --net0 virtio,bridge=vmbr0

# Import the disk
echo "Importing disk..."
qm importdisk "$VMID" "$FILEPATH" "$STORAGE_POOL"

# Configure the VM
echo "Configuring VM..."
qm set "$VMID" --scsihw virtio-scsi-pci --scsi0 "$STORAGE_POOL:vm-$VMID-disk-0"
qm set "$VMID" --ide2 "$STORAGE_POOL:cloudinit"
qm set "$VMID" --boot c --bootdisk scsi0
qm set "$VMID" --serial0 socket --vga serial0

echo "VM $VMID created and configured successfully."