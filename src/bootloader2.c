void print(char*);

void bootloader2() {
  char* msg = "Success!!";
  print(msg);
}

void print(char* addr) {
  __asm__(
      "mov $0x0, %%ax;"
      "mov %%ax, %%ds;"
      "cld;"

    "print_loop: "
      "lodsb;"
      "or %%al, %%al;"
      "jz exit;"
      "mov $0x0, %%bh;"
      "mov $0x0e, %%ah;"
      "int $0x10;"
      "jmp exit;"

    "exit: "
    :
    : "S" (addr)
    : "ax", "bh"
  );
}
