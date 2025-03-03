#!/usr/bin/env bash
#
# k3s-maintenance.sh
#
# Description:
#   Perform routine cleanup and maintenance tasks on a K3s cluster. 
#   - Remove completed or failed pods
#   - Force delete pods stuck in "Terminating" or "Unknown" states
#   - Prune unused container images
#   - (Optional) Prune old etcd snapshots if using internal etcd
#
# Usage:
#   1. Make the script executable:
#        chmod +x k3s-maintenance.sh
#   2. (Optional) Schedule it via cron:
#        sudo crontab -e
#        0 3 * * * /path/to/k3s-maintenance.sh >> /var/log/k3s-maintenance.log 2>&1
#
# Best Practices:
#   1. Always test changes in a non-production environment.
#   2. Keep the script idempotent and safe to run repeatedly.
#   3. Use environment variables or flags to tune behavior (e.g., retention times).
#   4. Maintain logs of cleaned resources for audit/debugging purposes.
#

# sudo crontab -e
# Run daily at 3 AM
# 0 3 * * * /usr/local/bin/k3s-maintenance.sh >> /var/log/k3s-maintenance.log 2>&1

set -euo pipefail

# ----------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------

# If you prefer to use "k3s kubectl" directly without aliasing, keep this as is.
KUBECTL="k3s kubectl"
# Retention period (in days) for etcd snapshots if using internal etcd.
ETCD_SNAPSHOT_RETENTION_DAYS="${ETCD_SNAPSHOT_RETENTION_DAYS:-7}"

# ----------------------------------------------------------------------
# Helper Functions
# ----------------------------------------------------------------------

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# ----------------------------------------------------------------------
# 1. Cleanup Completed or Failed Pods
# ----------------------------------------------------------------------
#
# Pods in "Completed" or "Error"/"CrashLoopBackOff" state can be removed
# if they are no longer needed. Adjust states to your needs.

cleanup_finished_pods() {
  log "Cleaning up completed or failed pods..."
  # Completed pods
  completed_pods=$($KUBECTL get pods --all-namespaces \
    --field-selector=status.phase==Succeeded \
    -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace \
    --no-headers || true)

  # Failed pods
  failed_pods=$($KUBECTL get pods --all-namespaces \
    --field-selector=status.phase==Failed \
    -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace \
    --no-headers || true)

  while read -r line; do
    [[ -z "$line" ]] && continue
    pod_name=$(echo "$line" | awk '{print $1}')
    pod_ns=$(echo "$line" | awk '{print $2}')
    log "Deleting completed pod: $pod_name in namespace: $pod_ns"
    $KUBECTL delete pod "$pod_name" -n "$pod_ns" || true
  done <<< "$completed_pods"

  while read -r line; do
    [[ -z "$line" ]] && continue
    pod_name=$(echo "$line" | awk '{print $1}')
    pod_ns=$(echo "$line" | awk '{print $2}')
    log "Deleting failed pod: $pod_name in namespace: $pod_ns"
    $KUBECTL delete pod "$pod_name" -n "$pod_ns" || true
  done <<< "$failed_pods"
}

# ----------------------------------------------------------------------
# 2. Force Delete Stuck Pods
# ----------------------------------------------------------------------
#
# Sometimes pods remain in a "Terminating" or "Unknown" state if there
# were issues during deletion or node disruptions. We can force-delete
# them if they are definitely safe to remove.

force_delete_stuck_pods() {
  log "Force deleting pods stuck in 'Terminating' or 'Unknown' state..."
  # Adjust the grep expression to handle additional states you consider "stuck"
  stuck_pods=$($KUBECTL get pods --all-namespaces \
    --no-headers | grep -E 'Terminating|Unknown' || true)

  while read -r line; do
    [[ -z "$line" ]] && continue
    pod_ns=$(echo "$line" | awk '{print $1}')
    pod_name=$(echo "$line" | awk '{print $2}')
    log "Force deleting stuck pod: $pod_name in namespace: $pod_ns"
    $KUBECTL delete pod "$pod_name" -n "$pod_ns" --grace-period=0 --force || true
  done <<< "$stuck_pods"
}

# ----------------------------------------------------------------------
# 3. Prune Unused Container Images
# ----------------------------------------------------------------------
#
# If you installed K3s with containerd (default), you can prune images using "crictl".
# For Docker-based K3s, you could use "docker system prune -f". 
# Example uses crictl (default for K3s).
# 
# WARNING: This will remove all unused images which could cause extra pulls 
# if they are needed again. Tweak as necessary.

prune_unused_images() {
  if command -v crictl &> /dev/null; then
    log "Pruning unused container images with crictl..."
    crictl image prune || true
  else
    log "crictl not found. Skipping image prune."
  fi
}

# ----------------------------------------------------------------------
# 4. (Optional) Prune Old Etcd Snapshots
# ----------------------------------------------------------------------
#
# If K3s is configured with the embedded etcd datastore, you can use the built-in
# snapshot functionality. By default, K3s keeps snapshots in /var/lib/rancher/k3s/server/db/snapshots.
# This step removes snapshots older than the configured retention period.

prune_old_etcd_snapshots() {
  # Detect if etcd is actually in use (k3s check).
  # We assume if there's a /var/lib/rancher/k3s/server/db/snapshots directory, etcd snapshots may be present.
  snapshot_dir="/var/lib/rancher/k3s/server/db/snapshots"
  if [[ -d "$snapshot_dir" ]]; then
    log "Pruning etcd snapshots older than $ETCD_SNAPSHOT_RETENTION_DAYS days..."
    find "$snapshot_dir" -type f -name '*.db' -mtime +$ETCD_SNAPSHOT_RETENTION_DAYS -exec rm -v {} \;
  else
    log "Etcd snapshot directory not found or etcd not in use. Skipping prune."
  fi
}

# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------

cleanup_finished_pods
force_delete_stuck_pods
prune_unused_images
prune_old_etcd_snapshots

log "K3s maintenance completed!"
exit 0
