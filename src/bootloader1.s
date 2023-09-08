.code16

	VIDEO_INT = 0x10
	VIDEO_WCHAR_FN = 0x0e

	DISK_INT = 0x13
	DISK_RESET_FN = 0x00
	DISK_READ_FN = 0x02

	BOOTLD2_ADDR = 0x7e00
	BOOTLD2_SECTOR = 0x2

	STACK_SEGMENT = 0x0000 
	STACK_OFFSET = 0x7c00

.section .text
.globl initialize_segments

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
	movb $0x3, %al	# No. of Sectors
	movb $0x0, %ch	# Track Number
	movb $0x2, %cl	# Sector Number
	movb $0x0, %dh	# Head Number
	movb $0x0, %dl	# Drive Number
	int $DISK_INT
	jc reading_error

prepare_stack:
	movw $STACK_SEGMENT, %ax
	movw %ax, %ss
	movw $STACK_OFFSET, %ax
	movw %ax, %sp
	movw %sp, %bp

jmp_to_bootloader2:
	ljmp $0x0, $BOOTLD2_ADDR

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
