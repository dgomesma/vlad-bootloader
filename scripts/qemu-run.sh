#!/bin/bash
# Runs image in Qemu

THIS_DIR=$(dirname "$0")
source $THIS_DIR/utils.sh

DISPLAY="curses"
DEBUG=0
QEMU="qemu-system-i386"

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

check_programs() {
  program_exists qemu-system-i386 true
}

assert_nargs $# 1

while [[ "$#" -gt 0 ]]; do
  IMG=$1
  case $1 in
    --display) DISPLAY="$2"; shift ;;
    --debug) DEBUG="true" ;;
    --help) display_help ;;
  esac
  shift
done

check_programs

FLAGS="--display ${DISPLAY} "
if [[ ${DEBUG} -eq 1 ]]; then
  FLAGS+=" -s -S"
fi

assert_file_exists ${IMG}

FLAGS+="-fda "
${QEMU} ${FLAGS} ${IMG}
