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
	MEM_MAP_BUF_PHYS_ADDR = 0x9e3ff
	MEM_MAP_BUF_BEGIN_SEGMENT = 0x9e3f
	MEM_MAP_BUF_BEGIN_OFFSET = 0x000f

	# Physical Address = 0x9fbff
	MEM_MAP_BUF_END_SEGMNET = 0x9fbf
	MEM_MAP_BUF_END_OFFSET = 0x000f

	# Other
	SMAP = 0x534D4150
	SMAP_LOW = 0x4D53
	SMAP_HIGH = 0x5041
	MEM_MAP_STRUCT_SIZE = 24		

.section .text
	call detect_mem
	call print_mem_detected
	call print_success

# Arguments
#	No arguments.
# Clobber:

# Arguments:
#	No arguments.
# Clobber:
#	ES, DI, AX, BX, DX, CX
detect_mem:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %es
	pushw %di
	pushw %bx
	pushw %cx
	pushw %dx

detect_mem_loop_entry:
	movl $MEM_MAP_BUF_PHYS_ADDR, mem_map_buf  
	movb $0x0, mem_map_buf_n

	# Set buffer location
	movw $MEM_MAP_BUF_BEGIN_SEGMENT, %ax
	movw %ax, %es
	movw $MEM_MAP_BUF_BEGIN_OFFSET, %ax
	movw %ax, %di

	# Set function
	movb $BIG_MEM_SIZE_AH, %ah
	movb $SYS_MEM_MAP_AL, %al

	xor %bx, %bx
	movw $MEM_MAP_STRUCT_SIZE, %cx
	movl $SMAP, %edx	# 'SMAP' Signature

detect_mem_loop_body:
	int $BIG_MEM_SRV_INT
	incb mem_map_buf_n

detect_mem_loop_check:
	cmpl $SMAP, %eax 
	jne detect_mem_abort
	cmpw $0x0, %bx  
	je detect_mem_loop_exit 

detect_mem_loop_update:
	addw $MEM_MAP_STRUCT_SIZE, %di
	movw $MEM_MAP_STRUCT_SIZE, %cx

	# Set function
	movb $BIG_MEM_SIZE_AH, %ah
	movb $SYS_MEM_MAP_AL, %al
	jmp detect_mem_loop_body

detect_mem_abort:
	movw $0x0, %ax
	movw %ax, %ds
	movw $mem_map_error, %ax
	movw %ax, %si
	call abort

detect_mem_loop_exit:
	popw %dx
	popw %cx
	popw %bx
	popw %di
	popw %es
	popw %ax
	popw %bp
	ret

# Arguments:
#	DS - Segment where error string is located
#	SI - Offset where error string is located
abort:
	# Function preamble
	pushw %bp
	movw %sp, %bp

	# Store arguments
	sub $4, %sp
	movw %ds, -4(%bp)
	movw %si, -2(%bp)

	# Print error string prefix
	movw $0x0, %ax
	movw %ax, %ds
	movw $error_prefix_str, %ax
	movw %ax, %si
	call print
	
	# Retrieve arguments
	movw -4(%bp), %ds
	movw -2(%bp), %si
	call print

	# Restore stack frame
	movw %bp, %sp
	popw %bp
	jmp hang

# Arguments:
#	No arguments
print_bootloader2_loaded:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $bootloader2_loaded_str, %ax
	movw %ax, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

# Arguments
#	No arguments
print_mem_detected:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %dx
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $mem_detected_str, %ax
	movw %ax, %si

	call print

	popw %si
	popw %dx
	popw %ax
	popw %bp
	ret

# Arguments:
#	No arguments
print_error:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $error_str, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret
	
# Arguments:
#	No arguments
print_success:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $success_str, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

# Arguments:
#	No arguments
print_end:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %ds
	pushw %si

	movw $0x0, %ax
	movw %ax, %ds
	movw $end_str, %si

	call print

	popw %si
	popw %ds
	popw %ax
	popw %bp
	ret

# Arguments:
#	DS - Segment where string is located
#	SI - Offset where string is located
print:
	pushw %bp
	movw %sp, %bp
	pushw %ax
	pushw %bx

print_loop:
	cld
	lodsb
	or %al, %al
	jz print_loop_exit 
	movb $0x0, %bh
	movb $VIDEO_WCHAR_FN, %ah
	int $VIDEO_INT
	jmp print_loop

print_loop_exit:
	popw %bx
	popw %ax
	pop %bp
	ret

hang:
	jmp hang

.section .data
bootloader2_loaded_str:
	.asciz "Bootloader 2 loaded...\n\r"
mem_detected_str:
	.asciz "Memory detected...\n\r"
end_str:
	.asciz "End of execution."	
mem_map_error:
	.asciz "Error detecting memory."
success_str:
	.asciz "Success!"
error_str:
	.asciz "Error!"
error_prefix_str:
	.asciz "Error: "

.section .bss
mem_map_buf:
	.space 8
mem_map_buf_n:
	.space 1
