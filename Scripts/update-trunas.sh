#!/usr/bin/env bash

cli -c "system update check_available"
cli -c "system update update"
cli -c "system update download"
cli -c "system update update"
cli -c "system reboot"
