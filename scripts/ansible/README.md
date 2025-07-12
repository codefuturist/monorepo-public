# Ansible Scripts

Scripts for managing Ansible automation and user setup.

## Scripts

- **`add-ansible-user.sh`** - Creates and configures an ansible user with sudo privileges and SSH key setup
- **`replace-ansible-ssh-trusted-keys.sh`** - Updates SSH authorized keys for the ansible user

## Usage

### Add Ansible User
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/ansible/add-ansible-user.sh)"
```

### Replace SSH Keys
```shell
bash -c '$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/ansible/replace-ansible-ssh-trusted-keys.sh)'
```
