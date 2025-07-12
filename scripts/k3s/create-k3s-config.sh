#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root or with sudo. Please re-run with sudo."
  exit 1
fi

# Define the configuration content
CONFIG_CONTENT=$(cat <<EOF
# Enable cluster initialization
# cluster-init: true

server: "https://192.168.2.77:6443"
token: ""
node-name: k3s-hybrid-3

# Set custom data directory
data-dir: "/var/lib/rancher/k3s"

# Disable default components
disable:
  - servicelb
  - local-storage
  - traefik

# Configure service node port range
service-node-port-range: "80-32767"

# Configure custom TLS SANs for certificates
tls-san:
  - "k3s.pandia.io"
  - "k3s-master-lb.pandia.io"
  - "192.168.2.130"
  - "192.168.2.50"
  - "192.168.2.133"

# Set kubeconfig write permissions
write-kubeconfig-mode: "644"

# Pass arguments to the Kubernetes API server
kube-apiserver-arg:
  - "default-not-ready-toleration-seconds=30"
  - "default-unreachable-toleration-seconds=30"

# Pass arguments to the Kubernetes Controller Manager
kube-controller-arg:
  - "node-monitor-period=20s"
  - "node-monitor-grace-period=20s"
  
node-label:
  - other=what
  
# node-taint+:
#  - charlie=delta:NoSchedule


# Pass arguments to the Kubernetes Kubelet
kubelet-arg:
  - "node-status-update-frequency=5s"
EOF
)

# Create the directory for the config file if it doesn't exist
CONFIG_DIR="/etc/rancher/k3s"
sudo mkdir -p "$CONFIG_DIR"

# Create the configuration file
CONFIG_FILE="$CONFIG_DIR/config.yaml"
echo "$CONFIG_CONTENT" | sudo tee "$CONFIG_FILE" > /dev/null

# Ensure proper permissions
sudo chmod 600 "$CONFIG_FILE"

# Print success message
echo "Configuration file created at $CONFIG_FILE:"
cat "$CONFIG_FILE"
