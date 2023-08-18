BOOT=boot
ASM=nasm
OBJCOPY=objcopy

all: hello-vlad

hello-vlad: bin/hello-vlad.bin

bin/%.bin: build/%.elf
	$(OBJCOPY) -O binary $< $@ 

build/%.elf: src/%.s
	$(ASM) $< -f elf -g -o $@

.PHONY: clean
clean:
	rm -f build/* bin/*
