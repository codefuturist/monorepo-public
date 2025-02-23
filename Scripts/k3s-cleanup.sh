#!/usr/bin/env bash

ctr -n k8s.io images prune --all

crictl rmi --prune
