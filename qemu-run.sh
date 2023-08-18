#!/bin/bash

# Runs binary in Qemu
    
DISPLAY=curses
DEBUG=0
QEMU=qemu-system-i386

display_help() {
  echo "Runs the given binary (must be located in bin/) in ${QEMU}."
  echo
  echo "Usage: $0 [options] binary"
  echo
  echo "Options:    "
  echo "--display   The display type for qemu. See qemu(1) for available options."
  echo "--debug     Start qemu with -s and -S flags. See qemu(1)."
  echo "--help      Prints this message."
  exit 0
}

while [[ "$#" -gt 0 ]]; do
  BINARY=bin/$1
  case $1 in
    --display) DISPLAY="$2"; shift ;;
    --debug) DEBUG=1 ;;
    --help) display_help ;;
  esac
  shift
done

FLAGS="--display ${DISPLAY} "
if [[ ${DEBUG} -eq 1 ]]; then
  FLAGS+=" -s -S"
fi

if [ ! -e ${BINARY} ]; then
  echo "$BINARY does not exist."
  exit 1
fi

${QEMU} ${FLAGS} ${BINARY}
