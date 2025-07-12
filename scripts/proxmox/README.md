# Proxmox Scripts

Scripts for managing Proxmox virtual environments and VMs.

## Scripts

- **`proxmox-update-reboot.sh`** - Updates Proxmox host packages and reboots if needed
- **`proxmox-auto-resize.sh`** - Automatically resizes VM disks in Proxmox
- **`update-vms-with-guest-agent.sh`** - Updates all VMs that have QEMU guest agent installed
- **`setup-cloud-image.sh`** - Sets up Ubuntu cloud images for VM templates

## Usage

### Setup Cloud Image Template
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/proxmox/setup-cloud-image.sh)"
```

### Update VMs with Guest Agent
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/proxmox/update-vms-with-guest-agent.sh)"
```

### Automated VM Updates (Cron)
Exclude specific VMs (e.g., 103, 111):
```
0 0 * * 0 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/proxmox/update-vms-with-guest-agent.sh)" -s 103 111 >>/var/log/update-vms-cron.log 2>/dev/null
```

## Resources

- Ubuntu Cloud Images: https://cloud-images.ubuntu.com/noble/current/
