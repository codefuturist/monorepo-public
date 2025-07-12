# Scripts Directory

This directory contains various system administration and automation scripts organized by category.

## Directory Structure

- **`ansible/`** - Ansible automation and user management scripts
- **`git/`** - Git synchronization and automation scripts  
- **`k3s/`** - Kubernetes/K3s cluster management scripts
- **`proxmox/`** - Proxmox virtualization platform scripts
- **`system-setup/`** - Initial system setup and configuration scripts
- **`maintenance/`** - General system maintenance scripts
- **`truenas/`** - TrueNAS storage system scripts
- **`archive/`** - Archived scripts (deprecated or broken versions)

## Quick Reference

### Git Auto Sync
```shell
zsh -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/git/git-auto-sync-download.sh)"
```
```shell
zsh -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/git/git-auto-pull.sh)"
```
```shell
zsh -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/git/git-auto-sync2.sh)"
```

### Ansible User Management
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/ansible/add-ansible-user.sh)"
```

### Replace Ansible SSH Keys
```shell
bash -c '$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/ansible/replace-ansible-ssh-trusted-keys.sh)'
```

### Proxmox Cloud Image Setup
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/proxmox/setup-cloud-image.sh)"
```
Ubuntu cloud images: https://cloud-images.ubuntu.com/noble/current/

### Update Proxmox VMs
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/proxmox/update-vms-with-guest-agent.sh)"
```
Cron example (exclude VMs 103, 111):
```
0 0 * * 0 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/proxmox/update-vms-with-guest-agent.sh)" -s 103 111 >>/var/log/update-vms-cron.log 2>/dev/null
```

### Proxmox Host Maintenance
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/proxmox/proxmox-update-reboot.sh)"
```
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/proxmox/proxmox-auto-resize.sh)"
```

### K3s Setup
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/k3s/create-k3s-config.sh)"
```
```shell
curl -sfL https://get.k3s.io | sh -s - --config /etc/rancher/k3s/config.yaml
```

### K3s Deployment Restart
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/k3s/restart-k3s-deployments.sh)"
```

### K3s Maintenance
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/k3s/k3s-cleanup.sh)"
```
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/k3s/k3s-compact-etcd.sh)"
```

### Ubuntu Basic Setup
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/system-setup/basic-ubuntu-setup.sh)"
```

### SSH Configuration Management
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/system-setup/ssh-config-manager.sh)"
```

### System Setup & Configuration
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/system-setup/install-docker.sh)"
```
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/system-setup/setup-disk.sh)"
```

### System Maintenance
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/maintenance/update-reboot.sh)"
```

### TrueNAS Management
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/truenas/update-trunas.sh)"
```
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/truenas/upgrade-truenas-apps.sh)"
```
