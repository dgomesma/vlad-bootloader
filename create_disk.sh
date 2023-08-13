#!/bin/bash

DISK_IMG=diskimage.dd

dd if=/dev/zero of=$DISK_IMG bs=1048576 count=128
fdisk $DISK_IMG <<EOF
g
n


+8M

t
1
w
EOF
sudo losetup -o $[2048*512] --sizelimit $[8*1024*1024] -f diskimage.dd
LOOPBACK_DEV=$(losetup -a | awk -F: '/diskimage.dd/ {print $1}')
if [ $? -ne 0 ]; then
  echo "Was not able to run losetup with required sudo privileges" >&2
  exit 1
fi
echo "Bootable device attached to loopback device ${LOOPBACK_DEV}"
## TODO: Possibly unfinished.