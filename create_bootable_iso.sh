#!/bin/bash

nasm boot.s -f bin -o boot.bin 
mkdir iso_temp
mv boot.bin iso_temp
mkisofs -o bootloader.iso -b boot.bin -no-emul-boot -boot-load-size 4 -boot-info-table iso_temp/
rm -rf iso_temp

