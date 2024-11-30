
# Prompt for the disk image file path
read -p "Enter the path to your disk image file: " image_path

# Check if the file exists
if [ ! -f "$image_path" ]; then
    echo "Error: File '$image_path' does not exist."
    exit 1
fi

# Verify the file is readable
if [ ! -r "$image_path" ]; then
    echo "Error: Cannot read file '$image_path'. Check permissions."
    exit 1
fi

qm create 8000 --memory 2048 --core 2 --name ubuntu-cloud-test --net0 virtio,bridge=vmbr0
qm disk import 8000 "$image_path" local-lvm
qm set 8000 --scsihw virtio-scsi-pci --scsi0 local:vm-8000-disk-0
qm set 8000 --ide2 local-lvm:cloudinit
qm set 8000 --boot c --bootdisk scsi0
qm set 8000 --serial0 socket --vga serial0