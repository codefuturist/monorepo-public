# K3s/Kubernetes Scripts

Scripts for managing K3s clusters and Kubernetes deployments.

## Scripts

- **`create-k3s-config.sh`** - Generates K3s configuration files
- **`k3s-cleanup.sh`** - Cleans up K3s container images and cache
- **`k3s-cleanup-2.sh`** - Alternative cleanup script for K3s
- **`restart-k3s-deployments.sh`** - Restarts K3s deployments to fix common issues
- **`k3s-compact-etcd.sh`** - Compacts etcd database to reclaim space

## Usage

### Setup K3s Config
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/k3s/create-k3s-config.sh)"
```

### Install K3s with Config
```shell
curl -sfL https://get.k3s.io | sh -s - --config /etc/rancher/k3s/config.yaml
```

### Restart Deployments
```shell
bash -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/k3s/restart-k3s-deployments.sh)"
```
