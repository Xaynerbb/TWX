#!/bin/bash

echo "Check disk usage in Linux systems"

disk_size=$(df -h | grep /dev/sda2 | awk '{print $5}' | cut -d'%' -f1)

if [ -z "$disk_size" ]; then
    echo "Could not find /dev/sda2. Check the correct partition with: df -h"
    exit 1
fi

echo "$disk_size% of disk filled"

if [ "$disk_size" -gt 80 ]; then
    echo "Disk is utilized more than 80% — expand disk or delete files soon"
else
    echo "Enough disk is available"
fi
