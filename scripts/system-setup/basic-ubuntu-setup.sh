#!/usr/bin/env bash

apt update
# apt install qemu-guest-agent nfs-common lvm2 spice-vdagent linux-modules-extra-$(uname -r) -y
apt install qemu-guest-agent nfs-common lvm2 linux-modules-extra-$(uname -r) -y
timedatectl set-timezone Europe/Zurich
ufw disable
reboot
