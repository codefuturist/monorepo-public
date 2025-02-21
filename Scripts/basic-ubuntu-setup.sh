#!/usr/bin/env bash

apt update
apt install qemu-guest-agent nfs-common lvm2 spice-vdagent -y
timedatectl set-timezone Europe/Zurich
ufw disable
reboot
