BOOT=boot
ASM=nasm

SRC=$(BOOT).s
BIN=$(BOOT).bin

all: $(BIN)

$(BIN):
	$(ASM) $(SRC) -f bin -o $@

.PHONY: clean
clean:
	rm $(BIN)
