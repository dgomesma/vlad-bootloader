#!/bin/bash
# Creates and formats floppy disk image

THIS_DIR=$(dirname "$0")
source $THIS_DIR/utils.sh

DISK="disk.img"

display_help() {
	echo "Creates a floppy disk image where binaries can be copied into."
	echo
	echo "Usage: $0 disk-name"
	echo
	echo "Options:	"
	echo "--help	Prints this message"
	exit 0
}

check_programs() {
	program_exists fdisk true
	program_exists dd true
	program_exists mkfs.vfat true
}

assert_nargs $# 1

while [[ "$#" -gt 0 ]]; do
  DISK_NAME=$1
  case $1 in
    --help) display_help ;;
  esac
  shift
done

dd if=/dev/zero of=${DISK} bs=1048576 count=128
fdisk ${DISK} <<EOF
o
n



+8M

t
1
w
EOF
mkfs.vfat -F 16 ${DISK}
