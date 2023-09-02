.code16

	# Interrupts
	VIDEO_INT = 0x10
	VIDEO_WCHAR_FN = 0x0e

	DISK_INT = 0x13
	DISK_RESET_FN = 0x00
	DISK_READ_FN = 0x02

	# Big Memory Services
	BIG_MEM_SRV_INT = 0x15
	BIG_MEM_SIZE_AH = 0xe8
	SYS_MEM_MAP_AL = 0x20

	# Memory Allocation
	# Memory Map Buffer
	# Physical Address = 0x9e3ff
	MEM_MAP_BUF_BEGIN_SEGMENT = 0x9e3f
	MEM_MAP_BUF_BEGIN_OFFSET = 0x000f

	# Physical Address = 0x9fbff
	MEM_MAP_BUF_END_SEGMNET = 0x9fbf
	MEM_MAP_BUF_END_OFFSET = 0x000f

	# Other
	SMAP = 0x534D4150
	MEM_MAP_STRUCT_SIZE = 24		
.section .text
detect_memory:
	# Set buffer location
	movw $MEM_MAP_BUF_BEGIN_SEGMENT, %ax
	movw %ax, %es
	movw $MEM_MAP_BUF_BEGIN_OFFSET, %ax
	movw %ax, %di

	# Set function
	movb $BIG_MEM_SIZE_AH, %ah
	movb $SYS_MEM_MAP_AL, %al

	xor %bx, %bx		# Set continuation value
	movw $MEM_MAP_STRUCT_SIZE, %cx
	movl $SMAP, %edx	# 'SMAP' Signature

	int $BIG_MEM_SRV_INT

print_end:
	movw $0x0, %ax
	movw %ax, %ds
	movw $end_msg, %si
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

end_msg:
	.asciz "End of execution."	
