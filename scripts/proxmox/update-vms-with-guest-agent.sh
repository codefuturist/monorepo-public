#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

echo -e "\n $(date)"
excluded_containers=("$@")
function update_container() {
  container=$1
  name=$(qm guest exec --timeout 600 "$container" hostname)
  echo -e "\n [Info] Updating $container : $name \n"
  os=$(qm config "$container" | awk '/^description:/ {print $0}' | grep -o 'ostype-.*' | cut -d'-' -f2)
  case "$os" in
  alpine) qm guest exec --timeout 600 "$container" -- ash -c "apk update && apk upgrade" ;;
  archlinux) qm guest exec --timeout 600 "$container" -- bash -c "pacman -Syyu --noconfirm" ;;
  fedora | rocky | centos | alma) qm guest exec --timeout 600 "$container" -- bash -c "dnf -y update && dnf -y upgrade" ;;
  # ubuntu | debian | devuan) qm guest exec --timeout 600 "$container" -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confold" dist-upgrade -y; rm -rf /usr/lib/python3.*/EXTERNALLY-MANAGED" ;;
  ubuntu | debian | devuan) qm guest exec --timeout 600 "$container" -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confold" dist-upgrade -y" ;;
  opensuse) qm guest exec --timeout 600 "$container" -- bash -c "zypper ref && zypper --non-interactive dup" ;;
  esac
}

for container in $(qm list | awk '{if(NR>1) print $1}'); do
  excluded=false
  for excluded_container in "${excluded_containers[@]}"; do
    if [ "$container" == "$excluded_container" ]; then
      excluded=true
      break
    fi
  done
  if [ "$excluded" == true ]; then
    echo -e "[Info] Skipping $container"
    sleep 1
  else
    status=$(qm status $container)
    template=$(qm config $container | grep -q "template:" && echo "true" || echo "false")
    if [ "$template" == "false" ] && [ "$status" == "status: stopped" ]; then
      echo -e "[Info] Starting $container"
      qm start $container
      sleep 60
      update_container $container
      echo -e "[Info] Shutting down $container"
      qm shutdown $container &
    elif [ "$status" == "status: running" ]; then
      update_container $container
    fi
  fi
done
wait
