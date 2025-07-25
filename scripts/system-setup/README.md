# System Setup Scripts

Scripts for initial system configuration and software installation.

## Scripts

- **`basic-ubuntu-setup.sh`** - Performs basic Ubuntu server setup and hardening
- **`install-docker.sh`** - Installs Docker and Docker Compose
- **`setup-disk.sh`** - Sets up and formats additional disks
- **`ssh-config-manager.sh`** - Comprehensive SSH configuration and security hardening tool

## Usage

### Basic Ubuntu Setup
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/system-setup/basic-ubuntu-setup.sh)"
```

### Install Docker
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/system-setup/install-docker.sh)"
```

### SSH Configuration Manager (Advanced)
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/system-setup/ssh-config-manager.sh)"
```

**SSH Config Manager Features:**
- Enable/disable password authentication
- Configure root login settings
- Change SSH port
- Apply security hardening presets
- Validate configuration changes
- Create automatic backups

**Common Usage Examples:**
```shell
sudo ./ssh-config-manager.sh

sudo ./ssh-config-manager.sh --enable-password -y -r

sudo ./ssh-config-manager.sh --hardening-preset -y

sudo ./ssh-config-manager.sh --change-port 2222 --disable-root -r

sudo ./ssh-config-manager.sh --show-current
```
