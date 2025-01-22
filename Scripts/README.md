 

### add ansible user
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/add-ansible-user.sh)"
```
### setup cloud image
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/setup-cloud-image.sh)"
```
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
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/add-ansible-user.sh)"
```
