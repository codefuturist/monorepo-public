### Git Auto Sync Install
```shell
zsh -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/git-auto-sync-install.sh)"
```
```shell
zsh -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/git-auto-sync-install-download.sh)"
```
```shell
zsh -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/git-auto-pull.sh)"
```

### add ansible user
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/add-ansible-user.sh)"
```

### replace ansible ssh trusted keys
```shell
bash -c '$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/replace-ansible-ssh-trusted-keys.sh)'
```

### setup cloud image
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/setup-cloud-image.sh)"
```
https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

images here: https://cloud-images.ubuntu.com/noble/current/

### update vms
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/update-vms-with-guest-agent.sh)"
```
exclude vms
0 0 * * 0 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/update-vms-with-guest-agent.sh)" -s 103 111 >>/var/log/update-vms-cron.log 2>/dev/null

### setup k3s config
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/create-k3s-config.sh)"
```
```shell
curl -sfL https://get.k3s.io | sh -s - --config /etc/rancher/k3s/config.yaml
```
### add deployment fixer
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/restart-k3s-deployments.sh)"
```

### ubuntu basic setup
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/basic-ubuntu-setup.sh)"
```
