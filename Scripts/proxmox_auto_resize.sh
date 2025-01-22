#!/bin/bash

# Configuration
THRESHOLD=80             # Disk usage percentage threshold to trigger resize.
EXPAND_AMOUNT="+10G"     # Amount to increase disk size when threshold is exceeded.
VM_IDS=(101 102)         # List of QEMU VM IDs to check.
CT_IDS=(201 202)         # List of LXC container IDs to check.

# Function to check and resize QEMU VM disks using QEMU Guest Agent and jq
check_and_resize_vm() {
    local VMID=$1

    # Execute df inside guest using QEMU Guest Agent
    json_output=$(qm guest exec "$VMID" -- df -h /)

    # Check if qm guest exec succeeded
    if [[ $? -ne 0 ]]; then
        echo "Error executing guest command for VM $VMID"
        return
    fi

    # Parse output data containing df result from JSON
    out_data=$(echo "$json_output" | jq -r '.["out-data"]')

    # Extract disk usage percentage from df output.
    # This assumes the second line in df output corresponds to the root filesystem.
    usage=$(echo "$out_data" | awk 'NR==2 {print $5}' | tr -d '%')

    if [[ -z "$usage" ]]; then
        echo "Unable to retrieve disk usage for VM $VMID. Skipping."
        return
    fi

    echo "VM $VMID - Current root disk usage: ${usage}%"

    if (( usage >= THRESHOLD )); then
        echo "Threshold exceeded for VM $VMID. Proceeding with shutdown and resize."

        # Shut down the VM gracefully
        qm shutdown "$VMID"
        echo "Waiting for VM $VMID to shut down..."
        while qm status "$VMID" | grep -q running; do
            sleep 5
        done

        # Resize disk. Adjust 'scsi0' if your disk configuration differs.
        echo "Resizing disk for VM $VMID by $EXPAND_AMOUNT."
        qm resize "$VMID" scsi0 "$EXPAND_AMOUNT"

        # Start the VM again
        qm start "$VMID"
        echo "VM $VMID has been restarted."
    fi
}

# Function to check and resize LXC container disks
check_and_resize_lxc() {
    local CTID=$1

    # Query root filesystem usage inside the container
    usage=$(pct exec "$CTID" -- df -h / | awk 'NR==2 {print $5}' | tr -d '%')

    if [[ -z "$usage" ]]; then
        echo "Unable to retrieve disk usage for LXC $CTID. Skipping."
        return
    fi

    echo "LXC $CTID - Current root disk usage: ${usage}%"

    if (( usage >= THRESHOLD )); then
        echo "Threshold exceeded for LXC $CTID. Proceeding with shutdown and resize."

        # Stop the container
        pct stop "$CTID"
        echo "Waiting for LXC $CTID to stop..."
        while pct status "$CTID" | grep -q "status: running"; do
            sleep 5
        done

        # Resize disk for container root filesystem
        echo "Resizing disk for LXC $CTID by $EXPAND_AMOUNT."
        pct resize "$CTID" rootfs "$EXPAND_AMOUNT"

        # Start the container again
        pct start "$CTID"
        echo "LXC $CTID has been restarted."
    fi
}

# Process each QEMU VM
for vmid in "${VM_IDS[@]}"; do
    check_and_resize_vm "$vmid"
done

# Process each LXC container
for ctid in "${CT_IDS[@]}"; do
    check_and_resize_lxc "$ctid"
done
