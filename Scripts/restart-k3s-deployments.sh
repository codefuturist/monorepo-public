#!/usr/bin/env bash

kubectl scale deployment/erpnext-gunicorn   --replicas=0 -n experimental
kubectl scale deployment/erpnext-nginx      --replicas=0 -n experimental
kubectl scale deployment/erpnext-scheduler  --replicas=0 -n experimental
kubectl scale deployment/erpnext-socketio   --replicas=0 -n experimental
kubectl scale deployment/erpnext-worker-d   --replicas=0 -n experimental
kubectl scale deployment/erpnext-worker-l   --replicas=0 -n experimental
kubectl scale deployment/erpnext-worker-s   --replicas=0 -n experimental

kubectl scale statefulset/erpnext-mariadb --replicas=0 -n experimental
kubectl scale deployment/mongodb --replicas=0 -n database
kubectl scale statefulset/mariadb-primary --replicas=0 -n database
kubectl scale statefulset/postgresql-primary --replicas=0 -n database

sleep 120

kubectl scale deployment/erpnext-gunicorn   --replicas=1 -n experimental
kubectl scale deployment/erpnext-nginx      --replicas=1 -n experimental
kubectl scale deployment/erpnext-scheduler  --replicas=1 -n experimental
kubectl scale deployment/erpnext-socketio   --replicas=1 -n experimental
kubectl scale deployment/erpnext-worker-d   --replicas=1 -n experimental
kubectl scale deployment/erpnext-worker-l   --replicas=1 -n experimental
kubectl scale deployment/erpnext-worker-s   --replicas=1 -n experimental

kubectl scale statefulset/erpnext-mariadb --replicas=1 -n experimental
kubectl scale deployment/mongodb --replicas=1 -n database
kubectl scale statefulset/mariadb-primary --replicas=1 -n database
kubectl scale statefulset/postgresql-primary --replicas=1 -n database
