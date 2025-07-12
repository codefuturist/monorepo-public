#!/usr/bin/env bash

kubectl scale \
  deployment/erpnext-gunicorn \
  deployment/erpnext-nginx \
  deployment/erpnext-scheduler \
  deployment/erpnext-socketio \
  deployment/erpnext-worker-d \
  deployment/erpnext-worker-l \
  deployment/erpnext-worker-s \
  statefulset/erpnext-mariadb \
  --replicas=0 -n experimental

# Scale down all database namespace resources to 0
kubectl scale \
  deployment/mongodb \
  statefulset/mariadb-primary \
  statefulset/postgresql-primary \
  --replicas=0 -n database
  
kubectl scale \
  statefulset/authentik-redis-master \
  --replicas=0 -n access-control
  
# Wait for 60 seconds
sleep 60

kubectl scale \
  statefulset/authentik-redis-master \
  --replicas=1 -n access-control

# Scale up all experimental namespace resources to 1
kubectl scale \
  deployment/erpnext-gunicorn \
  deployment/erpnext-nginx \
  deployment/erpnext-scheduler \
  deployment/erpnext-socketio \
  deployment/erpnext-worker-d \
  deployment/erpnext-worker-l \
  deployment/erpnext-worker-s \
  statefulset/erpnext-mariadb \
  --replicas=1 -n experimental

# Scale up all database namespace resources to 1
kubectl scale \
  deployment/mongodb \
  statefulset/mariadb-primary \
  statefulset/postgresql-primary \
  --replicas=1 -n database
