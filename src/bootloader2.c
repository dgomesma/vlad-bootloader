#include "bios.h"
void bios_print_char(char c) {
  __asm__(
    "movb %2, %%ah;"
    "int %1;"
    :
    : "al" (c), "i" (VIDEO_INT), "i" (VIDEO_WCHAR_FN)
    :
  );
}

void bios_print(char *str, unsigned int n) {
  char* c_ptr = str;
  unsigned int i = 0;

  for (char c = *c_ptr; c && i < n; i++, c_ptr++)
  {
    bios_print_char(c);
  }
}

void bootloader2(void) {
  char* msg = "Success";

  bios_print(msg, 7);  
}