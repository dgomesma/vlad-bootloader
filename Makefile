BOOT=boot

ARCH=i686-elf

AS=$(ARCH)-as
OBJCOPY=$(ARCH)-objcopy
LD=$(ARCH)-ld

all: hello-vlad

.PHONY: test

hello-vlad: img/hello-vlad.img
bootloader: img/bootloader.img

img/hello-vlad.img:
	scripts/create-disk.sh $@
	nasm -f bin -o bin/hello-vlad.bin src/hello-vlad.s
	dd if=bin/hello-vlad.bin of=$@ bs=512 count=1 conv=notrunc

img/bootloader.img: bin/bootloader.bin
	scripts/create-disk.sh $@
	dd if=$< of=$@ bs=512 count=3 conv=notrunc

bin/bootloader.bin: build/bootloader1.o build/bootloader2.o 
	$(LD) -T ldscripts/bootloader.ld -o $@ $?

build/%.o: src/%.s
	$(AS) -o $@ $< 

.PHONY: clean
clean:
	rm -f build/* img/* bin/*
