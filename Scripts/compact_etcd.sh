#!/usr/bin/env bash
# Ensure PATH is set (cron has a minimal environment)
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Fetch the revision number from etcd
rev=$(ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' \
      ETCDCTL_CACERT='/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt' \
      ETCDCTL_CERT='/var/lib/rancher/k3s/server/tls/etcd/server-client.crt' \
      ETCDCTL_KEY='/var/lib/rancher/k3s/server/tls/etcd/server-client.key' \
      ETCDCTL_API=3 etcdctl endpoint status --write-out fields | \
      grep Revision | cut -d: -f2)

# Run the compact command using the fetched revision
ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' \
ETCDCTL_CACERT='/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt' \
ETCDCTL_CERT='/var/lib/rancher/k3s/server/tls/etcd/server-client.crt' \
ETCDCTL_KEY='/var/lib/rancher/k3s/server/tls/etcd/server-client.key' \
ETCDCTL_API=3 etcdctl compact $rev

ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt' ETCDCTL_CERT='/var/lib/rancher/k3s/server/tls/etcd/server-client.crt' ETCDCTL_KEY='/var/lib/rancher/k3s/server/tls/etcd/server-client.key' ETCDCTL_API=3 etcdctl defrag --cluster
