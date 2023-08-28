.code16

	VIDEO_INT = 0x10
	VIDEO_WCHAR_FN = 0x0e

	DISK_INT = 0x13
	DISK_RESET_FN = 0x00
	DISK_READ_FN = 0x02

.section .text
.globl print
	movw $0x0, %ax
	movw %ax, %ds
	movw $success_msg, %si
	cld

print_loop:
	lodsb
	or %al, %al
	jz hang
	movb $0x0, %bh
	movb $VIDEO_WCHAR_FN, %ah
	int $VIDEO_INT
	jmp print_loop

hang:
	jmp hang

success_msg:
	.asciz "Success!!"	
