BOOT=boot
ASM=nasm
OBJCOPY=objcopy

all: hello-vlad

.PHONY: test

hello-vlad: img/hello-vlad.img

img/hello-vlad.img: build/hello-vlad.bin
	scripts/create-disk.sh $@
	dd if=$< of=$@ bs=512 count=1 conv=notrunc

build/%.bin: src/%.s
	$(ASM) -f binary -o $< $@ 

.PHONY: clean
clean:
	rm -f build/* bin/*
