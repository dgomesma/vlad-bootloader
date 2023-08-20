BOOT=boot
ASM=nasm
OBJCOPY=objcopy

all: hello-vlad

.PHONY: test

hello-vlad: img/hello-vlad.img
bootloader: img/bootloader.img

img/hello-vlad.img: build/hello-vlad.bin
	scripts/create-disk.sh $@
	dd if=$< of=$@ bs=512 count=1 conv=notrunc

img/bootloader.img: build/bootloader1.bin build/bootloader2.bin
	scripts/create-disk.sh $@
	dd if=build/bootloader1.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=build/bootloader2.bin of=$@ bs=512 seek=1 conv=notrunc

build/%.bin: src/%.s
	$(ASM) -f bin -o $@ $< 

.PHONY: clean
clean:
	rm -f build/* img/*
