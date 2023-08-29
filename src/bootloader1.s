.code16

	VIDEO_INT = 0x10
	VIDEO_WCHAR_FN = 0x0e

	DISK_INT = 0x13
	DISK_RESET_FN = 0x00
	DISK_READ_FN = 0x02

	BOOTLD2_ADDR = 0x7e00
	BOOTLD2_SECTOR = 0x2

.section .text
.globl initialize_segments

start:
initialize_segments:
	movw $0x0, %ax
	movw %ax, %ds

initialize_disk:
	movb $DISK_RESET_FN, %ah
	movb $0x0, %dl
	int $DISK_INT
			
# Contents read are buffered into [es:bx]
read_bootloader:
	# Set [es:bx]
	movw $0x0, %ax
	movw %ax, %es
	movw $BOOTLD2_ADDR, %ax
	movw %ax, %bx
	
	# Set interrupt
	movb $DISK_READ_FN, %ah
	movb $0x1, %al
	movb $0x0, %ch
	movb $0x2, %cl
	movb $0x0, %dh
	movb $0x0, %dl
	int $DISK_INT
	jc reading_error


# Stack pointer denoted by [ss:sp]
set_stack_ptr:
	movw $0x0, %ax
	movw %ax, %ss
	movw $start, %sp	

call_bootloader2:
	call bootloader2

reading_error:
	movw $error_msg, %si
	cld

print_error:
	lodsb
	or %al, %al
	jz hang
	movb $0x0, %bh
	movb $VIDEO_WCHAR_FN, %ah
	int $VIDEO_INT
	jmp print_error

hang:
	jmp hang

error_msg:
	.asciz "Error reading from disk!"

signature:
	.fill 510 - (. - initialize_segments), 1, 0
	.byte 0x55
	.byte 0xaa
