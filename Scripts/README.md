 

### add ansible user
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/add-ansible-user.sh)"
```
### setup cloud image
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/setup-cloud-image.sh)"
```

### setup k3s config
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/Scripts/create-k3s-config.sh)"
```
```shell
curl -sfL https://get.k3s.io | sh -s - --config /etc/rancher/k3s/config.yaml
```
