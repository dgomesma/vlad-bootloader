BOOT=boot

ASM=nasm

ARCH=i686-elf

CC=$(ARCH)-gcc
LD=$(ARCH)-ld

CFLAGS=-ffreestanding -mno-red-zone -nostdlib

all: hello-vlad

.PHONY: test

hello-vlad: img/hello-vlad.img
bootloader: img/bootloader.img

img/hello-vlad.img: bin/hello-vlad.bin
	scripts/create-disk.sh $@
	dd if=$< of=$@ bs=512 count=1 conv=notrunc

img/bootloader.img: bin/bootloader1.bin bin/bootloader2.bin
	scripts/create-disk.sh $@
	dd if=bin/bootloader1.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=bin/bootloader2.bin of=$@ bs=512 seek=1 conv=notrunc

bin/bootloader2.bin: build/bootloader2.o
	$(LD) -T src/bootloader.ld -o $@ $<

build/%.o: src/%.c
	$(CC) $(CFLAGS) -c -o $@ $< 

bin/%.bin: build/%.o
	$(LD) -o $@ $<

bin/%.bin: src/%.s
	$(ASM) -f bin -o $@ $< 

.PHONY: clean
clean:
	rm -f build/* img/* bin/*
